package com.toeic.practice.repository;

import com.toeic.practice.entity.TestAttempt;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TestAttemptRepository extends JpaRepository<TestAttempt, Long> {
    List<TestAttempt> findByUserIdOrderByStartedAtDesc(Long userId);
    Page<TestAttempt> findByUserIdOrderByStartedAtDesc(Long userId, Pageable pageable);

    // Full test attempts cho 1 đề
    List<TestAttempt> findByUserIdAndTestIdOrderByStartedAtDesc(Long userId, Long testId);

    // Part attempts cho 1 đề (thông qua testPart.test.id)
    @Query("SELECT a FROM TestAttempt a WHERE a.user.id = :userId AND a.testPart.test.id = :testId ORDER BY a.startedAt DESC")
    List<TestAttempt> findByUserIdAndTestPartTestIdOrderByStartedAtDesc(@Param("userId") Long userId, @Param("testId") Long testId);

    // Part attempts cho 1 part cụ thể trong 1 đề
    @Query("SELECT a FROM TestAttempt a WHERE a.user.id = :userId AND a.testPart.test.id = :testId AND a.testPart.partNumber = :partNumber ORDER BY a.startedAt ASC")
    List<TestAttempt> findByUserIdAndTestIdAndPartNumber(@Param("userId") Long userId, @Param("testId") Long testId, @Param("partNumber") Integer partNumber);

    // Tất cả attempts liên quan đến 1 đề (cả full lẫn part) để list đề đã luyện
    @Query("SELECT a FROM TestAttempt a WHERE a.user.id = :userId AND (a.test.id = :testId OR a.testPart.test.id = :testId) ORDER BY a.startedAt DESC")
    List<TestAttempt> findAllByUserIdAndTestIdOrderByStartedAtDesc(@Param("userId") Long userId, @Param("testId") Long testId);
}
