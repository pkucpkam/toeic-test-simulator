package com.toeic.practice.dto;

import lombok.Data;

@Data
public class StartAttemptRequest {
    private String attemptType; // FULL, PART
    private Long testId;
    private Long testPartId; // nullable if FULL
}
