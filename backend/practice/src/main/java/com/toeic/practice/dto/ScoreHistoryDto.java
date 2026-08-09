package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class ScoreHistoryDto {
    private Long attemptId;
    private String testTitle;
    private String attemptType;
    private Integer totalCorrect;
    private Integer totalQuestions;  // correct + incorrect + unanswered
    private Double accuracy;
    private LocalDateTime date;
}
