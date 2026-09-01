package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class PartDetailDto {
    private Long testId;
    private String testTitle;
    private Integer partNumber;
    private String partName;
    private Integer totalAttempts;
    private Integer totalAnswered;
    private Integer totalCorrect;
    private Double averageAccuracy;
    private Double bestAccuracy;
    // Lịch sử từng lần luyện part đó
    private List<AttemptSummaryDto> attemptHistory;

    @Data
    @Builder
    public static class AttemptSummaryDto {
        private Long attemptId;
        private LocalDateTime date;
        private Integer totalCorrect;
        private Integer totalAnswered;
        private Double accuracy;
        private Integer durationSeconds;
    }
}
