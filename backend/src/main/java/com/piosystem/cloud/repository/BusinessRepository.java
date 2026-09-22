package com.piosystem.cloud.repository;

import com.piosystem.cloud.model.Business;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface BusinessRepository extends JpaRepository<Business, UUID> {
    Optional<Business> findByEmail(String email);
    Optional<Business> findByRuc(String ruc);
}
