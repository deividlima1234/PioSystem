package com.piosystem.cloud.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "businesses")
public class Business {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private String ruc;

    private LocalDateTime subscriptionEndDate;

    private boolean isActive = true;

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getRuc() { return ruc; }
    public void setRuc(String ruc) { this.ruc = ruc; }
    public LocalDateTime getSubscriptionEndDate() { return subscriptionEndDate; }
    public void setSubscriptionEndDate(LocalDateTime subscriptionEndDate) { this.subscriptionEndDate = subscriptionEndDate; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
}
