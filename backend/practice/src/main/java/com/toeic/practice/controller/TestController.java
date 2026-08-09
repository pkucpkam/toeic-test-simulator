package com.toeic.practice.controller;

import com.toeic.practice.dto.QuestionGroupDto;
import com.toeic.practice.dto.QuestionGroupSummaryDto;
import com.toeic.practice.dto.TestDto;
import com.toeic.practice.dto.TestPartDto;
import com.toeic.practice.dto.TestPartSummaryDto;
import com.toeic.practice.service.TestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tests")
@RequiredArgsConstructor
public class TestController {

    private final TestService testService;

    @GetMapping("/years")
    public ResponseEntity<List<Integer>> getYears() {
        return ResponseEntity.ok(testService.getAvailableYears());
    }

    @GetMapping
    public ResponseEntity<List<TestDto>> getTests(@RequestParam Integer year) {
        return ResponseEntity.ok(testService.getTestsByYear(year));
    }

    @GetMapping("/{testId}/parts")
    public ResponseEntity<List<TestPartDto>> getTestParts(@PathVariable Long testId) {
        return ResponseEntity.ok(testService.getTestParts(testId));
    }

    @GetMapping("/{testId}")
    public ResponseEntity<TestDto> getTestById(@PathVariable Long testId) {
        return ResponseEntity.ok(testService.getTestById(testId));
    }

    @GetMapping("/parts/summary")
    public ResponseEntity<List<TestPartSummaryDto>> getTestPartsSummary(
            @RequestParam Integer year, 
            @RequestParam Integer partNumber) {
        return ResponseEntity.ok(testService.getTestPartsByYearAndPartNumber(year, partNumber));
    }

    @GetMapping("/parts/{partId}/questions")
    public ResponseEntity<List<QuestionGroupDto>> getQuestionsForPart(@PathVariable Long partId) {
        return ResponseEntity.ok(testService.getQuestionsForPart(partId));
    }

    @GetMapping("/parts/{partId}/groups")
    public ResponseEntity<List<QuestionGroupSummaryDto>> getGroupsSummaryForPart(@PathVariable Long partId) {
        return ResponseEntity.ok(testService.getGroupsSummaryForPart(partId));
    }
}
