package com.toeic.practice;

import com.toeic.practice.entity.*;
import com.toeic.practice.repository.*;
import com.toeic.practice.service.UserTestStatsService;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Migration test: backfills user_test_stats và user_part_stats
 * từ toàn bộ lịch sử attempt hiện có trong DB.
 *
 * Chạy 1 lần sau khi deploy code mới.
 * Safe to re-run: mỗi lần rebuild sẽ xoá và tính lại từ đầu.
 *
 * Run command:
 *   ./gradlew test --tests "com.toeic.practice.AnalyticsCacheMigrationTest"
 */
@SpringBootTest
@ActiveProfiles("default")
class AnalyticsCacheMigrationTest {

    private static final Logger log = LoggerFactory.getLogger(AnalyticsCacheMigrationTest.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private TestAttemptRepository attemptRepository;

    @Autowired
    private UserTestStatsRepository userTestStatsRepository;

    @Autowired
    private UserPartStatsRepository userPartStatsRepository;

    @Autowired
    private UserTestStatsService userTestStatsService;

    /**
     * Rebuild cache cho tất cả users trong DB.
     * Sau khi chạy, kiểm tra xem user nào có attempt thì phải có row trong user_test_stats.
     */
    @Test
    void rebuildAnalyticsCacheForAllUsers() {
        List<User> allUsers = userRepository.findAll();
        log.info("=== Analytics Cache Migration ===");
        log.info("Found {} users to process", allUsers.size());

        int processedUsers = 0;
        int totalTestEntries = 0;
        int totalPartEntries = 0;

        for (User user : allUsers) {
            List<TestAttempt> attempts = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId());
            long completedCount = attempts.stream().filter(a -> a.getCompletedAt() != null).count();

            if (completedCount == 0) {
                log.info("  User [{}] {} — no completed attempts, skipping", user.getId(), user.getEmail());
                continue;
            }

            log.info("  Processing user [{}] {} — {} completed attempts...",
                    user.getId(), user.getEmail(), completedCount);

            userTestStatsService.rebuildForUser(user);

            long testEntries = userTestStatsRepository.findByUserIdOrderByLastAttemptDateDesc(user.getId()).size();
            long partEntries = userPartStatsRepository.findByUserId(user.getId()).size();

            log.info("    → {} test entries, {} part entries created", testEntries, partEntries);
            totalTestEntries += testEntries;
            totalPartEntries += partEntries;
            processedUsers++;
        }

        log.info("=== Migration Complete ===");
        log.info("Processed {} users", processedUsers);
        log.info("Total user_test_stats rows: {}", totalTestEntries);
        log.info("Total user_part_stats rows: {}", totalPartEntries);

        // Verify: mọi user có completed attempt đều phải có ít nhất 1 test entry
        for (User user : allUsers) {
            long completedCount = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId())
                    .stream().filter(a -> a.getCompletedAt() != null).count();
            if (completedCount > 0) {
                List<UserTestStats> testStats = userTestStatsRepository
                        .findByUserIdOrderByLastAttemptDateDesc(user.getId());
                assertThat(testStats)
                        .as("User %s phải có ít nhất 1 test stats entry", user.getEmail())
                        .isNotEmpty();

                // Verify accuracy là số hợp lệ (0-100)
                testStats.forEach(ts -> {
                    assertThat(ts.getAverageAccuracy())
                            .as("averageAccuracy phải trong khoảng [0, 100]")
                            .isBetween(0.0, 100.0);
                    assertThat(ts.getBestAccuracy())
                            .as("bestAccuracy phải >= averageAccuracy")
                            .isGreaterThanOrEqualTo(ts.getAverageAccuracy() - 0.1); // tolerance cho rounding
                    assertThat(ts.getTotalAttempts())
                            .as("totalAttempts phải > 0")
                            .isGreaterThan(0);
                });

                // Verify part stats
                List<UserPartStats> partStats = userPartStatsRepository.findByUserId(user.getId());
                partStats.forEach(ps -> {
                    assertThat(ps.getPartNumber()).isBetween(1, 7);
                    assertThat(ps.getTotalAnswered()).isGreaterThanOrEqualTo(ps.getTotalCorrect());
                    assertThat(ps.getAverageAccuracy()).isBetween(0.0, 100.0);
                });
            }
        }

        log.info("=== All assertions passed ✓ ===");
    }

    /**
     * Verify incremental accuracy: tổng totalAttempts trong cache
     * phải khớp với số completed attempts trong test_attempts.
     */
    @Test
    @Transactional
    void verifyIncrementalAccuracy() {
        List<User> allUsers = userRepository.findAll();

        for (User user : allUsers) {
            // Rebuild fresh
            userTestStatsService.rebuildForUser(user);

            List<TestAttempt> completed = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId())
                    .stream().filter(a -> a.getCompletedAt() != null).toList();

            if (completed.isEmpty()) continue;

            List<UserTestStats> testStats = userTestStatsRepository
                    .findByUserIdOrderByLastAttemptDateDesc(user.getId());

            // Tổng totalAttempts qua tất cả đề = số completed attempts
            int sumAttempts = testStats.stream().mapToInt(UserTestStats::getTotalAttempts).sum();
            assertThat(sumAttempts)
                    .as("Tổng attempts trong cache của user %s phải khớp với DB", user.getEmail())
                    .isEqualTo(completed.size());

            // totalFullAttempts + totalPartAttempts = totalAttempts cho mỗi đề
            testStats.forEach(ts ->
                    assertThat(ts.getTotalFullAttempts() + ts.getTotalPartAttempts())
                            .as("full + part = total cho đề %s", ts.getTest().getTitle())
                            .isEqualTo(ts.getTotalAttempts()));

            log.info("User [{}] {}: {} test entries verified ✓", user.getId(), user.getEmail(), testStats.size());
        }
    }
}
