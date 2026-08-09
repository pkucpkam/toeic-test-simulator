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
    public ResponseEntity<List<AttemptHistoryDto>> getHistory(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getHistory(user));
    }

    @GetMapping("/stats")
    public ResponseEntity<AnalyticsStatsDto> getStats(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getStats(user));
    }

    @GetMapping("/score-history")
    public ResponseEntity<List<ScoreHistoryDto>> getScoreHistory(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getScoreHistory(user));
    }

    @GetMapping("/part-accuracy")
    public ResponseEntity<List<PartAccuracyDto>> getPartAccuracy(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(analyticsService.getPartAccuracy(user));
    }
}
