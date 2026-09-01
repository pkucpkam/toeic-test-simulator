package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class AttemptedTestDto {
    private Long testId;
    private String testTitle;
    private Integer totalAttempts;
    private Double averageAccuracy;
    private Double bestAccuracy;
    private LocalDateTime lastAttemptDate;
}
