package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PartAccuracyDto {
    private Integer partNumber;
    private String partName;    // "Photos", "Question-Response", etc.
    private Integer totalAnswered;
    private Integer totalCorrect;
    private Double accuracy;    // percentage
}
