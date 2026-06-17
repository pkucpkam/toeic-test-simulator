package com.toeic.practice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class QuestionGroupDto {
    private Long id;
    private String audioUrl;
    private String imageUrl;
    private String passageText;
    private String transcript;
    private List<QuestionDto> questions;
}
