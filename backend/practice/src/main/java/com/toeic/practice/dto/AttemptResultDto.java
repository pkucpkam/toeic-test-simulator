package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
public class AttemptResultDto {
    private Long attemptId;
    private String testTitle;
    private String attemptType;
    private Integer listeningScore;
    private Integer readingScore;
    private Integer totalScore;
    private Integer totalCorrect;
    private Integer totalIncorrect;
    private Integer totalUnanswered;
    private Integer durationSeconds;
    private LocalDateTime startedAt;
    private LocalDateTime completedAt;
    private List<QuestionResultDto> questionResults;

    @Data
    @Builder
    public static class QuestionResultDto {
        private Long questionId;
        private Integer questionNumber;
        private String questionText;
        private String optionA;
        private String optionB;
        private String optionC;
        private String optionD;
        private String correctAnswer;
        private String selectedOption;
        private Boolean isCorrect;
        private String explanation;
        private String partTitle; // "Part 1", "Part 2", ...
        private Integer partNumber;
    }
}
