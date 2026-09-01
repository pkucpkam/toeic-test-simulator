package com.toeic.practice.service;

import com.toeic.practice.dto.*;
import com.toeic.practice.entity.*;
import com.toeic.practice.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final TestAttemptRepository attemptRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final UserTestStatsRepository userTestStatsRepository;
    private final UserPartStatsRepository userPartStatsRepository;
    private final UserDashboardStatsService userDashboardStatsService;

    private static final String[] PART_NAMES = {
            "Photos", "Question-Response", "Conversations",
            "Short Talks", "Incomplete Sentences", "Text Completion", "Reading Passages"
    };

    // ── Existing methods ────────────────────────────────────────────────────────

    public PageResponseDto<AttemptHistoryDto> getHistory(User user, int page, int size) {
        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(page, size);
        org.springframework.data.domain.Page<TestAttempt> attemptPage = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId(), pageable);
        return PageResponseDto.of(attemptPage, attempt -> {
            Long testId = attempt.getTest() != null ? attempt.getTest().getId()
                    : (attempt.getTestPart() != null && attempt.getTestPart().getTest() != null
                            ? attempt.getTestPart().getTest().getId() : 1L);
            String title = attempt.getTest() != null ? attempt.getTest().getTitle()
                    : (attempt.getTestPart() != null && attempt.getTestPart().getTest() != null
                            ? attempt.getTestPart().getTest().getTitle() : "Unknown");
            Integer partNumber = attempt.getTestPart() != null ? attempt.getTestPart().getPartNumber() : null;
            return AttemptHistoryDto.builder()
                    .id(attempt.getId())
                    .testId(testId)
                    .testTitle(title)
                    .attemptType(attempt.getAttemptType())
                    .partNumber(partNumber)
                    .totalScore(attempt.getTotalScore())
                    .totalCorrect(attempt.getTotalCorrect())
                    .totalIncorrect(attempt.getTotalIncorrect())
                    .totalUnanswered(attempt.getTotalUnanswered())
                    .durationSeconds(attempt.getDurationSeconds())
                    .startedAt(attempt.getStartedAt())
                    .completedAt(attempt.getCompletedAt())
                    .build();
        });
    }

    public AnalyticsStatsDto getStats(User user) {
        UserDashboardStats stats = userDashboardStatsService.getOrCalculateStats(user);
        return AnalyticsStatsDto.builder()
                .totalAttempts(stats.getTotalAttempts() != null ? stats.getTotalAttempts() : 0)
                .totalFullTests(stats.getTotalFullTests() != null ? stats.getTotalFullTests() : 0)
                .totalPartPractices(stats.getTotalPartPractices() != null ? stats.getTotalPartPractices() : 0)
                .averageScore(stats.getAverageScore() != null ? stats.getAverageScore() : 0.0)
                .averageAccuracy(stats.getAverageAccuracy() != null ? stats.getAverageAccuracy() : 0.0)
                .bestScore(stats.getBestScore() != null ? stats.getBestScore() : 0)
                .currentStreak(stats.getCurrentStreak() != null ? stats.getCurrentStreak() : 0)
                .build();
    }

    public PageResponseDto<ScoreHistoryDto> getScoreHistory(User user, int page, int size) {
        org.springframework.data.domain.Pageable pageable = org.springframework.data.domain.PageRequest.of(page, size);
        org.springframework.data.domain.Page<TestAttempt> attemptPage = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId(), pageable);
        return PageResponseDto.of(attemptPage, a -> {
            int total = (a.getTotalCorrect() != null ? a.getTotalCorrect() : 0)
                    + (a.getTotalIncorrect() != null ? a.getTotalIncorrect() : 0)
                    + (a.getTotalUnanswered() != null ? a.getTotalUnanswered() : 0);
            double accuracy = total > 0
                    ? (double) (a.getTotalCorrect() != null ? a.getTotalCorrect() : 0) / total * 100 : 0;
            return ScoreHistoryDto.builder()
                    .attemptId(a.getId())
                    .testTitle(a.getTest() != null ? a.getTest().getTitle() : "Unknown")
                    .attemptType(a.getAttemptType())
                    .totalCorrect(a.getTotalCorrect())
                    .totalQuestions(total)
                    .accuracy(Math.round(accuracy * 10.0) / 10.0)
                    .date(a.getStartedAt())
                    .build();
        });
    }

    public List<PartAccuracyDto> getPartAccuracy(User user) {
        UserDashboardStats stats = userDashboardStatsService.getOrCalculateStats(user);
        int[][] partData = {
                {nvl(stats.getP1Total()), nvl(stats.getP1Correct())},
                {nvl(stats.getP2Total()), nvl(stats.getP2Correct())},
                {nvl(stats.getP3Total()), nvl(stats.getP3Correct())},
                {nvl(stats.getP4Total()), nvl(stats.getP4Correct())},
                {nvl(stats.getP5Total()), nvl(stats.getP5Correct())},
                {nvl(stats.getP6Total()), nvl(stats.getP6Correct())},
                {nvl(stats.getP7Total()), nvl(stats.getP7Correct())}
        };
        List<PartAccuracyDto> list = new ArrayList<>();
        for (int i = 1; i <= 7; i++) {
            int total = partData[i - 1][0];
            int correct = partData[i - 1][1];
            double accuracy = total > 0 ? (double) correct / total * 100 : 0.0;
            list.add(PartAccuracyDto.builder()
                    .partNumber(i).partName(PART_NAMES[i - 1])
                    .totalAnswered(total).totalCorrect(correct)
                    .accuracy(Math.round(accuracy * 10.0) / 10.0)
                    .build());
        }
        return list;
    }

    // ── New: read from pre-computed cache ─────────────────────────────────────

    /**
     * Danh sách các đề user đã luyện — đọc từ user_test_stats (O(1) query).
     */
    public List<AttemptedTestDto> getAttemptedTests(User user) {
        return userTestStatsRepository.findByUserIdOrderByLastAttemptDateDesc(user.getId())
                .stream()
                .map(ts -> AttemptedTestDto.builder()
                        .testId(ts.getTest().getId())
                        .testTitle(ts.getTest().getTitle())
                        .totalAttempts(ts.getTotalAttempts())
                        .averageAccuracy(ts.getAverageAccuracy())
                        .bestAccuracy(ts.getBestAccuracy())
                        .lastAttemptDate(ts.getLastAttemptDate())
                        .build())
                .collect(Collectors.toList());
    }

    /**
     * Chi tiết analytics cho 1 đề — đọc từ user_test_stats + user_part_stats (2 queries).
     */
    public TestAnalyticsDto getTestAnalytics(User user, Long testId) {
        UserTestStats ts = userTestStatsRepository
                .findByUserIdAndTestId(user.getId(), testId)
                .orElse(null);

        List<UserPartStats> partStatsList = userPartStatsRepository
                .findByUserIdAndTestIdOrderByPartNumber(user.getId(), testId);

        // Build part accuracy list (all 7 parts, fill 0 if no data)
        Map<Integer, UserPartStats> partMap = partStatsList.stream()
                .collect(Collectors.toMap(UserPartStats::getPartNumber, p -> p));

        List<PartAccuracyDto> partStats = new ArrayList<>();
        for (int i = 1; i <= 7; i++) {
            UserPartStats ps = partMap.get(i);
            partStats.add(PartAccuracyDto.builder()
                    .partNumber(i)
                    .partName(PART_NAMES[i - 1])
                    .totalAnswered(ps != null ? ps.getTotalAnswered() : 0)
                    .totalCorrect(ps != null ? ps.getTotalCorrect() : 0)
                    .accuracy(ps != null ? ps.getAverageAccuracy() : 0.0)
                    .build());
        }

        if (ts == null) {
            return TestAnalyticsDto.builder()
                    .testId(testId).testTitle("Unknown")
                    .totalAttempts(0).totalFullAttempts(0).totalPartAttempts(0)
                    .averageAccuracy(0.0).bestAccuracy(0.0)
                    .partStats(partStats).build();
        }

        return TestAnalyticsDto.builder()
                .testId(testId)
                .testTitle(ts.getTest().getTitle())
                .totalAttempts(ts.getTotalAttempts())
                .totalFullAttempts(ts.getTotalFullAttempts())
                .totalPartAttempts(ts.getTotalPartAttempts())
                .averageAccuracy(ts.getAverageAccuracy())
                .bestAccuracy(ts.getBestAccuracy())
                .lastAttemptDate(ts.getLastAttemptDate())
                .partStats(partStats)
                .build();
    }

    /**
     * Chi tiết 1 part trong 1 đề — lấy UserPartStats từ cache + attempt history từ DB.
     * Attempt history vẫn cần query nhưng chỉ cần 1 bảng (test_attempts) + answers theo part.
     */
    public PartDetailDto getPartDetail(User user, Long testId, Integer partNumber) {
        String partName = (partNumber >= 1 && partNumber <= 7) ? PART_NAMES[partNumber - 1] : "Part " + partNumber;

        // Cache summary
        UserPartStats ps = userPartStatsRepository
                .findByUserIdAndTestIdAndPartNumber(user.getId(), testId, partNumber)
                .orElse(null);

        // Attempt history for trend chart — query attempts related to this test
        List<TestAttempt> allAttempts = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId());
        List<TestAttempt> testAttempts = allAttempts.stream()
                .filter(a -> {
                    Test t = resolveTest(a);
                    return t != null && t.getId().equals(testId) && a.getCompletedAt() != null;
                })
                .collect(Collectors.toList());

        String testTitle = testAttempts.stream()
                .map(this::resolveTest).filter(Objects::nonNull)
                .map(Test::getTitle).findFirst().orElse("Unknown");

        // Build attempt history
        List<PartDetailDto.AttemptSummaryDto> history = new ArrayList<>();
        for (TestAttempt attempt : testAttempts) {
            boolean isPartAttempt = "PART".equals(attempt.getAttemptType());
            boolean partMatches = isPartAttempt
                    && attempt.getTestPart() != null
                    && partNumber.equals(attempt.getTestPart().getPartNumber());
            if (isPartAttempt && !partMatches) continue;

            List<UserAnswer> answers = isPartAttempt
                    ? userAnswerRepository.findByAttemptId(attempt.getId())
                    : userAnswerRepository.findByAttemptIdAndPartNumber(attempt.getId(), partNumber);

            int totalAnswered = (int) answers.stream()
                    .filter(ua -> ua.getSelectedOption() != null && !ua.getSelectedOption().isEmpty()).count();
            int totalCorrect = (int) answers.stream()
                    .filter(ua -> Boolean.TRUE.equals(ua.getIsCorrect())).count();
            if (totalAnswered == 0) continue;

            double acc = (double) totalCorrect / totalAnswered * 100;
            history.add(PartDetailDto.AttemptSummaryDto.builder()
                    .attemptId(attempt.getId())
                    .date(attempt.getStartedAt())
                    .totalCorrect(totalCorrect)
                    .totalAnswered(totalAnswered)
                    .accuracy(Math.round(acc * 10.0) / 10.0)
                    .durationSeconds(attempt.getDurationSeconds())
                    .build());
        }
        history.sort(Comparator.comparing(PartDetailDto.AttemptSummaryDto::getDate));

        return PartDetailDto.builder()
                .testId(testId)
                .testTitle(testTitle)
                .partNumber(partNumber)
                .partName(partName)
                .totalAttempts(ps != null ? ps.getTotalAttempts() : history.size())
                .totalAnswered(ps != null ? ps.getTotalAnswered() : history.stream().mapToInt(PartDetailDto.AttemptSummaryDto::getTotalAnswered).sum())
                .totalCorrect(ps != null ? ps.getTotalCorrect() : history.stream().mapToInt(PartDetailDto.AttemptSummaryDto::getTotalCorrect).sum())
                .averageAccuracy(ps != null ? ps.getAverageAccuracy() : history.stream().mapToDouble(PartDetailDto.AttemptSummaryDto::getAccuracy).average().orElse(0.0))
                .bestAccuracy(ps != null ? ps.getBestAccuracy() : history.stream().mapToDouble(PartDetailDto.AttemptSummaryDto::getAccuracy).max().orElse(0.0))
                .attemptHistory(history)
                .build();
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private Test resolveTest(TestAttempt attempt) {
        if (attempt.getTest() != null) return attempt.getTest();
        if (attempt.getTestPart() != null) return attempt.getTestPart().getTest();
        return null;
    }

    private int nvl(Integer v) { return v != null ? v : 0; }
}
