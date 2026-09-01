package com.toeic.practice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Pre-computed stats per user per test per part.
 * Updated incrementally on each attempt submit.
 */
@Entity
@Table(name = "user_part_stats",
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "test_id", "part_number"}))
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserPartStats {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "test_id", nullable = false)
    private Test test;

    @Column(name = "part_number", nullable = false)
    private Integer partNumber;

    /** Total number of practice sessions that touched this part */
    @Builder.Default
    @Column(name = "total_attempts")
    private Integer totalAttempts = 0;

    /** Cumulative answered questions across all sessions */
    @Builder.Default
    @Column(name = "total_answered")
    private Integer totalAnswered = 0;

    /** Cumulative correct answers across all sessions */
    @Builder.Default
    @Column(name = "total_correct")
    private Integer totalCorrect = 0;

    @Builder.Default
    @Column(name = "average_accuracy")
    private Double averageAccuracy = 0.0;

    @Builder.Default
    @Column(name = "best_accuracy")
    private Double bestAccuracy = 0.0;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void onSave() {
        this.updatedAt = LocalDateTime.now();
    }
}
