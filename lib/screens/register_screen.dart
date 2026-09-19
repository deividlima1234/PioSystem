import 'package:flutter/material.dart';
import '../services/isar_service.dart';
import 'activation_screen.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final IsarService _isarService = IsarService();
  
  final _businessNameController = TextEditingController();
  final _adminNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() async {
    if (_businessNameController.text.isEmpty ||
        _adminNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Todos los campos son obligatorios'), backgroundColor: context.colors.error),
      );
      return;
    }

    await _isarService.registerFirstAdmin(
      businessName: _businessNameController.text,
      adminName: _adminNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ActivationScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fastfood,
                  size: 80,
                  color: context.colors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "PioSystem",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  "Registro Inicial",
                  style: TextStyle(
                    fontSize: 18,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                _buildTextField(_businessNameController, "Nombre de la Pollería", Icons.store),
                const SizedBox(height: 16),
                _buildTextField(_adminNameController, "Nombre del Responsable", Icons.person),
                const SizedBox(height: 16),
                _buildTextField(_emailController, "Correo Electrónico", Icons.email),
                const SizedBox(height: 16),
                _buildTextField(_passwordController, "Contraseña (Clave Maestra)", Icons.lock, obscureText: true),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                    ),
                    child: Text("Crear Cuenta Local", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: context.colors.textSecondary),
        filled: true,
        fillColor: context.colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: TextStyle(color: context.colors.textPrimary),
    );
  }
}
