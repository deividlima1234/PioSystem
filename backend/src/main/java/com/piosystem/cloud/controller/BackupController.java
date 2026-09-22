package com.piosystem.cloud.controller;

import com.piosystem.cloud.model.Backup;
import com.piosystem.cloud.model.Business;
import com.piosystem.cloud.repository.BackupRepository;
import com.piosystem.cloud.repository.BusinessRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/backups")
public class BackupController {

    @Autowired
    private BackupRepository backupRepository;

    @Autowired
    private BusinessRepository businessRepository;

    @PostMapping("/push")
    public ResponseEntity<?> receiveBackup(Authentication authentication, @RequestBody Map<String, Object> payload) {
        String email = authentication.getName();
        Optional<Business> businessOpt = businessRepository.findByEmail(email);

        if (businessOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Negocio no encontrado"));
        }

        Business business = businessOpt.get();

        if (!business.isActive() || (business.getSubscriptionEndDate() != null && business.getSubscriptionEndDate().isBefore(LocalDateTime.now()))) {
            return ResponseEntity.status(403).body(Map.of("error", "Suscripción expirada o inactiva"));
        }

        Backup backup = new Backup();
        backup.setBusiness(business);
        backup.setPayload(payload);
        backup.setAppVersion(payload.getOrDefault("appVersion", "unknown").toString());
        backup.setUploadedAt(LocalDateTime.now());

        backupRepository.save(backup);

        return ResponseEntity.ok(Map.of(
            "message", "Backup recibido y procesado correctamente",
            "backupId", backup.getId().toString(),
            "timestamp", backup.getUploadedAt().toString()
        ));
    }

    @GetMapping("/pull")
    public ResponseEntity<?> pullBackup(Authentication authentication) {
        String email = authentication.getName();
        Optional<Business> businessOpt = businessRepository.findByEmail(email);

        if (businessOpt.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "Negocio no encontrado"));
        }

        Optional<Backup> latestBackup = backupRepository.findFirstByBusinessIdOrderByUploadedAtDesc(businessOpt.get().getId());

        if (latestBackup.isEmpty()) {
            return ResponseEntity.status(404).body(Map.of("error", "No hay respaldos disponibles para este negocio"));
        }

        return ResponseEntity.ok(latestBackup.get().getPayload());
    }
}
