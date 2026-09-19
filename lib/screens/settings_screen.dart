import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/isar_service.dart';
import '../models/app_config.dart';
import '../widgets/bluetooth_radar.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import '../widgets/bluetooth_scanner_modal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final IsarService _isarService = IsarService();
  final _formKey = GlobalKey<FormState>();
  
  AppConfig? _config;
  bool _isLoading = true;

  String _name = '';
  String _ruc = '';
  String _address = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _isarService.getAppConfig();
    if (mounted) {
      setState(() {
        _config = config;
        _name = config?.businessName ?? '';
        _ruc = config?.ruc ?? '';
        _address = config?.address ?? '';
        _phone = config?.phone ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate() && _config != null) {
      _formKey.currentState!.save();
      _config!.businessName = _name;
      _config!.ruc = _ruc;
      _config!.address = _address;
      _config!.phone = _phone;
      
      await _isarService.updateAppConfig(_config!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Datos guardados exitosamente"),
            backgroundColor: context.readColors.success,
          ),
        );
      }
    }
  }

  Future<void> _checkBluetoothAndShowScanner() async {
    // Check permissions
    var status = await Permission.bluetoothConnect.status;
    if (!status.isGranted) {
      await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();
    }

    bool? isOn = await BlueThermalPrinter.instance.isOn;
    if (isOn == null || !isOn) {
      _showBluetoothOffWarning();
      return;
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: context.readColors.transparent,
        builder: (context) {
          return const BluetoothScannerModal();
        },
      );
    }
  }

  void _showBluetoothOffWarning() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.readColors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.readColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bluetooth_disabled, color: context.readColors.error, size: 64),
              const SizedBox(height: 16),
              Text(
                "Bluetooth Apagado",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.readColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                "Para buscar impresoras necesitas encender el Bluetooth de tu dispositivo.",
                textAlign: TextAlign.center,
                style: TextStyle(color: context.readColors.textSecondary),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.readColors.primary,
                    foregroundColor: context.readColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Ir a Configuraciones", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: context.colors.primary));
    }

    return Container(
      color: context.colors.transparent,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            "Configuración",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
          ),
          const SizedBox(height: 24),

          // SECCIÓN 1: DATOS DEL NEGOCIO
          Text("DATOS DEL NEGOCIO", style: TextStyle(color: context.colors.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.borderFaint),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _name,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nombre Comercial',
                      labelStyle: TextStyle(color: context.colors.textMuted),
                      filled: true, fillColor: context.colors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSaved: (v) => _name = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _ruc,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'RUC (Opcional)',
                      labelStyle: TextStyle(color: context.colors.textMuted),
                      filled: true, fillColor: context.colors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSaved: (v) => _ruc = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _address,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Dirección (Opcional)',
                      labelStyle: TextStyle(color: context.colors.textMuted),
                      filled: true, fillColor: context.colors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSaved: (v) => _address = v ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _phone,
                    style: TextStyle(color: context.colors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Teléfono (Opcional)',
                      labelStyle: TextStyle(color: context.colors.textMuted),
                      filled: true, fillColor: context.colors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    onSaved: (v) => _phone = v ?? '',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: context.colors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Guardar Datos", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // SECCIÓN 2: IMPRESORA Y BLUETOOTH
          Text("IMPRESIÓN", style: TextStyle(color: context.colors.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.borderFaint),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.print, color: context.colors.primary),
              ),
              title: Text("Conexión de Ticketera", style: TextStyle(color: context.colors.textPrimary, fontWeight: FontWeight.bold)),
              subtitle: Text("Emparejar Bluetooth/USB", style: TextStyle(color: context.colors.textSecondary)),
              trailing: ElevatedButton(
                onPressed: _checkBluetoothAndShowScanner,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.surfaceLight,
                  foregroundColor: context.colors.primary,
                  elevation: 0,
                ),
                child: const Text("Buscar"),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // SECCIÓN 3: TEMA Y APARIENCIA
          Text("APARIENCIA", style: TextStyle(color: context.colors.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.borderFaint),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF003C)),
                  ),
                  title: Text("Tema Oscuro (Rojo Carmesí)", style: TextStyle(color: context.colors.textPrimary)),
                  trailing: context.watch<ThemeProvider>().currentTheme == AppThemeType.darkRed
                      ? Icon(Icons.check_circle, color: context.colors.primary)
                      : null,
                  onTap: () => context.read<ThemeProvider>().switchTheme(AppThemeType.darkRed),
                ),
                Divider(color: context.colors.borderFaint, height: 1),
                ListTile(
                  leading: Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1565C0)),
                  ),
                  title: Text("Tema Claro (Azul Moderno)", style: TextStyle(color: context.colors.textPrimary)),
                  trailing: context.watch<ThemeProvider>().currentTheme == AppThemeType.lightBlue
                      ? Icon(Icons.check_circle, color: context.colors.primary)
                      : null,
                  onTap: () => context.read<ThemeProvider>().switchTheme(AppThemeType.lightBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // SECCIÓN 4: CLOUD BACKUP
          Text("RESPALDO EN LA NUBE", style: TextStyle(color: context.colors.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.primaryDark, context.colors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_sync, color: context.colors.onPrimary, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("PioSystem Cloud", style: TextStyle(color: context.colors.onPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(
                        "Sincroniza tus ventas y protege tus datos automáticamente.",
                        style: TextStyle(color: context.colors.onPrimary.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("Próximamente", style: TextStyle(color: context.colors.onPrimary, fontWeight: FontWeight.bold, fontSize: 10)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
