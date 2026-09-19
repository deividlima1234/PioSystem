import 'package:isar/isar.dart';

part 'user.g.dart';

@collection
class User {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String email; // Para el administrador

  late String passwordHash; // Hash SHA-256 de la contraseña

  late String pinHash; // Hash SHA-256 del PIN de cajero

  @Enumerated(EnumType.name)
  late Role role;

  late String name;
}

enum Role {
  admin,
  cashier
}
