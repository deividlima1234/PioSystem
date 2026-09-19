import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../theme/app_theme.dart';
import 'bluetooth_radar.dart';

class BluetoothScannerModal extends StatefulWidget {
  const BluetoothScannerModal({super.key});

  @override
  State<BluetoothScannerModal> createState() => _BluetoothScannerModalState();
}

class _BluetoothScannerModalState extends State<BluetoothScannerModal> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  bool _isScanning = true;
  BluetoothDevice? _deviceConnected;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _devices = [];
    });

    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      if (mounted) {
        setState(() {
          _devices = devices;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() {
      _isScanning = true; // Use scanning state for loading
    });
    
    try {
      bool? isConnected = await bluetooth.isConnected;
      if (isConnected != null && isConnected) {
        await bluetooth.disconnect();
      }
      await bluetooth.connect(device);
      setState(() {
        _deviceConnected = device;
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Conectado a ${device.name}"),
            backgroundColor: context.readColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al conectar: ${device.name}"),
            backgroundColor: context.readColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Text(
            "Buscando Impresoras",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            "Asegúrate de que la ticketera esté encendida",
            style: TextStyle(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Center(
              child: BluetoothRadar(isScanning: _isScanning),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dispositivos Encontrados",
                style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary),
              ),
              if (!_isScanning)
                TextButton.icon(
                  onPressed: _startScan,
                  icon: Icon(Icons.refresh, size: 18, color: context.colors.primary),
                  label: Text("Buscar de nuevo", style: TextStyle(color: context.colors.primary)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _devices.isEmpty && !_isScanning
                ? Center(
                    child: Text(
                      "No se encontraron dispositivos vinculados.\nEmpareja la impresora desde los ajustes de Bluetooth de tu teléfono primero.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.colors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final isConnected = _deviceConnected?.address == device.address;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isConnected ? context.colors.primary : context.colors.borderFaint,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.print, color: context.colors.primary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    device.name ?? "Dispositivo Desconocido",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                                  ),
                                  Text(
                                    device.address ?? "",
                                    style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: isConnected || _isScanning ? null : () => _connect(device),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isConnected ? context.colors.success : context.colors.primary,
                                foregroundColor: context.colors.onPrimary,
                              ),
                              child: Text(isConnected ? "Conectado" : "Conectar"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
