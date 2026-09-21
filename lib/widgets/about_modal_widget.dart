import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/update_service.dart';
import '../theme/app_theme.dart';
import 'update_modal.dart';

class AboutModalWidget extends StatefulWidget {
  final BuildContext parentContext;

  const AboutModalWidget({super.key, required this.parentContext});

  @override
  State<AboutModalWidget> createState() => _AboutModalWidgetState();
}

class _AboutModalWidgetState extends State<AboutModalWidget> {
  String _appVersion = "Cargando...";
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = info.version;
      });
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _isError = false;
    });

    try {
      final updateInfo = await UpdateService().checkForUpdates();
      
      if (!mounted) return;

      if (updateInfo != null && updateInfo.hasUpdate) {
        // Cerrar este modal de "Acerca de"
        Navigator.of(context).pop();
        // Mostrar el modal de actualización usando el contexto padre
        UpdateModal.show(widget.parentContext, updateInfo);
      } else {
        setState(() {
          _isLoading = false;
          _message = "Tienes la última versión instalada.";
          _isError = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _message = "Error de red: revisa tu conexión a internet.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Icon(Icons.point_of_sale, size: 48, color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            'PioSystem',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
          ),
          Text(
            'Versión $_appVersion',
            style: TextStyle(color: context.colors.textMuted),
          ),
          
          if (_message != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _isError ? context.colors.error.withOpacity(0.1) : context.colors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isError ? context.colors.error.withOpacity(0.3) : context.colors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: _isError ? context.colors.error : context.colors.success,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _isError ? context.colors.error : context.colors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          Divider(color: context.colors.borderLight),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkForUpdates,
              icon: _isLoading 
                  ? SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.onPrimary)
                    )
                  : Icon(Icons.sync, color: context.colors.onPrimary),
              label: Text(
                _isLoading ? "Buscando..." : "Buscar Actualizaciones",
                style: TextStyle(fontSize: 16, color: context.colors.onPrimary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildCreditRow("Desarrollado por", "Eddam Eloy"),
          const SizedBox(height: 12),
          _buildCreditRow("Corporación", "EddamCore © 2026"),
          const SizedBox(height: 40),
          Text(
            "Todos los derechos reservados",
            style: TextStyle(fontSize: 10, color: context.colors.textMuted),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCreditRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: context.colors.textMuted, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary)),
      ],
    );
  }
}
