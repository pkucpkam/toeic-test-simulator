package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class TestAnalyticsDto {
    private Long testId;
    private String testTitle;
    private Integer totalAttempts;
    private Integer totalFullAttempts;
    private Integer totalPartAttempts;
    private Double averageAccuracy;
    private Double bestAccuracy;
    private LocalDateTime lastAttemptDate;
    // Per-part breakdown cho đề này
    private List<PartAccuracyDto> partStats;
}
