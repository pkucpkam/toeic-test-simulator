package com.toeic.practice.service;

import com.toeic.practice.entity.*;
import com.toeic.practice.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserDashboardStatsService {

    private final UserDashboardStatsRepository statsRepository;
    private final TestAttemptRepository attemptRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final QuestionGroupRepository questionGroupRepository;
    private final TestPartRepository testPartRepository;

    @Transactional
    public UserDashboardStats getOrCalculateStats(User user) {
        return statsRepository.findByUserId(user.getId())
                .orElseGet(() -> recalculateStats(user));
    }

    @Transactional
    public UserDashboardStats recalculateStats(User user) {
        List<TestAttempt> attempts = attemptRepository.findByUserIdOrderByStartedAtDesc(user.getId());

        int totalAttempts = attempts.size();
        int totalFull = (int) attempts.stream().filter(a -> "FULL".equals(a.getAttemptType())).count();
        int totalPart = (int) attempts.stream().filter(a -> "PART".equals(a.getAttemptType())).count();

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

        int streak = calculateStreak(completed);

        LocalDate lastDate = completed.stream()
                .filter(a -> a.getStartedAt() != null)
                .map(a -> a.getStartedAt().toLocalDate())
                .max(LocalDate::compareTo)
                .orElse(null);

        // Per-part stats calculation
        int[] totals = new int[8];
        int[] corrects = new int[8];

        for (TestAttempt attempt : completed) {
            List<UserAnswer> answers = userAnswerRepository.findByAttemptId(attempt.getId());
            for (UserAnswer ua : answers) {
                if (ua.getSelectedOption() == null || ua.getSelectedOption().isEmpty()) continue;
                int partNum = getPartNumberForQuestion(ua.getQuestion());
                if (partNum >= 1 && partNum <= 7) {
                    totals[partNum]++;
                    if (Boolean.TRUE.equals(ua.getIsCorrect())) {
                        corrects[partNum]++;
                    }
                }
            }
        }

        UserDashboardStats stats = statsRepository.findByUserId(user.getId())
                .orElseGet(() -> UserDashboardStats.builder().user(user).build());

        stats.setTotalAttempts(totalAttempts);
        stats.setTotalFullTests(totalFull);
        stats.setTotalPartPractices(totalPart);
        stats.setAverageScore(Math.round(avgScore * 10.0) / 10.0);
        stats.setAverageAccuracy(Math.round(avgAccuracy * 10.0) / 10.0);
        stats.setBestScore(bestScore);
        stats.setCurrentStreak(streak);
        stats.setLastPracticeDate(lastDate);

        stats.setP1Total(totals[1]); stats.setP1Correct(corrects[1]);
        stats.setP2Total(totals[2]); stats.setP2Correct(corrects[2]);
        stats.setP3Total(totals[3]); stats.setP3Correct(corrects[3]);
        stats.setP4Total(totals[4]); stats.setP4Correct(corrects[4]);
        stats.setP5Total(totals[5]); stats.setP5Correct(corrects[5]);
        stats.setP6Total(totals[6]); stats.setP6Correct(corrects[6]);
        stats.setP7Total(totals[7]); stats.setP7Correct(corrects[7]);

        return statsRepository.save(stats);
    }

    private int getPartNumberForQuestion(Question question) {
        if (question == null || question.getQuestionGroup() == null) return 0;
        return questionGroupRepository.findById(question.getQuestionGroup().getId())
                .map(qg -> {
                    if (qg.getTestPart() == null) return 0;
                    return testPartRepository.findById(qg.getTestPart().getId())
                            .map(tp -> tp.getPartNumber() != null ? tp.getPartNumber() : 0)
                            .orElse(0);
                }).orElse(0);
    }

    private int calculateStreak(List<TestAttempt> completed) {
        if (completed.isEmpty()) return 0;
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
