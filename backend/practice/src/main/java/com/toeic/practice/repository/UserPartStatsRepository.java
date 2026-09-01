package com.toeic.practice.repository;

import com.toeic.practice.entity.UserPartStats;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserPartStatsRepository extends JpaRepository<UserPartStats, Long> {

    Optional<UserPartStats> findByUserIdAndTestIdAndPartNumber(Long userId, Long testId, Integer partNumber);

    List<UserPartStats> findByUserIdAndTestId(Long userId, Long testId);

    List<UserPartStats> findByUserIdAndTestIdOrderByPartNumber(Long userId, Long testId);

    List<UserPartStats> findByUserId(Long userId);

    void deleteByUserId(Long userId);
}
