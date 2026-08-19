package com.toeic.practice.service;

import com.toeic.practice.dto.*;
import com.toeic.practice.entity.TestAttempt;
import com.toeic.practice.entity.User;
import com.toeic.practice.entity.UserDashboardStats;
import com.toeic.practice.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final TestAttemptRepository attemptRepository;
    private final UserDashboardStatsService userDashboardStatsService;

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
            return AttemptHistoryDto.builder()
                    .id(attempt.getId())
                    .testId(testId)
                    .testTitle(title)
                    .attemptType(attempt.getAttemptType())
                    .totalScore(attempt.getTotalScore())
                    .totalCorrect(attempt.getTotalCorrect())
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

        String[] partNames = {
                "Photos", "Question-Response", "Conversations",
                "Short Talks", "Incomplete Sentences", "Text Completion", "Reading Passages"
        };

        int[][] partData = {
                {stats.getP1Total() != null ? stats.getP1Total() : 0, stats.getP1Correct() != null ? stats.getP1Correct() : 0},
                {stats.getP2Total() != null ? stats.getP2Total() : 0, stats.getP2Correct() != null ? stats.getP2Correct() : 0},
                {stats.getP3Total() != null ? stats.getP3Total() : 0, stats.getP3Correct() != null ? stats.getP3Correct() : 0},
                {stats.getP4Total() != null ? stats.getP4Total() : 0, stats.getP4Correct() != null ? stats.getP4Correct() : 0},
                {stats.getP5Total() != null ? stats.getP5Total() : 0, stats.getP5Correct() != null ? stats.getP5Correct() : 0},
                {stats.getP6Total() != null ? stats.getP6Total() : 0, stats.getP6Correct() != null ? stats.getP6Correct() : 0},
                {stats.getP7Total() != null ? stats.getP7Total() : 0, stats.getP7Correct() != null ? stats.getP7Correct() : 0}
        };

        List<PartAccuracyDto> list = new ArrayList<>();
        for (int i = 1; i <= 7; i++) {
            int total = partData[i - 1][0];
            int correct = partData[i - 1][1];
            double accuracy = total > 0 ? (double) correct / total * 100 : 0.0;
            list.add(PartAccuracyDto.builder()
                    .partNumber(i)
                    .partName(partNames[i - 1])
                    .totalAnswered(total)
                    .totalCorrect(correct)
                    .accuracy(Math.round(accuracy * 10.0) / 10.0)
                    .build());
        }
        return list;
    }
}
