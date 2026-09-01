package com.toeic.practice.controller;

import com.toeic.practice.dto.*;
import com.toeic.practice.entity.User;
import com.toeic.practice.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/analytics")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    // ── Existing endpoints ──────────────────────────────────────────────────────

    @GetMapping("/history")
    public ResponseEntity<PageResponseDto<AttemptHistoryDto>> getHistory(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        return ResponseEntity.ok(analyticsService.getHistory(user, page, size));
    }

    @GetMapping("/stats")
    public ResponseEntity<AnalyticsStatsDto> getStats(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getStats(user));
    }

    @GetMapping("/score-history")
    public ResponseEntity<PageResponseDto<ScoreHistoryDto>> getScoreHistory(
            @AuthenticationPrincipal User user,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return ResponseEntity.ok(analyticsService.getScoreHistory(user, page, size));
    }

    @GetMapping("/part-accuracy")
    public ResponseEntity<List<PartAccuracyDto>> getPartAccuracy(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getPartAccuracy(user));
    }

    // ── New: Per-test & Per-part endpoints ─────────────────────────────────────

    /**
     * Danh sách các đề user đã luyện, kèm thống kê tổng hợp.
     * GET /api/analytics/tests
     */
    @GetMapping("/tests")
    public ResponseEntity<List<AttemptedTestDto>> getAttemptedTests(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getAttemptedTests(user));
    }

    /**
     * Chi tiết analytics cho 1 đề cụ thể: accuracy từng part, lịch sử attempt.
     * GET /api/analytics/by-test/{testId}
     */
    @GetMapping("/by-test/{testId}")
    public ResponseEntity<TestAnalyticsDto> getTestAnalytics(
            @AuthenticationPrincipal User user,
            @PathVariable Long testId) {
        return ResponseEntity.ok(analyticsService.getTestAnalytics(user, testId));
    }

    /**
     * Chi tiết 1 part trong 1 đề: trend theo từng lần luyện.
     * GET /api/analytics/by-test/{testId}/part/{partNumber}
     */
    @GetMapping("/by-test/{testId}/part/{partNumber}")
    public ResponseEntity<PartDetailDto> getPartDetail(
            @AuthenticationPrincipal User user,
            @PathVariable Long testId,
            @PathVariable Integer partNumber) {
        return ResponseEntity.ok(analyticsService.getPartDetail(user, testId, partNumber));
    }
}
