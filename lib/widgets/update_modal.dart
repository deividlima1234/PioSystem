import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/update_info.dart';
import '../theme/app_theme.dart';

class UpdateModal extends StatefulWidget {
  final UpdateInfo updateInfo;

  const UpdateModal({super.key, required this.updateInfo});

  static void show(BuildContext context, UpdateInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: !info.isMandatory,
      enableDrag: !info.isMandatory,
      backgroundColor: context.readColors.transparent,
      builder: (context) => UpdateModal(updateInfo: info),
    );
  }

  @override
  State<UpdateModal> createState() => _UpdateModalState();
}

class _UpdateModalState extends State<UpdateModal> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusMessage = "";

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = "Descargando actualización...";
    });

    try {
      final dio = Dio();
      
      // Obtener el directorio de descargas o temporal
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getExternalStorageDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      
      final String savePath = "${dir!.path}/piosystem_v${widget.updateInfo.latestVersion}.apk";

      await dio.download(
        widget.updateInfo.downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
              _statusMessage = "Descargando... ${(_progress * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      setState(() {
        _statusMessage = "Descarga completada. Abriendo instalador...";
      });

      // Abrir el archivo para iniciar la instalación
      final result = await OpenFilex.open(savePath);
      
      if (result.type != ResultType.done && mounted) {
         setState(() {
           _statusMessage = "Error al abrir el instalador: ${result.message}";
           _isDownloading = false;
         });
      } else if (mounted) {
         Navigator.of(context).pop();
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _statusMessage = "Error en la descarga. Verifica tu conexión.";
        });
      }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: context.colors.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.system_update, color: context.colors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¡Nueva Actualización!",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: context.colors.textPrimary),
                    ),
                    Text(
                      "Versión ${widget.updateInfo.latestVersion}",
                      style: TextStyle(color: context.colors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "Novedades:",
            style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.borderFaint),
            ),
            child: Text(
              widget.updateInfo.releaseNotes,
              style: TextStyle(color: context.colors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          
          if (_isDownloading) ...[
            Text(_statusMessage, style: TextStyle(color: context.colors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: context.colors.borderFaint,
              valueColor: AlwaysStoppedAnimation<Color>(context.colors.primary),
              borderRadius: BorderRadius.circular(4),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startDownload,
                icon: Icon(Icons.download, color: context.colors.onPrimary),
                label: Text(
                  "Descargar e Instalar",
                  style: TextStyle(color: context.colors.onPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            if (!widget.updateInfo.isMandatory) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Quizás más tarde", style: TextStyle(color: context.colors.textSecondary)),
                ),
              )
            ]
          ]
        ],
      ),
    );
  }
}
