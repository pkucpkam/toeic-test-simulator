package com.toeic.practice.service;

import com.toeic.practice.dto.QuestionDto;
import com.toeic.practice.dto.QuestionGroupDto;
import com.toeic.practice.dto.QuestionGroupSummaryDto;
import com.toeic.practice.dto.TestDto;
import com.toeic.practice.dto.TestPartDto;
import com.toeic.practice.dto.TestPartSummaryDto;
import com.toeic.practice.entity.QuestionGroup;
import com.toeic.practice.repository.QuestionGroupRepository;
import com.toeic.practice.repository.QuestionRepository;
import com.toeic.practice.repository.TestPartRepository;
import com.toeic.practice.repository.TestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Comparator;
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
        List<QuestionGroupDto> groups = questionGroupRepository.findByTestPartId(partId).stream()
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
                            .sorted(Comparator.comparingInt(q -> q.getQuestionNumber() != null ? q.getQuestionNumber() : 0))
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

        groups.sort(Comparator.comparingInt(g -> (g.getQuestions() != null && !g.getQuestions().isEmpty()) 
                ? (g.getQuestions().get(0).getQuestionNumber() != null ? g.getQuestions().get(0).getQuestionNumber() : 0) : 0));

        return groups;
    }

    public List<QuestionGroupSummaryDto> getGroupsSummaryForPart(Long partId) {
        List<QuestionGroup> groups = questionGroupRepository.findByTestPartId(partId);
        List<QuestionGroupSummaryDto> summaries = groups.stream().map(qg -> {
            List<com.toeic.practice.entity.Question> questions = questionRepository.findByQuestionGroupId(qg.getId());
            questions.sort(Comparator.comparingInt(q -> q.getQuestionNumber() != null ? q.getQuestionNumber() : 0));

            int firstQ = questions.isEmpty() ? 0 : (questions.get(0).getQuestionNumber() != null ? questions.get(0).getQuestionNumber() : 0);
            int lastQ = questions.isEmpty() ? 0 : (questions.get(questions.size() - 1).getQuestionNumber() != null ? questions.get(questions.size() - 1).getQuestionNumber() : 0);

            boolean hasAudio = qg.getAudioUrl() != null && !qg.getAudioUrl().isEmpty();
            boolean hasImage = qg.getImageUrl() != null && !qg.getImageUrl().isEmpty();
            boolean hasPassage = qg.getPassageText() != null && !qg.getPassageText().isEmpty();

            String type;
            if (hasPassage) type = "passage";
            else if (hasAudio && hasImage) type = "audio_group";
            else if (hasAudio) type = "audio_group";
            else if (hasImage) type = "picture";
            else type = "single";

            return QuestionGroupSummaryDto.builder()
                    .groupId(qg.getId())
                    .questionCount(questions.size())
                    .firstQuestionNumber(firstQ)
                    .lastQuestionNumber(lastQ)
                    .type(type)
                    .hasAudio(hasAudio)
                    .hasImage(hasImage)
                    .hasPassage(hasPassage)
                    .build();
        }).collect(Collectors.toList());
        
        summaries.sort(Comparator.comparingInt(QuestionGroupSummaryDto::getFirstQuestionNumber));
        
        for (int i = 0; i < summaries.size(); i++) {
            summaries.get(i).setGroupIndex(i + 1);
        }
        
        return summaries;
    }
}
