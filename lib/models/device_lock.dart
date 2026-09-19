import 'package:isar/isar.dart';

part 'device_lock.g.dart';

@collection
class DeviceLock {
  Id id = Isar.autoIncrement;

  late String hardwareSignature; // Firma encriptada del hardware
  
  bool isActivated = false;

  String? activationToken;
}
