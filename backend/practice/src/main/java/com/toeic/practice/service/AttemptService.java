package com.toeic.practice.service;

import com.toeic.practice.dto.AttemptResultDto;
import com.toeic.practice.dto.StartAttemptRequest;
import com.toeic.practice.dto.SubmitAttemptRequest;
import com.toeic.practice.dto.UserAnswerSubmitDto;
import com.toeic.practice.entity.*;
import com.toeic.practice.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AttemptService {

    private final TestAttemptRepository attemptRepository;
    private final UserAnswerRepository userAnswerRepository;
    private final UserIncorrectQuestionRepository incorrectQuestionRepository;
    private final QuestionRepository questionRepository;
    private final TestRepository testRepository;
    private final TestPartRepository testPartRepository;
    private final QuestionGroupRepository questionGroupRepository;
    private final UserDashboardStatsService userDashboardStatsService;
    private final UserTestStatsService userTestStatsService;

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
        int listeningCorrect = 0;
        int readingCorrect = 0;
        List<UserAnswer> savedAnswers = new ArrayList<>();

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
                    // Determine if this question belongs to Listening (Part 1-4) or Reading (Part 5-7)
                    int partNumber = getPartNumberForQuestion(question);
                    if (partNumber >= 1 && partNumber <= 4) {
                        listeningCorrect++;
                    } else {
                        readingCorrect++;
                    }
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
            savedAnswers.add(userAnswer);
        }

        attempt.setCompletedAt(LocalDateTime.now());
        attempt.setDurationSeconds(request.getDurationSeconds());
        attempt.setTotalCorrect(totalCorrect);
        attempt.setTotalIncorrect(totalIncorrect);
        attempt.setTotalUnanswered(totalUnanswered);
        attempt.setListeningScore(listeningCorrect);
        attempt.setReadingScore(readingCorrect);
        attempt.setTotalScore(totalCorrect);

        attemptRepository.save(attempt);

        // Update pre-calculated stats (overall + per-test/part cache)
        userDashboardStatsService.recalculateStats(user);
        userTestStatsService.updateStatsForAttempt(user, attempt, savedAnswers);
    }

    /**
     * Lazy / direct submit: creates the TestAttempt and saves all answers in one transaction.
     * Used when the frontend does NOT call /attempts/start first (lazy start flow).
     *
     * @return the saved attempt id
     */
    @Transactional
    public Long submitAttemptDirect(SubmitAttemptRequest request, User user) {
        if (request.getTestId() == null) {
            throw new IllegalArgumentException("testId is required for submit-direct");
        }

        Test test = testRepository.findById(request.getTestId())
                .orElseThrow(() -> new IllegalArgumentException("Test not found"));

        TestPart testPart = null;
        if ("PART".equals(request.getAttemptType()) && request.getTestPartId() != null) {
            testPart = testPartRepository.findById(request.getTestPartId())
                    .orElseThrow(() -> new IllegalArgumentException("TestPart not found"));
        }

        // Create the attempt record now (at submit time)
        TestAttempt attempt = TestAttempt.builder()
                .user(user)
                .attemptType(request.getAttemptType() != null ? request.getAttemptType() : "FULL")
                .test(test)
                .testPart(testPart)
                .startedAt(java.time.LocalDateTime.now()
                        .minusSeconds(request.getDurationSeconds() != null ? request.getDurationSeconds() : 0))
                .build();

        attempt = attemptRepository.save(attempt);

        // Process answers inline (same logic as submitAttempt, no self-invocation)
        int totalCorrect = 0;
        int totalIncorrect = 0;
        int totalUnanswered = 0;
        int listeningCorrect = 0;
        int readingCorrect = 0;
        List<UserAnswer> savedAnswers = new ArrayList<>();

        List<UserAnswerSubmitDto> answers = request.getAnswers();
        if (answers != null) {
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
                        int partNumber = getPartNumberForQuestion(question);
                        if (partNumber >= 1 && partNumber <= 4) {
                            listeningCorrect++;
                        } else {
                            readingCorrect++;
                        }
                    } else {
                        totalIncorrect++;
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
                savedAnswers.add(userAnswer);
            }
        }

        attempt.setCompletedAt(LocalDateTime.now());
        attempt.setDurationSeconds(request.getDurationSeconds());
        attempt.setTotalCorrect(totalCorrect);
        attempt.setTotalIncorrect(totalIncorrect);
        attempt.setTotalUnanswered(totalUnanswered);
        attempt.setListeningScore(listeningCorrect);
        attempt.setReadingScore(readingCorrect);
        attempt.setTotalScore(totalCorrect);

        attemptRepository.save(attempt);

        // Update pre-calculated stats (overall + per-test/part cache)
        userDashboardStatsService.recalculateStats(user);
        userTestStatsService.updateStatsForAttempt(user, attempt, savedAnswers);

        return attempt.getId();
    }

    /**
     * Returns detailed result for an attempt including per-question breakdown.
     */
    public AttemptResultDto getAttemptResult(Long attemptId, User user) {
        TestAttempt attempt = attemptRepository.findById(attemptId)
                .orElseThrow(() -> new IllegalArgumentException("Attempt not found"));

        if (!attempt.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Not authorized for this attempt");
        }

        List<UserAnswer> userAnswers = userAnswerRepository.findByAttemptId(attemptId);

        List<AttemptResultDto.QuestionResultDto> questionResults = userAnswers.stream()
                .map(ua -> {
                    Question q = ua.getQuestion();
                    int partNum = getPartNumberForQuestion(q);
                    return AttemptResultDto.QuestionResultDto.builder()
                            .questionId(q.getId())
                            .questionNumber(q.getQuestionNumber())
                            .questionText(q.getQuestionText())
                            .optionA(q.getOptionA())
                            .optionB(q.getOptionB())
                            .optionC(q.getOptionC())
                            .optionD(q.getOptionD())
                            .correctAnswer(q.getCorrectAnswer())
                            .selectedOption(ua.getSelectedOption())
                            .isCorrect(ua.getIsCorrect())
                            .explanation(q.getExplanation())
                            .partNumber(partNum)
                            .partTitle("Part " + partNum)
                            .build();
                })
                .sorted((a, b) -> {
                    int partComp = Integer.compare(
                            a.getPartNumber() != null ? a.getPartNumber() : 0,
                            b.getPartNumber() != null ? b.getPartNumber() : 0);
                    if (partComp != 0) return partComp;
                    return Integer.compare(
                            a.getQuestionNumber() != null ? a.getQuestionNumber() : 0,
                            b.getQuestionNumber() != null ? b.getQuestionNumber() : 0);
                })
                .collect(Collectors.toList());

        return AttemptResultDto.builder()
                .attemptId(attempt.getId())
                .testTitle(attempt.getTest() != null ? attempt.getTest().getTitle() : "Unknown")
                .attemptType(attempt.getAttemptType())
                .listeningScore(attempt.getListeningScore())
                .readingScore(attempt.getReadingScore())
                .totalScore(attempt.getTotalScore())
                .totalCorrect(attempt.getTotalCorrect())
                .totalIncorrect(attempt.getTotalIncorrect())
                .totalUnanswered(attempt.getTotalUnanswered())
                .durationSeconds(attempt.getDurationSeconds())
                .startedAt(attempt.getStartedAt())
                .completedAt(attempt.getCompletedAt())
                .questionResults(questionResults)
                .build();
    }

    /**
     * Determines the part number (1-7) for a given question via its QuestionGroup -> TestPart.
     */
    private int getPartNumberForQuestion(Question question) {
        if (question.getQuestionGroup() == null) return 0;
        QuestionGroup qg = questionGroupRepository.findById(question.getQuestionGroup().getId()).orElse(null);
        if (qg == null || qg.getTestPart() == null) return 0;
        TestPart part = testPartRepository.findById(qg.getTestPart().getId()).orElse(null);
        if (part == null) return 0;
        return part.getPartNumber() != null ? part.getPartNumber() : 0;
    }
}
