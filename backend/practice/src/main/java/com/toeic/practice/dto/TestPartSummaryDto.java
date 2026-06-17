package com.toeic.practice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TestPartSummaryDto {
    private Long testId;
    private String testTitle;
    private Long partId;
}
