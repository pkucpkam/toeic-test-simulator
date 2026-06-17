package com.toeic.practice.dto;

import lombok.Data;

@Data
public class UserAnswerSubmitDto {
    private Long questionId;
    private String selectedOption;
}
