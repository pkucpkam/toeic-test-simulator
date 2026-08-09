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

    @GetMapping("/{attemptId}/result")
    public ResponseEntity<AttemptResultDto> getAttemptResult(
            @PathVariable Long attemptId,
            @AuthenticationPrincipal User user) {
        return ResponseEntity.ok(attemptService.getAttemptResult(attemptId, user));
    }
}
