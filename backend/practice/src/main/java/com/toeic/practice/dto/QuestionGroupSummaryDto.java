package com.toeic.practice.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class QuestionGroupSummaryDto {
    private Long groupId;
    private Integer groupIndex;       // 1, 2, 3, ... (order within part)
    private Integer questionCount;    // number of questions in this group
    private Integer firstQuestionNumber;
    private Integer lastQuestionNumber;
    private String type;              // "audio_group", "passage", "picture", "single"
    private Boolean hasAudio;
    private Boolean hasImage;
    private Boolean hasPassage;
}
