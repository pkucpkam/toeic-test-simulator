package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class IncorrectQuestionDto {
    private Long id;
    private Long attemptId;
    private QuestionDto question;
}
