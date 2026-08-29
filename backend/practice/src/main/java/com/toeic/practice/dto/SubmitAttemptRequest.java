package com.toeic.practice.dto;

import lombok.Data;

import java.util.List;

@Data
public class SubmitAttemptRequest {
    private Integer durationSeconds;
    private List<UserAnswerSubmitDto> answers;

    // Fields used by the lazy (submit-direct) flow.
    // Optional — only required when creating the attempt on-the-fly during submit.
    private Long testId;
    private String attemptType; // "FULL" or "PART"
    private Long testPartId;    // nullable if FULL
}
