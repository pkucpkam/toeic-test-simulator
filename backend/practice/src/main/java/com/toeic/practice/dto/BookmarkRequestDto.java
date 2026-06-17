package com.toeic.practice.dto;

import lombok.Data;

@Data
public class BookmarkRequestDto {
    private Long questionId;
    private String note;
}
