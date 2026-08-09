package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BookmarkDto {
    private Long id;
    private String note;
    private QuestionDto question;
}
