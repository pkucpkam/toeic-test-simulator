package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class AttemptHistoryDto {
    private Long id;
    private Long testId;
    private String testTitle;
    private String attemptType;
    private Integer partNumber;
    private Integer totalScore;
    private Integer totalCorrect;
    private Integer totalIncorrect;
    private Integer totalUnanswered;
    private Integer durationSeconds;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
}
