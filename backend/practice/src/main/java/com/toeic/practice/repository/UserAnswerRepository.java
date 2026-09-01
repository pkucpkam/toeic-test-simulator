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
}
