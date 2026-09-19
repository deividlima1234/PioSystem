import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class HardwareInfo {
  static Future<String> getDeviceSignature() async {
    final deviceInfo = DeviceInfoPlugin();
    String signature = 'unknown_device';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        // Combinamos varios identificadores para crear una firma única
        signature = '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}';
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        signature = '${iosInfo.identifierForVendor}';
      } else if (Platform.isWindows) {
        WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        signature = '${windowsInfo.deviceId}';
      } else if (Platform.isLinux) {
        LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;
        signature = '${linuxInfo.machineId}';
      } else if (Platform.isMacOS) {
        MacOsDeviceInfo macInfo = await deviceInfo.macOsInfo;
        signature = '${macInfo.systemGUID}';
      }
    } catch (e) {
      print('Error obteniendo firma del dispositivo: $e');
    }

    return signature;
  }
}
