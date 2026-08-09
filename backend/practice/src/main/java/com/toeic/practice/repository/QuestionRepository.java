package com.toeic.practice.repository;

import com.toeic.practice.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface QuestionRepository extends JpaRepository<Question, Long> {
    List<Question> findByQuestionGroupId(Long questionGroupId);

    /**
     * Returns the part number of the part that contains the given question.
     * Uses native SQL since Question entity may not have a mapped questionGroup relationship.
     */
    @Query(value = "SELECT tp.part_number FROM questions q " +
           "JOIN question_groups qg ON q.question_group_id = qg.id " +
           "JOIN test_parts tp ON qg.test_part_id = tp.id " +
           "WHERE q.id = :questionId", nativeQuery = true)
    Optional<Integer> findPartNumberByQuestionId(@Param("questionId") Long questionId);
}
