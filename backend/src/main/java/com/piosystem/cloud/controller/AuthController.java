package com.piosystem.cloud.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    // Simulación temporal para el MVP (Luego lo conectaremos con JWT y Spring Security reales)
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        String email = credentials.get("email");
        String password = credentials.get("password");

        // TODO: Validar con BusinessRepository y generar JWT
        if ("admin@piosystem.com".equals(email) && "123456".equals(password)) {
            return ResponseEntity.ok(Map.of("token", "dummy-jwt-token-12345", "businessId", "b-001"));
        }
        
        return ResponseEntity.status(401).body(Map.of("error", "Credenciales incorrectas"));
    }
}
