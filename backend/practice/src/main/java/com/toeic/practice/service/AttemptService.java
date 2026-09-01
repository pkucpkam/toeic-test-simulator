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
import java.util.*;
import java.util.function.Function;
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

        List<UserAnswerSubmitDto> answerDtos = request.getAnswers();
        ProcessedAnswers processed = processAnswers(answerDtos, attempt, user);

        attempt.setCompletedAt(LocalDateTime.now());
        attempt.setDurationSeconds(request.getDurationSeconds());
        attempt.setTotalCorrect(processed.totalCorrect);
        attempt.setTotalIncorrect(processed.totalIncorrect);
        attempt.setTotalUnanswered(processed.totalUnanswered);
        attempt.setListeningScore(processed.listeningCorrect);
        attempt.setReadingScore(processed.readingCorrect);
        attempt.setTotalScore(processed.totalCorrect);

        attemptRepository.save(attempt);

        // Incremental stats update (replaces the slow recalculateStats call)
        userDashboardStatsService.updateStatsForAttempt(user, attempt, processed.savedAnswers, processed.questionPartMap);
        userTestStatsService.updateStatsForAttempt(user, attempt, processed.savedAnswers);
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

        List<UserAnswerSubmitDto> answerDtos = request.getAnswers() != null ? request.getAnswers() : Collections.emptyList();
        ProcessedAnswers processed = processAnswers(answerDtos, attempt, user);

        attempt.setCompletedAt(LocalDateTime.now());
        attempt.setDurationSeconds(request.getDurationSeconds());
        attempt.setTotalCorrect(processed.totalCorrect);
        attempt.setTotalIncorrect(processed.totalIncorrect);
        attempt.setTotalUnanswered(processed.totalUnanswered);
        attempt.setListeningScore(processed.listeningCorrect);
        attempt.setReadingScore(processed.readingCorrect);
        attempt.setTotalScore(processed.totalCorrect);

        attemptRepository.save(attempt);

        // Incremental stats update (replaces the slow recalculateStats call)
        userDashboardStatsService.updateStatsForAttempt(user, attempt, processed.savedAnswers, processed.questionPartMap);
        userTestStatsService.updateStatsForAttempt(user, attempt, processed.savedAnswers);

        return attempt.getId();
    }

    /**
     * Returns detailed result for an attempt including per-question breakdown.
     * Uses JOIN FETCH to avoid N+1 queries when reading partNumber for each question.
     */
    public AttemptResultDto getAttemptResult(Long attemptId, User user) {
        TestAttempt attempt = attemptRepository.findById(attemptId)
                .orElseThrow(() -> new IllegalArgumentException("Attempt not found"));

        if (!attempt.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Not authorized for this attempt");
        }

        // Single JOIN FETCH query - no N+1 for questionGroup / testPart
        List<UserAnswer> userAnswers = userAnswerRepository.findByAttemptIdWithDetails(attemptId);

        List<AttemptResultDto.QuestionResultDto> questionResults = userAnswers.stream()
                .map(ua -> {
                    Question q = ua.getQuestion();
                    // partNumber is already loaded via JOIN FETCH - no extra SQL
                    int partNum = 0;
                    if (q != null && q.getQuestionGroup() != null && q.getQuestionGroup().getTestPart() != null) {
                        Integer pn = q.getQuestionGroup().getTestPart().getPartNumber();
                        partNum = pn != null ? pn : 0;
                    }
                    return AttemptResultDto.QuestionResultDto.builder()
                            .questionId(q != null ? q.getId() : null)
                            .questionNumber(q != null ? q.getQuestionNumber() : null)
                            .questionText(q != null ? q.getQuestionText() : null)
                            .optionA(q != null ? q.getOptionA() : null)
                            .optionB(q != null ? q.getOptionB() : null)
                            .optionC(q != null ? q.getOptionC() : null)
                            .optionD(q != null ? q.getOptionD() : null)
                            .correctAnswer(q != null ? q.getCorrectAnswer() : null)
                            .selectedOption(ua.getSelectedOption())
                            .isCorrect(ua.getIsCorrect())
                            .explanation(q != null ? q.getExplanation() : null)
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

    // -------------------------------------------------------------------------
    // Private helpers
    // -------------------------------------------------------------------------

    /**
     * Shared answer-processing logic for both submitAttempt and submitAttemptDirect.
     * <p>
     * Optimisations applied here (vs the old per-question loop):
     * <ol>
     *   <li>Batch-fetch all Question entities in a single findAllById call.</li>
     *   <li>Batch-fetch all questionId→partNumber mappings in one native SQL query.</li>
     *   <li>Collect UserAnswer and UserIncorrectQuestion lists, then persist with saveAll()
     *       so Hibernate can use JDBC batch inserts.</li>
     * </ol>
     */
    private ProcessedAnswers processAnswers(List<UserAnswerSubmitDto> answerDtos,
                                            TestAttempt attempt,
                                            User user) {
        if (answerDtos == null || answerDtos.isEmpty()) {
            return new ProcessedAnswers(0, 0, 0, 0, 0,
                    Collections.emptyList(), Collections.emptyMap());
        }

        // 1. Batch-fetch all questions in one query
        List<Long> questionIds = answerDtos.stream()
                .map(UserAnswerSubmitDto::getQuestionId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());

        Map<Long, Question> questionMap = questionRepository.findAllById(questionIds).stream()
                .collect(Collectors.toMap(Question::getId, Function.identity()));

        // 2. Batch-fetch partNumber mapping (questionId -> partNumber) in one SQL
        Map<Long, Integer> questionPartMap = questionRepository.buildQuestionPartMap(questionIds);

        int totalCorrect = 0;
        int totalIncorrect = 0;
        int totalUnanswered = 0;
        int listeningCorrect = 0;
        int readingCorrect = 0;

        List<UserAnswer> userAnswers = new ArrayList<>();
        List<UserIncorrectQuestion> incorrectQuestions = new ArrayList<>();

        for (UserAnswerSubmitDto dto : answerDtos) {
            Question question = questionMap.get(dto.getQuestionId());
            if (question == null) continue; // skip unknown question ids gracefully

            boolean isCorrect = false;

            if (dto.getSelectedOption() == null || dto.getSelectedOption().isEmpty()) {
                totalUnanswered++;
            } else {
                isCorrect = dto.getSelectedOption().equals(question.getCorrectAnswer());
                if (isCorrect) {
                    totalCorrect++;
                    int partNumber = questionPartMap.getOrDefault(question.getId(), 0);
                    if (partNumber >= 1 && partNumber <= 4) {
                        listeningCorrect++;
                    } else {
                        readingCorrect++;
                    }
                } else {
                    totalIncorrect++;
                    incorrectQuestions.add(UserIncorrectQuestion.builder()
                            .user(user)
                            .question(question)
                            .attempt(attempt)
                            .build());
                }
            }

            userAnswers.add(UserAnswer.builder()
                    .attempt(attempt)
                    .question(question)
                    .selectedOption(dto.getSelectedOption())
                    .isCorrect(isCorrect)
                    .build());
        }

        // 3. Batch insert - saveAll allows Hibernate to use JDBC batch statements
        List<UserAnswer> savedAnswers = userAnswerRepository.saveAll(userAnswers);
        incorrectQuestionRepository.saveAll(incorrectQuestions);

        return new ProcessedAnswers(totalCorrect, totalIncorrect, totalUnanswered,
                listeningCorrect, readingCorrect, savedAnswers, questionPartMap);
    }

    /** Simple value object returned by processAnswers(). */
    private static class ProcessedAnswers {
        final int totalCorrect;
        final int totalIncorrect;
        final int totalUnanswered;
        final int listeningCorrect;
        final int readingCorrect;
        final List<UserAnswer> savedAnswers;
        final Map<Long, Integer> questionPartMap;

        ProcessedAnswers(int totalCorrect, int totalIncorrect, int totalUnanswered,
                         int listeningCorrect, int readingCorrect,
                         List<UserAnswer> savedAnswers, Map<Long, Integer> questionPartMap) {
            this.totalCorrect = totalCorrect;
            this.totalIncorrect = totalIncorrect;
            this.totalUnanswered = totalUnanswered;
            this.listeningCorrect = listeningCorrect;
            this.readingCorrect = readingCorrect;
            this.savedAnswers = savedAnswers;
            this.questionPartMap = questionPartMap;
        }
    }
}
