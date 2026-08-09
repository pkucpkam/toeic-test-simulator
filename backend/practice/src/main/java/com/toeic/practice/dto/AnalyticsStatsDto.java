package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AnalyticsStatsDto {
    private Integer totalAttempts;
    private Integer totalFullTests;
    private Integer totalPartPractices;
    private Double averageScore;          // average totalCorrect
    private Double averageAccuracy;       // correct / (correct + incorrect) %
    private Integer bestScore;
    private Integer currentStreak;        // consecutive days practiced
}
