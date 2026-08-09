package com.toeic.practice.service;

import com.toeic.practice.dto.*;
import com.toeic.practice.entity.TestAttempt;
import com.toeic.practice.entity.User;
import com.toeic.practice.entity.UserAnswer;
import com.toeic.practice.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final TestAttemptRepository attemptRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final QuestionGroupRepository questionGroupRepository;
    private final TestPartRepository testPartRepository;

    public List<AttemptHistoryDto> getHistory(User user) {
        return attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId())
                .stream()
                .map(attempt -> AttemptHistoryDto.builder()
                        .id(attempt.getId())
                        .testTitle(attempt.getTest() != null ? attempt.getTest().getTitle() : "Unknown")
                        .attemptType(attempt.getAttemptType())
                        .totalScore(attempt.getTotalScore())
                        .totalCorrect(attempt.getTotalCorrect())
                        .durationSeconds(attempt.getDurationSeconds())
                        .startedAt(attempt.getStartedAt())
                        .completedAt(attempt.getCompletedAt())
                        .build())
                .collect(Collectors.toList());
    }

    public AnalyticsStatsDto getStats(User user) {
        List<TestAttempt> attempts = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId());

        int totalAttempts = attempts.size();
        long totalFull = attempts.stream().filter(a -> "FULL".equals(a.getAttemptType())).count();
        long totalPart = attempts.stream().filter(a -> "PART".equals(a.getAttemptType())).count();

        List<TestAttempt> completed = attempts.stream()
                .filter(a -> a.getCompletedAt() != null && a.getTotalCorrect() != null)
                .collect(Collectors.toList());

        double avgScore = completed.stream()
                .mapToInt(a -> a.getTotalCorrect() != null ? a.getTotalCorrect() : 0)
                .average().orElse(0.0);

        double avgAccuracy = completed.stream()
                .filter(a -> a.getTotalCorrect() != null && a.getTotalIncorrect() != null)
                .mapToDouble(a -> {
                    int answered = a.getTotalCorrect() + a.getTotalIncorrect();
                    return answered > 0 ? (double) a.getTotalCorrect() / answered * 100 : 0;
                })
                .average().orElse(0.0);

        int bestScore = completed.stream()
                .mapToInt(a -> a.getTotalCorrect() != null ? a.getTotalCorrect() : 0)
                .max().orElse(0);

        // Calculate current streak (consecutive distinct days with at least 1 completed attempt)
        int streak = calculateStreak(completed);

        return AnalyticsStatsDto.builder()
                .totalAttempts(totalAttempts)
                .totalFullTests((int) totalFull)
                .totalPartPractices((int) totalPart)
                .averageScore(Math.round(avgScore * 10.0) / 10.0)
                .averageAccuracy(Math.round(avgAccuracy * 10.0) / 10.0)
                .bestScore(bestScore)
                .currentStreak(streak)
                .build();
    }

    public List<ScoreHistoryDto> getScoreHistory(User user) {
        return attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId())
                .stream()
                .filter(a -> a.getCompletedAt() != null && a.getTotalCorrect() != null)
                .map(a -> {
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
                })
                .collect(Collectors.toList());
    }

    public List<PartAccuracyDto> getPartAccuracy(User user) {
        // Get all user answers for this user
        List<TestAttempt> attempts = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId());

        Map<Integer, int[]> partStats = new LinkedHashMap<>();
        // Initialize all parts 1-7
        for (int i = 1; i <= 7; i++) {
            partStats.put(i, new int[]{0, 0}); // [totalAnswered, totalCorrect]
        }

        for (TestAttempt attempt : attempts) {
            if (attempt.getCompletedAt() == null) continue;
            List<UserAnswer> answers = userAnswerRepository.findByAttemptId(attempt.getId());
            for (UserAnswer ua : answers) {
                if (ua.getSelectedOption() == null || ua.getSelectedOption().isEmpty()) continue;
                int partNum = getPartNumberForQuestion(ua);
                if (partNum < 1 || partNum > 7) continue;
                int[] stats = partStats.get(partNum);
                stats[0]++; // totalAnswered
                if (Boolean.TRUE.equals(ua.getIsCorrect())) {
                    stats[1]++; // totalCorrect
                }
            }
        }

        String[] partNames = {
                "Photos", "Question-Response", "Conversations",
                "Short Talks", "Incomplete Sentences", "Text Completion", "Reading Passages"
        };

        return partStats.entrySet().stream().map(entry -> {
            int partNum = entry.getKey();
            int[] stats = entry.getValue();
            double accuracy = stats[0] > 0 ? (double) stats[1] / stats[0] * 100 : 0;
            return PartAccuracyDto.builder()
                    .partNumber(partNum)
                    .partName(partNames[partNum - 1])
                    .totalAnswered(stats[0])
                    .totalCorrect(stats[1])
                    .accuracy(Math.round(accuracy * 10.0) / 10.0)
                    .build();
        }).collect(Collectors.toList());
    }

    private int getPartNumberForQuestion(UserAnswer ua) {
        if (ua.getQuestion() == null || ua.getQuestion().getQuestionGroup() == null) return 0;
        return questionGroupRepository.findById(ua.getQuestion().getQuestionGroup().getId())
                .map(qg -> {
                    if (qg.getTestPart() == null) return 0;
                    return testPartRepository.findById(qg.getTestPart().getId())
                            .map(tp -> tp.getPartNumber() != null ? tp.getPartNumber() : 0)
                            .orElse(0);
                }).orElse(0);
    }

    private int calculateStreak(List<TestAttempt> completed) {
        if (completed.isEmpty()) return 0;

        // Collect distinct days with activity
        Set<LocalDate> activeDays = completed.stream()
                .filter(a -> a.getStartedAt() != null)
                .map(a -> a.getStartedAt().toLocalDate())
                .collect(Collectors.toSet());

        LocalDate today = LocalDate.now();
        int streak = 0;
        LocalDate day = today;

        while (activeDays.contains(day)) {
            streak++;
            day = day.minusDays(1);
        }

        // If today not practiced, check yesterday to keep streak if it continues
        if (streak == 0) {
            day = today.minusDays(1);
            while (activeDays.contains(day)) {
                streak++;
                day = day.minusDays(1);
            }
        }

        return streak;
    }
}
