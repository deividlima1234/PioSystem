package com.piosystem.cloud.controller;

import com.piosystem.cloud.model.Business;
import com.piosystem.cloud.model.Device;
import com.piosystem.cloud.repository.BusinessRepository;
import com.piosystem.cloud.repository.DeviceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/v1/superadmin")
public class SuperAdminController {

    @Autowired
    private BusinessRepository businessRepository;

    @Autowired
    private DeviceRepository deviceRepository;

    private boolean isAuthorized(String key) {
        // Clave secreta quemada para MVP
        return "EddamCore2026".equals(key);
    }

    @GetMapping("/businesses")
    public ResponseEntity<?> getAllBusinesses(@RequestHeader(value = "X-SuperAdmin-Key", required = false) String key) {
        if (!isAuthorized(key)) return ResponseEntity.status(401).body(Map.of("error", "No autorizado"));
        List<Business> businesses = businessRepository.findAll();
        return ResponseEntity.ok(businesses);
    }

    @GetMapping("/devices")
    public ResponseEntity<?> getAllDevices(@RequestHeader(value = "X-SuperAdmin-Key", required = false) String key) {
        if (!isAuthorized(key)) return ResponseEntity.status(401).body(Map.of("error", "No autorizado"));
        List<Device> devices = deviceRepository.findAll();
        return ResponseEntity.ok(devices);
    }

    @PutMapping("/businesses/{id}/suspend")
    public ResponseEntity<?> suspendBusiness(@PathVariable UUID id, @RequestHeader(value = "X-SuperAdmin-Key", required = false) String key) {
        if (!isAuthorized(key)) return ResponseEntity.status(401).body(Map.of("error", "No autorizado"));
        Optional<Business> opt = businessRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        Business b = opt.get();
        b.setActive(false);
        businessRepository.save(b);
        return ResponseEntity.ok(Map.of("status", "suspendido"));
    }

    @PutMapping("/businesses/{id}/activate")
    public ResponseEntity<?> activateBusiness(@PathVariable UUID id, @RequestHeader(value = "X-SuperAdmin-Key", required = false) String key) {
        if (!isAuthorized(key)) return ResponseEntity.status(401).body(Map.of("error", "No autorizado"));
        Optional<Business> opt = businessRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        Business b = opt.get();
        b.setActive(true);
        businessRepository.save(b);
        return ResponseEntity.ok(Map.of("status", "activado"));
    }

    @PutMapping("/businesses/{id}/extend")
    public ResponseEntity<?> extendSubscription(@PathVariable UUID id, @RequestParam int months, @RequestHeader(value = "X-SuperAdmin-Key", required = false) String key) {
        if (!isAuthorized(key)) return ResponseEntity.status(401).body(Map.of("error", "No autorizado"));
        Optional<Business> opt = businessRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        Business b = opt.get();
        
        LocalDateTime currentEnd = b.getSubscriptionEndDate() != null ? b.getSubscriptionEndDate() : LocalDateTime.now();
        if (currentEnd.isBefore(LocalDateTime.now())) {
            currentEnd = LocalDateTime.now();
        }
        b.setSubscriptionEndDate(currentEnd.plusMonths(months));
        b.setActive(true); // Auto activa si extiendes
        businessRepository.save(b);
        return ResponseEntity.ok(Map.of("status", "extendido", "newEndDate", b.getSubscriptionEndDate()));
    }
}
