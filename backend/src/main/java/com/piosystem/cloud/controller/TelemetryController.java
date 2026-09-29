package com.piosystem.cloud.controller;

import com.piosystem.cloud.model.Device;
import com.piosystem.cloud.repository.DeviceRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/telemetry")
public class TelemetryController {

    @Autowired
    private DeviceRepository deviceRepository;

    @PostMapping("/ping")
    public ResponseEntity<?> ping(@RequestBody Map<String, Object> payload) {
        String signature = (String) payload.get("hardwareSignature");
        Boolean isCloud = (Boolean) payload.get("isCloud");

        if (signature == null || signature.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Falta hardwareSignature"));
        }

        Optional<Device> optDevice = deviceRepository.findByHardwareSignature(signature);
        Device device;
        if (optDevice.isPresent()) {
            device = optDevice.get();
        } else {
            device = new Device();
            device.setHardwareSignature(signature);
        }
        
        device.setCloud(isCloud != null ? isCloud : false);
        device.setLastPingDate(LocalDateTime.now());
        
        deviceRepository.save(device);

        return ResponseEntity.ok(Map.of("status", "ok"));
    }
}
