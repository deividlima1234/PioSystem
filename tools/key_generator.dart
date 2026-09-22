import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main() {
  print("===================================");
  print("  PIO-SYSTEM: GENERADOR DE CLAVES  ");
  print("===================================");
  print("");
  
  stdout.write("Introduce el 'Código de Equipo' del cliente: ");
  String? hardwareId = stdin.readLineSync();
  
  if (hardwareId == null || hardwareId.trim().isEmpty) {
    print("Error: El código no puede estar vacío.");
    return;
  }
  
  String activationKey = generateActivationKey(hardwareId.trim());
  
  print("\n===================================");
  print("CÓDIGO DE ACCESO GENERADO:");
  print(">> $activationKey <<");
  print("===================================");
  print("Dale este código al cliente para que active su equipo.");
}

String generateActivationKey(String hardwareId) {
  // Una "Sal" secreta que solo tú y tu código conocen
  const secretSalt = "PioSystem_MasterKey_2026_@EddamCore";
  
  // Concatenar y hashear
  var bytes = utf8.encode(hardwareId + secretSalt);
  var digest = sha256.convert(bytes);
  
  // Tomar los primeros 12 caracteres del hash en mayúsculas
  String hashString = digest.toString().toUpperCase();
  
  // Formatear como XXXX-XXXX-XXXX para que sea fácil de leer
  String part1 = hashString.substring(0, 4);
  String part2 = hashString.substring(4, 8);
  String part3 = hashString.substring(8, 12);
  
  return "$part1-$part2-$part3";
}
