package com.toeic.practice.controller;

import com.toeic.practice.dto.*;
import com.toeic.practice.entity.User;
import com.toeic.practice.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/history")
    public ResponseEntity<PageResponseDto<AttemptHistoryDto>> getHistory(
            @AuthenticationPrincipal User user,
            @org.springframework.web.bind.annotation.RequestParam(defaultValue = "0") int page,
            @org.springframework.web.bind.annotation.RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(analyticsService.getHistory(user, page, size));
    }

    @GetMapping("/stats")
    public ResponseEntity<AnalyticsStatsDto> getStats(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getStats(user));
    }

    @GetMapping("/score-history")
    public ResponseEntity<PageResponseDto<ScoreHistoryDto>> getScoreHistory(
            @AuthenticationPrincipal User user,
            @org.springframework.web.bind.annotation.RequestParam(defaultValue = "0") int page,
            @org.springframework.web.bind.annotation.RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(analyticsService.getScoreHistory(user, page, size));
    }

    @GetMapping("/part-accuracy")
    public ResponseEntity<List<PartAccuracyDto>> getPartAccuracy(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getPartAccuracy(user));
    }
}
