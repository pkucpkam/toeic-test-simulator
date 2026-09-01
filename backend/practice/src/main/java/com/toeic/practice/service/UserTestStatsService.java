package com.toeic.practice.service;

import com.toeic.practice.entity.*;
import com.toeic.practice.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Manages pre-computed analytics caches:
 *   - user_test_stats  (per user per test)
 *   - user_part_stats  (per user per test per part)
 *
 * Two modes of operation:
 *   1. Incremental: called after each submit — O(answers in that attempt)
 *   2. Full rebuild: called by migration test / admin — reprocesses all attempts
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class UserTestStatsService {

    private final UserTestStatsRepository testStatsRepo;
    private final UserPartStatsRepository partStatsRepo;
    private final UserAnswerRepository userAnswerRepository;
    private final TestAttemptRepository attemptRepository;

    // ── Incremental update (called after each submit) ────────────────────────

    /**
     * Updates user_test_stats and user_part_stats incrementally for one attempt.
     * Only reads the answers just submitted — does NOT scan historical data.
     *
     * @param user    the user who submitted
     * @param attempt the completed attempt (completedAt already set)
     * @param answers all UserAnswer records saved for this attempt
     */
    @Transactional
    public void updateStatsForAttempt(User user, TestAttempt attempt, List<UserAnswer> answers) {
        Test test = resolveTest(attempt);
        if (test == null) {
            log.warn("Cannot resolve test for attempt {}, skipping stats update", attempt.getId());
            return;
        }

        double attemptAccuracy = calcAttemptAccuracy(attempt);

        // ── 1. Update user_test_stats ────────────────────────────────────────
        UserTestStats testStats = testStatsRepo
                .findByUserIdAndTestId(user.getId(), test.getId())
                .orElseGet(() -> UserTestStats.builder().user(user).test(test).build());

        int n = testStats.getTotalAttempts() + 1;
        double newAvg = (testStats.getAverageAccuracy() * (n - 1) + attemptAccuracy) / n;
        double newBest = Math.max(testStats.getBestAccuracy(), attemptAccuracy);

        testStats.setTotalAttempts(n);
        if ("FULL".equals(attempt.getAttemptType())) {
            testStats.setTotalFullAttempts(testStats.getTotalFullAttempts() + 1);
        } else {
            testStats.setTotalPartAttempts(testStats.getTotalPartAttempts() + 1);
        }
        testStats.setAverageAccuracy(round1(newAvg));
        testStats.setBestAccuracy(round1(newBest));
        testStats.setLastAttemptDate(attempt.getStartedAt());
        testStatsRepo.save(testStats);

        // ── 2. Update user_part_stats (group answers by partNumber) ──────────
        Map<Integer, List<UserAnswer>> byPart = answers.stream()
                .filter(ua -> ua.getSelectedOption() != null && !ua.getSelectedOption().isEmpty())
                .collect(Collectors.groupingBy(ua -> getPartNum(ua)));

        for (Map.Entry<Integer, List<UserAnswer>> entry : byPart.entrySet()) {
            Integer partNum = entry.getKey();
            if (partNum < 1 || partNum > 7) continue;

            List<UserAnswer> partAnswers = entry.getValue();
            int answered = partAnswers.size();
            int correct = (int) partAnswers.stream().filter(ua -> Boolean.TRUE.equals(ua.getIsCorrect())).count();
            double partAcc = answered > 0 ? (double) correct / answered * 100 : 0.0;

            UserPartStats partStats = partStatsRepo
                    .findByUserIdAndTestIdAndPartNumber(user.getId(), test.getId(), partNum)
                    .orElseGet(() -> UserPartStats.builder().user(user).test(test).partNumber(partNum).build());

            int pn = partStats.getTotalAttempts() + 1;
            double pAvg = (partStats.getAverageAccuracy() * (pn - 1) + partAcc) / pn;
            double pBest = Math.max(partStats.getBestAccuracy(), partAcc);

            partStats.setTotalAttempts(pn);
            partStats.setTotalAnswered(partStats.getTotalAnswered() + answered);
            partStats.setTotalCorrect(partStats.getTotalCorrect() + correct);
            partStats.setAverageAccuracy(round1(pAvg));
            partStats.setBestAccuracy(round1(pBest));
            partStatsRepo.save(partStats);
        }
    }

    // ── Full rebuild (migration / admin) ─────────────────────────────────────

    /**
     * Wipes and rebuilds all cache rows for a single user from scratch.
     * Used by the migration JUnit test and the rebuild endpoint.
     */
    @Transactional
    public void rebuildForUser(User user) {
        log.info("Rebuilding test/part stats cache for user {}", user.getId());

        // Clear existing cache rows for this user
        testStatsRepo.deleteByUserId(user.getId());
        partStatsRepo.deleteByUserId(user.getId());

        List<TestAttempt> attempts = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId());

        // Process in chronological order so running averages are correct
        List<TestAttempt> completed = attempts.stream()
                .filter(a -> a.getCompletedAt() != null)
                .sorted(Comparator.comparing(TestAttempt::getStartedAt))
                .collect(Collectors.toList());

        // In-memory accumulators: testId → stats, (testId,part) → stats
        Map<Long, UserTestStats> testMap = new HashMap<>();
        Map<String, UserPartStats> partMap = new HashMap<>();

        for (TestAttempt attempt : completed) {
            Test test = resolveTest(attempt);
            if (test == null) continue;

            double attemptAccuracy = calcAttemptAccuracy(attempt);
            Long testId = test.getId();

            // Accumulate test-level stats
            UserTestStats ts = testMap.computeIfAbsent(testId,
                    k -> UserTestStats.builder().user(user).test(test).build());

            int tn = ts.getTotalAttempts() + 1;
            ts.setTotalAttempts(tn);
            if ("FULL".equals(attempt.getAttemptType())) {
                ts.setTotalFullAttempts(ts.getTotalFullAttempts() + 1);
            } else {
                ts.setTotalPartAttempts(ts.getTotalPartAttempts() + 1);
            }
            ts.setAverageAccuracy(round1((ts.getAverageAccuracy() * (tn - 1) + attemptAccuracy) / tn));
            ts.setBestAccuracy(round1(Math.max(ts.getBestAccuracy(), attemptAccuracy)));
            // Keep the latest (we sorted ASC, so last overwrite wins = most recent)
            ts.setLastAttemptDate(attempt.getStartedAt());

            // Accumulate part-level stats from UserAnswers
            List<UserAnswer> answers = userAnswerRepository.findByAttemptId(attempt.getId());
            Map<Integer, List<UserAnswer>> byPart = answers.stream()
                    .filter(ua -> ua.getSelectedOption() != null && !ua.getSelectedOption().isEmpty())
                    .collect(Collectors.groupingBy(ua -> getPartNum(ua)));

            for (Map.Entry<Integer, List<UserAnswer>> entry : byPart.entrySet()) {
                Integer partNum = entry.getKey();
                if (partNum < 1 || partNum > 7) continue;

                List<UserAnswer> partAnswers = entry.getValue();
                int answered = partAnswers.size();
                int correct = (int) partAnswers.stream()
                        .filter(ua -> Boolean.TRUE.equals(ua.getIsCorrect())).count();
                double partAcc = answered > 0 ? (double) correct / answered * 100 : 0.0;

                String key = testId + "_" + partNum;
                UserPartStats ps = partMap.computeIfAbsent(key,
                        k -> UserPartStats.builder().user(user).test(test).partNumber(partNum).build());

                int pn = ps.getTotalAttempts() + 1;
                ps.setTotalAttempts(pn);
                ps.setTotalAnswered(ps.getTotalAnswered() + answered);
                ps.setTotalCorrect(ps.getTotalCorrect() + correct);
                ps.setAverageAccuracy(round1((ps.getAverageAccuracy() * (pn - 1) + partAcc) / pn));
                ps.setBestAccuracy(round1(Math.max(ps.getBestAccuracy(), partAcc)));
            }
        }

        // Batch save
        testStatsRepo.saveAll(testMap.values());
        partStatsRepo.saveAll(partMap.values());

        log.info("Rebuilt cache for user {}: {} test entries, {} part entries",
                user.getId(), testMap.size(), partMap.size());
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private Test resolveTest(TestAttempt attempt) {
        if (attempt.getTest() != null) return attempt.getTest();
        if (attempt.getTestPart() != null) return attempt.getTestPart().getTest();
        return null;
    }

    private double calcAttemptAccuracy(TestAttempt a) {
        int correct = a.getTotalCorrect() != null ? a.getTotalCorrect() : 0;
        int incorrect = a.getTotalIncorrect() != null ? a.getTotalIncorrect() : 0;
        int unanswered = a.getTotalUnanswered() != null ? a.getTotalUnanswered() : 0;
        int total = correct + incorrect + unanswered;
        return total > 0 ? (double) correct / total * 100 : 0.0;
    }

    private int getPartNum(UserAnswer ua) {
        try {
            if (ua.getQuestion() == null || ua.getQuestion().getQuestionGroup() == null) return 0;
            var qg = ua.getQuestion().getQuestionGroup();
            if (qg.getTestPart() == null) return 0;
            return qg.getTestPart().getPartNumber() != null ? qg.getTestPart().getPartNumber() : 0;
        } catch (Exception e) {
            return 0;
        }
    }

    private double round1(double val) {
        return Math.round(val * 10.0) / 10.0;
    }
}
