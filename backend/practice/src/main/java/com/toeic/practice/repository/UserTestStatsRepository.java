package com.toeic.practice.repository;

import com.toeic.practice.entity.UserTestStats;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserTestStatsRepository extends JpaRepository<UserTestStats, Long> {

    Optional<UserTestStats> findByUserIdAndTestId(Long userId, Long testId);

    List<UserTestStats> findByUserIdOrderByLastAttemptDateDesc(Long userId);

    void deleteByUserId(Long userId);
}
