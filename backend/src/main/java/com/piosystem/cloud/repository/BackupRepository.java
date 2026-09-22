package com.piosystem.cloud.repository;

import com.piosystem.cloud.model.Backup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface BackupRepository extends JpaRepository<Backup, UUID> {
    Optional<Backup> findFirstByBusinessIdOrderByUploadedAtDesc(UUID businessId);
}
