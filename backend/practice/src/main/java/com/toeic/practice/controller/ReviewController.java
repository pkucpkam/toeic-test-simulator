package com.toeic.practice.controller;

import com.toeic.practice.dto.BookmarkDto;
import com.toeic.practice.dto.BookmarkRequestDto;
import com.toeic.practice.dto.IncorrectQuestionDto;
import com.toeic.practice.entity.User;
import com.toeic.practice.service.ReviewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/review")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;

    @PostMapping("/bookmarks")
    public ResponseEntity<Void> toggleBookmark(
            @RequestBody BookmarkRequestDto request,
            @AuthenticationPrincipal User user) {
        reviewService.toggleBookmark(request, user);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/bookmarks")
    public ResponseEntity<com.toeic.practice.dto.PageResponseDto<BookmarkDto>> getBookmarks(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(reviewService.getBookmarks(user, page, size));
    }

    @GetMapping("/incorrect")
    public ResponseEntity<com.toeic.practice.dto.PageResponseDto<IncorrectQuestionDto>> getIncorrectQuestions(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(reviewService.getIncorrectQuestions(user, page, size));
    }
}
