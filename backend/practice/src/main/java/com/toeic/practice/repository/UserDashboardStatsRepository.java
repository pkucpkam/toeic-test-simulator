package com.toeic.practice.repository;

import com.toeic.practice.entity.UserDashboardStats;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserDashboardStatsRepository extends JpaRepository<UserDashboardStats, Long> {
    Optional<UserDashboardStats> findByUserId(Long userId);
}
