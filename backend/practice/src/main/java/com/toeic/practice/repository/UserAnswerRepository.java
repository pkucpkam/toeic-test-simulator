package com.toeic.practice.repository;

import com.toeic.practice.entity.UserAnswer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserAnswerRepository extends JpaRepository<UserAnswer, Long> {
    List<UserAnswer> findByAttemptId(Long attemptId);

    @Query("SELECT ua FROM UserAnswer ua JOIN ua.question q JOIN q.questionGroup qg JOIN qg.testPart tp " +
           "WHERE ua.attempt.id = :attemptId AND tp.partNumber = :partNumber")
    List<UserAnswer> findByAttemptIdAndPartNumber(@Param("attemptId") Long attemptId, @Param("partNumber") Integer partNumber);

    /**
     * Eagerly fetches UserAnswer along with Question, QuestionGroup and TestPart in a single JOIN FETCH query.
     * Use this instead of findByAttemptId() whenever partNumber is required per answer (e.g. getAttemptResult),
     * so Hibernate does NOT fire N additional SELECT statements for each association.
     */
    @Query("SELECT ua FROM UserAnswer ua " +
           "JOIN FETCH ua.question q " +
           "JOIN FETCH q.questionGroup qg " +
           "JOIN FETCH qg.testPart tp " +
           "WHERE ua.attempt.id = :attemptId")
    List<UserAnswer> findByAttemptIdWithDetails(@Param("attemptId") Long attemptId);
}

