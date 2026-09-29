package com.piosystem.cloud.repository;

import com.piosystem.cloud.model.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DeviceRepository extends JpaRepository<Device, Long> {
    Optional<Device> findByHardwareSignature(String hardwareSignature);
}
