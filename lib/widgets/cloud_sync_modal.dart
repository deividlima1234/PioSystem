import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/cloud_sync_service.dart';

class CloudSyncModal extends StatefulWidget {
  final bool isLoginMode;

  const CloudSyncModal({super.key, this.isLoginMode = false});

  static Future<dynamic> show(BuildContext context, {bool isLoginMode = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CloudSyncModal(isLoginMode: isLoginMode),
    );
  }

  @override
  State<CloudSyncModal> createState() => _CloudSyncModalState();
}

class _CloudSyncModalState extends State<CloudSyncModal> {
  final CloudSyncService _syncService = CloudSyncService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  
  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    bool success = await _syncService.login(_emailController.text, _passwordController.text);
    
    if (!mounted) return;
    setState(() => _isLoading = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Cuenta vinculada con éxito"), backgroundColor: context.colors.success),
      );
      Navigator.pop(context, true); // Retorna true si fue exitoso
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Credenciales incorrectas"), backgroundColor: context.colors.error),
      );
    }
  }

  void _syncData(bool isPush) async {
    // Mostrar diálogo bloqueante
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SyncProgressDialog(isPush: isPush),
    );
    
    bool success = isPush ? await _syncService.pushBackup() : await _syncService.pullBackup();
    
    if (!mounted) return;
    Navigator.pop(context); // Cerrar diálogo bloqueante
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Sincronización completada"), backgroundColor: context.colors.success),
      );
      Navigator.pop(context); // Cerrar modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text("Error en la sincronización"), backgroundColor: context.colors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: widget.isLoginMode ? _buildLoginView() : _buildDashboardView(),
    );
  }

  Widget _buildLoginView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud, color: context.colors.primary, size: 32),
            const SizedBox(width: 12),
            Text(
              "Vincular Cuenta",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Ingresa las credenciales de tu suscripción para restaurar tus datos.",
          style: TextStyle(color: context.colors.textSecondary),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            prefixIcon: Icon(Icons.email, color: context.colors.textSecondary),
            filled: true,
            fillColor: context.colors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          style: TextStyle(color: context.colors.textPrimary),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: Icon(Icons.lock, color: context.colors.textSecondary),
            filled: true,
            fillColor: context.colors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          style: TextStyle(color: context.colors.textPrimary),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading 
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: context.colors.onPrimary, strokeWidth: 2))
                : Text("Conectar y Vincular", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onPrimary)),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_done, color: context.colors.primary, size: 64),
        const SizedBox(height: 16),
        Text(
          "PioSystem Cloud Activo",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          "Tu cuenta está vinculada de forma segura.",
          style: TextStyle(color: context.colors.textSecondary),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () => _syncData(true),
            icon: Icon(Icons.cloud_upload, color: context.colors.onPrimary),
            label: Text("Respaldar Ahora", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.onPrimary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton.icon(
            onPressed: () => _syncData(false),
            icon: Icon(Icons.cloud_download, color: context.colors.primary),
            label: Text("Restaurar Datos", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.colors.primary)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: context.colors.primary, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _SyncProgressDialog extends StatelessWidget {
  final bool isPush;
  const _SyncProgressDialog({required this.isPush});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reemplazar por un Lottie real más adelante si se provee. 
            // Usamos un CircularProgressIndicator por ahora para cumplir el diseño
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    color: context.colors.primary,
                    strokeWidth: 4,
                  ),
                  Icon(
                    isPush ? Icons.cloud_upload : Icons.cloud_download,
                    color: context.colors.primary,
                    size: 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Sincronizando datos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Por favor, no cierre la app",
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
