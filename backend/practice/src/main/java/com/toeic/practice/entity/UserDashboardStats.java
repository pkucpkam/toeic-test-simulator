package com.toeic.practice.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "user_dashboard_stats")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDashboardStats {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private User user;

    @Builder.Default
    @Column(name = "total_attempts")
    private Integer totalAttempts = 0;

    @Builder.Default
    @Column(name = "total_full_tests")
    private Integer totalFullTests = 0;

    @Builder.Default
    @Column(name = "total_part_practices")
    private Integer totalPartPractices = 0;

    @Builder.Default
    @Column(name = "average_score")
    private Double averageScore = 0.0;

    @Builder.Default
    @Column(name = "average_accuracy")
    private Double averageAccuracy = 0.0;

    @Builder.Default
    @Column(name = "best_score")
    private Integer bestScore = 0;

    @Builder.Default
    @Column(name = "current_streak")
    private Integer currentStreak = 0;

    @Column(name = "last_practice_date")
    private LocalDate lastPracticeDate;

    @Builder.Default
    @Column(name = "p1_total")
    private Integer p1Total = 0;
    @Builder.Default
    @Column(name = "p1_correct")
    private Integer p1Correct = 0;

    @Builder.Default
    @Column(name = "p2_total")
    private Integer p2Total = 0;
    @Builder.Default
    @Column(name = "p2_correct")
    private Integer p2Correct = 0;

    @Builder.Default
    @Column(name = "p3_total")
    private Integer p3Total = 0;
    @Builder.Default
    @Column(name = "p3_correct")
    private Integer p3Correct = 0;

    @Builder.Default
    @Column(name = "p4_total")
    private Integer p4Total = 0;
    @Builder.Default
    @Column(name = "p4_correct")
    private Integer p4Correct = 0;

    @Builder.Default
    @Column(name = "p5_total")
    private Integer p5Total = 0;
    @Builder.Default
    @Column(name = "p5_correct")
    private Integer p5Correct = 0;

    @Builder.Default
    @Column(name = "p6_total")
    private Integer p6Total = 0;
    @Builder.Default
    @Column(name = "p6_correct")
    private Integer p6Correct = 0;

    @Builder.Default
    @Column(name = "p7_total")
    private Integer p7Total = 0;
    @Builder.Default
    @Column(name = "p7_correct")
    private Integer p7Correct = 0;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    protected void onSave() {
        this.updatedAt = LocalDateTime.now();
    }
}
