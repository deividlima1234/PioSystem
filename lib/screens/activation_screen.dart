import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../utils/hardware_info.dart';
import '../services/isar_service.dart';
import 'login_screen.dart';
import '../theme/app_theme.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final IsarService _isarService = IsarService();
  String _hardwareSignature = "Cargando...";
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHardwareInfo();
  }

  Future<void> _loadHardwareInfo() async {
    String signature = await HardwareInfo.getDeviceSignature();
    setState(() {
      _hardwareSignature = signature;
    });
  }

  void _activate() async {
    String code = _codeController.text.trim();
    if (code.isEmpty) return;

    // La misma sal secreta usada en el generador de claves
    const secretSalt = "PioSystem_MasterKey_2026_@EddamCore";
    
    // Generar el hash localmente
    var bytes = utf8.encode(_hardwareSignature + secretSalt);
    var digest = sha256.convert(bytes);
    
    String hashString = digest.toString().toUpperCase();
    String expectedPart1 = hashString.substring(0, 4);
    String expectedPart2 = hashString.substring(4, 8);
    String expectedPart3 = hashString.substring(8, 12);
    String expectedCode = "$expectedPart1-$expectedPart2-$expectedPart3";

    if (code == expectedCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Activando equipo...', style: TextStyle(color: context.readColors.onPrimary)), backgroundColor: context.readColors.success),
      );
      
      await _isarService.activateDevice(_hardwareSignature, code);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen())
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código de Activación Inválido', style: TextStyle(color: context.readColors.onPrimary)), backgroundColor: context.readColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: context.colors.black.withOpacity(0.5),
                blurRadius: 10,
              )
            ]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline,
                size: 80,
                color: context.colors.primary,
              ),
              const SizedBox(height: 24),
              Text(
                "ACTIVACIÓN DE EQUIPO",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Text(
                "Licencia inactiva. Comuníquese con el proveedor para obtener su código de activación.",
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.errorAccent, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Text(
                "Código de Equipo:",
                style: TextStyle(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _hardwareSignature,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: "Código de Acceso",
                  hintText: "Ej. EDD-4F8A-99B2",
                  labelStyle: TextStyle(color: context.colors.textSecondary),
                  hintStyle: TextStyle(color: context.colors.borderLight),
                  filled: true,
                  fillColor: context.colors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: context.colors.primary),
                  ),
                ),
                style: TextStyle(color: context.colors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )
                  ),
                  onPressed: _activate,
                  child: const Text("ACTIVAR", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Tecnología impulsada por EddamCore-System",
                style: TextStyle(
                  color: context.colors.borderLight,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
