import 'package:isar/isar.dart';

part 'app_config.g.dart';

@collection
class AppConfig {
  Id id = Isar.autoIncrement;

  late String businessName; // Nombre de la pollería
  String ruc = '';
  String address = '';
  String phone = '';
  
  bool isFirstRun = true;
}
