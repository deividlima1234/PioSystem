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
}
