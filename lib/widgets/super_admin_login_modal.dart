import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../screens/super_admin_layout.dart';

class SuperAdminLoginModal extends StatefulWidget {
  const SuperAdminLoginModal({super.key});

  @override
  State<SuperAdminLoginModal> createState() => _SuperAdminLoginModalState();
}

class _SuperAdminLoginModalState extends State<SuperAdminLoginModal> {
  final TextEditingController _passController = TextEditingController();
  bool _isError = false;

  void _attemptLogin() {
    // Clave Maestra Hardcodeada para el Super Admin
    if (_passController.text == "EddamCore2026") {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      final isDark = themeProvider.currentTheme == AppThemeType.darkRed || themeProvider.currentTheme == AppThemeType.superAdminDark;
      themeProvider.switchTheme(isDark ? AppThemeType.superAdminDark : AppThemeType.superAdminLight);

      Navigator.of(context).pop(); // Cerrar el modal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SuperAdminLayout())
      );
    } else {
      setState(() {
        _isError = true;
        _passController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.admin_panel_settings, size: 64, color: context.colors.textPrimary),
            const SizedBox(height: 16),
            Text(
              "ACCESO CLASIFICADO",
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ingrese Clave Maestra de EddamCore",
              style: TextStyle(color: context.colors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passController,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.key, color: _isError ? context.colors.error : context.colors.textSecondary),
                filled: true,
                fillColor: context.colors.background,
                errorText: _isError ? "Clave denegada" : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary, width: 2),
                ),
              ),
              style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold),
              onSubmitted: (_) => _attemptLogin(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _attemptLogin,
                child: const Text("INGRESAR AL SISTEMA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
