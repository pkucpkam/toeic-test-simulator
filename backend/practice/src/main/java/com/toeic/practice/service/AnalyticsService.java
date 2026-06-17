package com.toeic.practice.service;

import com.toeic.practice.dto.AttemptHistoryDto;
import com.toeic.practice.entity.User;
import com.toeic.practice.repository.TestAttemptRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final TestAttemptRepository attemptRepository;

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
}
