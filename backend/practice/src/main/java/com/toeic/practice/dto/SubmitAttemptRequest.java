package com.toeic.practice.dto;

import lombok.Data;

import java.util.List;

@Data
public class SubmitAttemptRequest {
    private Integer durationSeconds;
    private List<UserAnswerSubmitDto> answers;
}
