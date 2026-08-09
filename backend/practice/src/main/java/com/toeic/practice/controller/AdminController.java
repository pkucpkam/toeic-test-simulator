package com.toeic.practice.controller;

import com.toeic.practice.dto.QuestionDto;
import com.toeic.practice.dto.QuestionGroupDto;
import com.toeic.practice.dto.TestDto;
import com.toeic.practice.dto.TestPartDto;
import com.toeic.practice.service.AdminService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @PutMapping("/tests/{id}")
    public ResponseEntity<TestDto> updateTest(@PathVariable Long id, @RequestBody TestDto dto) {
        return ResponseEntity.ok(adminService.updateTest(id, dto));
    }

    @PutMapping("/parts/{id}")
    public ResponseEntity<TestPartDto> updateTestPart(@PathVariable Long id, @RequestBody TestPartDto dto) {
        return ResponseEntity.ok(adminService.updateTestPart(id, dto));
    }

    @PutMapping("/groups/{id}")
    public ResponseEntity<QuestionGroupDto> updateQuestionGroup(@PathVariable Long id, @RequestBody QuestionGroupDto dto) {
        return ResponseEntity.ok(adminService.updateQuestionGroup(id, dto));
    }

    @PutMapping("/questions/{id}")
    public ResponseEntity<QuestionDto> updateQuestion(@PathVariable Long id, @RequestBody QuestionDto dto) {
        return ResponseEntity.ok(adminService.updateQuestion(id, dto));
    }
}
