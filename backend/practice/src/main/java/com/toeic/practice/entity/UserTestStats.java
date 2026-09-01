package com.toeic.practice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Pre-computed stats per user per test.
 * Updated incrementally on each attempt submit.
 */
@Entity
@Table(name = "user_test_stats",
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "test_id"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserTestStats {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "test_id", nullable = false)
    private Test test;

    @Builder.Default
    @Column(name = "total_attempts")
    private Integer totalAttempts = 0;

    @Builder.Default
    @Column(name = "total_full_attempts")
    private Integer totalFullAttempts = 0;

    @Builder.Default
    @Column(name = "total_part_attempts")
    private Integer totalPartAttempts = 0;

    @Builder.Default
    @Column(name = "average_accuracy")
    private Double averageAccuracy = 0.0;

    @Builder.Default
    @Column(name = "best_accuracy")
    private Double bestAccuracy = 0.0;

    @Column(name = "last_attempt_date")
    private LocalDateTime lastAttemptDate;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void onSave() {
        this.updatedAt = LocalDateTime.now();
    }
}
