package com.toeic.practice.repository;

import com.toeic.practice.entity.UserIncorrectQuestion;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserIncorrectQuestionRepository extends JpaRepository<UserIncorrectQuestion, Long> {
    List<UserIncorrectQuestion> findByUserId(Long userId);
    Page<UserIncorrectQuestion> findByUserIdOrderByIdDesc(Long userId, Pageable pageable);
}
