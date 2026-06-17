package com.toeic.practice.service;

import com.toeic.practice.dto.QuestionDto;
import com.toeic.practice.dto.QuestionGroupDto;
import com.toeic.practice.dto.TestDto;
import com.toeic.practice.dto.TestPartDto;
import com.toeic.practice.dto.TestPartSummaryDto;
import com.toeic.practice.repository.QuestionGroupRepository;
import com.toeic.practice.repository.QuestionRepository;
import com.toeic.practice.repository.TestPartRepository;
import com.toeic.practice.repository.TestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TestService {

    private final TestRepository testRepository;
    private final TestPartRepository testPartRepository;
    private final QuestionGroupRepository questionGroupRepository;
    private final QuestionRepository questionRepository;

    public List<Integer> getAvailableYears() {
        return testRepository.findDistinctYears();
    }

    public List<TestDto> getTestsByYear(Integer year) {
        return testRepository.findByYear(year).stream()
                .map(t -> TestDto.builder()
                        .id(t.getId())
                        .title(t.getTitle())
                        .year(t.getYear())
                        .fullAudioUrl(t.getFullAudioUrl())
                        .build())
                .collect(Collectors.toList());
    }

    public TestDto getTestById(Long testId) {
        return testRepository.findById(testId)
                .map(t -> TestDto.builder()
                        .id(t.getId())
                        .title(t.getTitle())
                        .year(t.getYear())
                        .fullAudioUrl(t.getFullAudioUrl())
                        .build())
                .orElseThrow(() -> new RuntimeException("Test not found"));
    }

    public List<TestPartDto> getTestParts(Long testId) {
        return testPartRepository.findByTestId(testId).stream()
                .map(tp -> TestPartDto.builder()
                        .id(tp.getId())
                        .testId(tp.getTest().getId())
                        .partNumber(tp.getPartNumber())
                        .name(tp.getName())
                        .build())
                .collect(Collectors.toList());
    }

    public List<TestPartSummaryDto> getTestPartsByYearAndPartNumber(Integer year, Integer partNumber) {
        return testPartRepository.findByTest_YearAndPartNumber(year, partNumber).stream()
                .map(tp -> TestPartSummaryDto.builder()
                        .testId(tp.getTest().getId())
                        .testTitle(tp.getTest().getTitle())
                        .partId(tp.getId())
                        .build())
                .collect(Collectors.toList());
    }

    public List<QuestionGroupDto> getQuestionsForPart(Long partId) {
        return questionGroupRepository.findByTestPartId(partId).stream()
                .map(qg -> {
                    List<QuestionDto> questions = questionRepository.findByQuestionGroupId(qg.getId()).stream()
                            .map(q -> QuestionDto.builder()
                                    .id(q.getId())
                                    .questionNumber(q.getQuestionNumber())
                                    .questionText(q.getQuestionText())
                                    .optionA(q.getOptionA())
                                    .optionB(q.getOptionB())
                                    .optionC(q.getOptionC())
                                    .optionD(q.getOptionD())
                                    .correctAnswer(q.getCorrectAnswer())
                                    .explanation(q.getExplanation())
                                    .build())
                            .collect(Collectors.toList());

                    return QuestionGroupDto.builder()
                            .id(qg.getId())
                            .audioUrl(qg.getAudioUrl())
                            .imageUrl(qg.getImageUrl())
                            .passageText(qg.getPassageText())
                            .transcript(qg.getTranscript())
                            .questions(questions)
                            .build();
                })
                .collect(Collectors.toList());
    }
}
