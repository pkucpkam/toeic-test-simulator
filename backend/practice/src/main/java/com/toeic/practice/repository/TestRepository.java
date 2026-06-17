package com.toeic.practice.repository;

import com.toeic.practice.entity.Test;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TestRepository extends JpaRepository<Test, Long> {
    List<Test> findByYear(Integer year);

    @Query("SELECT DISTINCT t.year FROM Test t ORDER BY t.year DESC")
    List<Integer> findDistinctYears();
}
