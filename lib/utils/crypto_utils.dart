import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static String hashPassword(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyPassword(String input, String hash) {
    return hashPassword(input) == hash;
  }
}
