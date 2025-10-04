package com.auren.repository;

import com.auren.model.InsightSnapshot;
import com.auren.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface InsightSnapshotRepository extends JpaRepository<InsightSnapshot, Long> {

    Optional<InsightSnapshot> findTop1ByUserOrderByCreatedAtDesc(User user);

    List<InsightSnapshot> findTop20ByUserOrderByCreatedAtDesc(User user);
}
