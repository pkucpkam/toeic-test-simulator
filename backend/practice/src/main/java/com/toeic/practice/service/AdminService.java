package com.toeic.practice.service;

import com.toeic.practice.dto.QuestionDto;
import com.toeic.practice.dto.QuestionGroupDto;
import com.toeic.practice.dto.TestDto;
import com.toeic.practice.dto.TestPartDto;
import com.toeic.practice.entity.Question;
import com.toeic.practice.entity.QuestionGroup;
import com.toeic.practice.entity.Test;
import com.toeic.practice.entity.TestPart;
import com.toeic.practice.repository.QuestionGroupRepository;
import com.toeic.practice.repository.QuestionRepository;
import com.toeic.practice.repository.TestPartRepository;
import com.toeic.practice.repository.TestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final TestRepository testRepository;
    private final TestPartRepository testPartRepository;
    private final QuestionGroupRepository questionGroupRepository;
    private final QuestionRepository questionRepository;

    @Transactional
    public TestDto updateTest(Long id, TestDto dto) {
        Test test = testRepository.findById(id).orElseThrow(() -> new RuntimeException("Test not found"));
        if (dto.getTitle() != null) test.setTitle(dto.getTitle());
        if (dto.getYear() != null) test.setYear(dto.getYear());
        if (dto.getFullAudioUrl() != null) test.setFullAudioUrl(dto.getFullAudioUrl());
        testRepository.save(test);
        return dto;
    }

    @Transactional
    public TestPartDto updateTestPart(Long id, TestPartDto dto) {
        TestPart part = testPartRepository.findById(id).orElseThrow(() -> new RuntimeException("TestPart not found"));
        if (dto.getName() != null) part.setName(dto.getName());
        testPartRepository.save(part);
        return dto;
    }

    @Transactional
    public QuestionGroupDto updateQuestionGroup(Long id, QuestionGroupDto dto) {
        QuestionGroup group = questionGroupRepository.findById(id).orElseThrow(() -> new RuntimeException("QuestionGroup not found"));
        if (dto.getAudioUrl() != null) group.setAudioUrl(dto.getAudioUrl());
        if (dto.getImageUrl() != null) group.setImageUrl(dto.getImageUrl());
        if (dto.getPassageText() != null) group.setPassageText(dto.getPassageText());
        if (dto.getTranscript() != null) group.setTranscript(dto.getTranscript());
        questionGroupRepository.save(group);
        return dto;
    }

    @Transactional
    public QuestionDto updateQuestion(Long id, QuestionDto dto) {
        Question question = questionRepository.findById(id).orElseThrow(() -> new RuntimeException("Question not found"));
        if (dto.getQuestionText() != null) question.setQuestionText(dto.getQuestionText());
        if (dto.getOptionA() != null) question.setOptionA(dto.getOptionA());
        if (dto.getOptionB() != null) question.setOptionB(dto.getOptionB());
        if (dto.getOptionC() != null) question.setOptionC(dto.getOptionC());
        if (dto.getOptionD() != null) question.setOptionD(dto.getOptionD());
        if (dto.getCorrectAnswer() != null) question.setCorrectAnswer(dto.getCorrectAnswer());
        if (dto.getExplanation() != null) question.setExplanation(dto.getExplanation());
        questionRepository.save(question);
        return dto;
    }
}
