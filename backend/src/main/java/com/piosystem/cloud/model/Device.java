package com.piosystem.cloud.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "devices")
public class Device {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String hardwareSignature;

    @Column(nullable = false)
    private boolean isCloud;

    private LocalDateTime lastPingDate;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getHardwareSignature() { return hardwareSignature; }
    public void setHardwareSignature(String hardwareSignature) { this.hardwareSignature = hardwareSignature; }
    public boolean isCloud() { return isCloud; }
    public void setCloud(boolean cloud) { isCloud = cloud; }
    public LocalDateTime getLastPingDate() { return lastPingDate; }
    public void setLastPingDate(LocalDateTime lastPingDate) { this.lastPingDate = lastPingDate; }
}
