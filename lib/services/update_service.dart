import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../models/update_info.dart';

class UpdateService {
  // TODO: Reemplazar con la URL RAW de tu archivo update.json en GitHub
  static const String _updateUrl = "https://raw.githubusercontent.com/deividlima1234/PioSystem/main/update.json";
  
  final Dio _dio = Dio();

  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final response = await _dio.get(
        _updateUrl,
        options: Options(
          headers: {
            // Evitar caché de github raw
            "Cache-Control": "no-cache",
          }
        )
      );

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        
        final latestVersion = data['latestVersion'] as String;
        
        // Comparación simple de versiones (ej: "1.0.0" vs "1.0.1")
        bool hasUpdate = _isVersionGreater(latestVersion, currentVersion);

        return UpdateInfo.fromJson(data, hasUpdate);
      }
    } catch (e) {
      print("Error checking for updates: $e");
    }
    return null;
  }

  bool _isVersionGreater(String newVersion, String currentVersion) {
    List<String> newV = newVersion.split('.');
    List<String> currentV = currentVersion.split('.');

    for (int i = 0; i < newV.length; i++) {
      int n = int.tryParse(newV[i]) ?? 0;
      int c = i < currentV.length ? (int.tryParse(currentV[i]) ?? 0) : 0;
      
      if (n > c) return true;
      if (n < c) return false;
    }
    return false;
  }
}
