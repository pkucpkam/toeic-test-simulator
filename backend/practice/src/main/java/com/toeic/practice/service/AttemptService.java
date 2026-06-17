package com.toeic.practice.service;

import com.toeic.practice.dto.StartAttemptRequest;
import com.toeic.practice.dto.SubmitAttemptRequest;
import com.toeic.practice.dto.UserAnswerSubmitDto;
import com.toeic.practice.entity.*;
import com.toeic.practice.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AttemptService {

    private final TestAttemptRepository attemptRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final UserIncorrectQuestionRepository incorrectQuestionRepository;
    private final QuestionRepository questionRepository;
    private final TestRepository testRepository;
    private final TestPartRepository testPartRepository;

    @Transactional
    public Long startAttempt(StartAttemptRequest request, User user) {
        Test test = testRepository.findById(request.getTestId())
                .orElseThrow(() -> new IllegalArgumentException("Test not found"));
        TestPart testPart = null;
        if ("PART".equals(request.getAttemptType()) && request.getTestPartId() != null) {
            testPart = testPartRepository.findById(request.getTestPartId())
                    .orElseThrow(() -> new IllegalArgumentException("TestPart not found"));
        }

        TestAttempt attempt = TestAttempt.builder()
                .user(user)
                .attemptType(request.getAttemptType())
                .test(test)
                .testPart(testPart)
                .startedAt(LocalDateTime.now())
                .build();

        attempt = attemptRepository.save(attempt);
        return attempt.getId();
    }

    @Transactional
    public void submitAttempt(Long attemptId, SubmitAttemptRequest request, User user) {
        TestAttempt attempt = attemptRepository.findById(attemptId)
                .orElseThrow(() -> new IllegalArgumentException("Attempt not found"));

        if (!attempt.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Not authorized for this attempt");
        }

        int totalCorrect = 0;
        int totalIncorrect = 0;
        int totalUnanswered = 0;

        List<UserAnswerSubmitDto> answers = request.getAnswers();
        
        for (UserAnswerSubmitDto answerDto : answers) {
            Question question = questionRepository.findById(answerDto.getQuestionId())
                    .orElseThrow(() -> new IllegalArgumentException("Question not found"));

            boolean isCorrect = false;
            if (answerDto.getSelectedOption() == null || answerDto.getSelectedOption().isEmpty()) {
                totalUnanswered++;
            } else {
                isCorrect = answerDto.getSelectedOption().equals(question.getCorrectAnswer());
                if (isCorrect) {
                    totalCorrect++;
                } else {
                    totalIncorrect++;
                    
                    // Save to user_incorrect_questions
                    UserIncorrectQuestion incorrectQuestion = UserIncorrectQuestion.builder()
                            .user(user)
                            .question(question)
                            .attempt(attempt)
                            .build();
                    incorrectQuestionRepository.save(incorrectQuestion);
                }
            }

            UserAnswer userAnswer = UserAnswer.builder()
                    .attempt(attempt)
                    .question(question)
                    .selectedOption(answerDto.getSelectedOption())
                    .isCorrect(isCorrect)
                    .build();
            userAnswerRepository.save(userAnswer);
        }

        attempt.setCompletedAt(LocalDateTime.now());
        attempt.setDurationSeconds(request.getDurationSeconds());
        attempt.setTotalCorrect(totalCorrect);
        attempt.setTotalIncorrect(totalIncorrect);
        attempt.setTotalUnanswered(totalUnanswered);
        
        // Simple score calculation for now as per user request
        attempt.setTotalScore(totalCorrect); 
        // Can be separated into listening/reading scores later

        attemptRepository.save(attempt);
    }
}
