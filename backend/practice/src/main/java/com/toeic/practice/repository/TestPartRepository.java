package com.toeic.practice.repository;

import com.toeic.practice.entity.TestPart;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TestPartRepository extends JpaRepository<TestPart, Long> {
    List<TestPart> findByTestId(Long testId);
    List<TestPart> findByTest_YearAndPartNumber(Integer year, Integer partNumber);
}
