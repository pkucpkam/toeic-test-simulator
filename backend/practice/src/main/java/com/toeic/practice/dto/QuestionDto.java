package com.toeic.practice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class QuestionDto {
    private Long id;
    private Integer questionNumber;
    private String questionText;
    private String optionA;
    private String optionB;
    private String optionC;
    private String optionD;
    // Don't expose correct_answer for test taking unless needed by frontend.
    // For now, let's include it for flexibility, but frontend should hide it.
    private String correctAnswer; 
    private String explanation;
}
