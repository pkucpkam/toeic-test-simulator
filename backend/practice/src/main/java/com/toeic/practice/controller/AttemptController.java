package com.toeic.practice.controller;

import com.toeic.practice.dto.AttemptResultDto;
import com.toeic.practice.dto.StartAttemptRequest;
import com.toeic.practice.dto.SubmitAttemptRequest;
import com.toeic.practice.entity.User;
import com.toeic.practice.service.AttemptService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/attempts")
@RequiredArgsConstructor
public class AttemptController {

    private final AttemptService attemptService;

    @PostMapping("/start")
    public ResponseEntity<Map<String, Long>> startAttempt(
            @RequestBody StartAttemptRequest request,
            @AuthenticationPrincipal User user) {
        Long attemptId = attemptService.startAttempt(request, user);
        return ResponseEntity.ok(Map.of("id", attemptId));
    }

    @PostMapping("/{attemptId}/submit")
    public ResponseEntity<Void> submitAttempt(
            @PathVariable Long attemptId,
            @RequestBody SubmitAttemptRequest request,
            @AuthenticationPrincipal User user) {
        attemptService.submitAttempt(attemptId, request, user);
        return ResponseEntity.ok().build();
    }

    /**
     * Lazy submit-direct: creates the attempt and saves results in one request.
     * Frontend does NOT need to call /start first.
     * Returns the attemptId and full result so the frontend can display the score immediately.
     */
    @PostMapping("/submit-direct")
    public ResponseEntity<AttemptResultDto> submitAttemptDirect(
            @RequestBody SubmitAttemptRequest request,
            @AuthenticationPrincipal User user) {
        Long attemptId = attemptService.submitAttemptDirect(request, user);
        AttemptResultDto result = attemptService.getAttemptResult(attemptId, user);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{attemptId}/result")
    public ResponseEntity<AttemptResultDto> getAttemptResult(
            @PathVariable Long attemptId,
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(attemptService.getAttemptResult(attemptId, user));
    }
}
