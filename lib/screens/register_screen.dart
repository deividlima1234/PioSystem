import 'package:flutter/material.dart';
import '../services/isar_service.dart';
import 'activation_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/cloud_sync_modal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDark = themeProvider.currentTheme == AppThemeType.darkRed;
              return IconButton(
                tooltip: 'Cambiar Tema',
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder: (child, animation) {
                    return RotationTransition(
                      turns: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    key: ValueKey(isDark ? 'light' : 'dark'),
                    color: context.colors.textPrimary,
                    size: 28,
                  ),
                ),
                onPressed: () {
                  themeProvider.switchTheme(
                    isDark ? AppThemeType.lightBlue : AppThemeType.darkRed,
                  );
                },
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  width: 100,
                  height: 100,
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
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Importar e invocar el modal en modo login
                      final result = await CloudSyncModal.show(context, isLoginMode: true);
                      // Si el resultado es true (login exitoso), redirigir al home o la pantalla que corresponda
                      // (Requiere recargar el main o navegar, por ahora lo dejamos así)
                    },
                    icon: Icon(Icons.cloud_download, color: context.colors.primary),
                    label: Text("Restaurar desde PioSystem Cloud", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.primary)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: context.colors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      )
                    ),
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
