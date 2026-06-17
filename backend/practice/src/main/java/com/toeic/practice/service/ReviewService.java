package com.toeic.practice.service;

import com.toeic.practice.dto.BookmarkRequestDto;
import com.toeic.practice.dto.IncorrectQuestionDto;
import com.toeic.practice.dto.QuestionDto;
import com.toeic.practice.entity.Question;
import com.toeic.practice.entity.User;
import com.toeic.practice.entity.UserBookmark;
import com.toeic.practice.repository.QuestionRepository;
import com.toeic.practice.repository.UserBookmarkRepository;
import com.toeic.practice.repository.UserIncorrectQuestionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReviewService {

    private final UserBookmarkRepository bookmarkRepository;
    private final UserIncorrectQuestionRepository incorrectQuestionRepository;
    private final QuestionRepository questionRepository;

    @Transactional
    public void toggleBookmark(BookmarkRequestDto request, User user) {
        // Optional: check if it already exists and remove it (toggle), or just add/update
        List<UserBookmark> existingBookmarks = bookmarkRepository.findByUserId(user.getId());
        for (UserBookmark bookmark : existingBookmarks) {
            if (bookmark.getQuestion().getId().equals(request.getQuestionId())) {
                bookmarkRepository.delete(bookmark);
                return; // Toggled off
            }
        }

        Question question = questionRepository.findById(request.getQuestionId())
                .orElseThrow(() -> new IllegalArgumentException("Question not found"));

        UserBookmark bookmark = UserBookmark.builder()
                .user(user)
                .question(question)
                .note(request.getNote())
                .build();
        bookmarkRepository.save(bookmark);
    }

    public List<IncorrectQuestionDto> getIncorrectQuestions(User user) {
        return incorrectQuestionRepository.findByUserId(user.getId()).stream()
                .map(iq -> {
                    Question q = iq.getQuestion();
                    QuestionDto qDto = QuestionDto.builder()
                            .id(q.getId())
                            .questionNumber(q.getQuestionNumber())
                            .questionText(q.getQuestionText())
                            .optionA(q.getOptionA())
                            .optionB(q.getOptionB())
                            .optionC(q.getOptionC())
                            .optionD(q.getOptionD())
                            .correctAnswer(q.getCorrectAnswer())
                            .explanation(q.getExplanation())
                            .build();

                    return IncorrectQuestionDto.builder()
                            .id(iq.getId())
                            .attemptId(iq.getAttempt().getId())
                            .question(qDto)
                            .build();
                })
                .collect(Collectors.toList());
    }
}
