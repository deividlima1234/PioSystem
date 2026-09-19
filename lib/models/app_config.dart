import 'package:isar/isar.dart';

part 'app_config.g.dart';

@collection
class AppConfig {
  Id id = Isar.autoIncrement;

  late String businessName; // Nombre de la pollería
  
  bool isFirstRun = true;
}
