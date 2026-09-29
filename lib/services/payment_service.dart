import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'isar_service.dart';

class PaymentService {
  final Dio _dio = Dio();
  final IsarService _isarService = IsarService();
  
  // Culqi Public Key (Solo para generar tokens seguros en el cliente)
  final String _culqiPublicKey = "pk_test_tu_llave_publica_aqui";
  
  // URL de tu Backend Java que procesa el cargo real
  final String _backendUrl = "https://api-piosystem.colegiohuanoquite.org.pe/api/v1";

  Future<bool> processCardPayment({
    required String cardNumber,
    required String cvv,
    required String expiry,
    required String email,
  }) async {
    try {
      // 1. Separar expiración MM/YY
      final parts = expiry.split('/');
      if (parts.length != 2) return false;
      
      final expMonth = parts[0];
      final expYear = "20${parts[1]}"; // asume formato 24 -> 2024

      // 2. Generar Token en Culqi
      final tokenResponse = await _dio.post(
        "https://secure.culqi.com/v2/tokens",
        data: {
          "card_number": cardNumber.replaceAll(' ', ''),
          "cvv": cvv,
          "expiration_month": expMonth,
          "expiration_year": expYear,
          "email": email,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $_culqiPublicKey",
            "Content-Type": "application/json"
          }
        ),
      );

      final tokenId = tokenResponse.data['id'];

      // 3. Enviar token al Backend Java para procesar la suscripción
      return await _subscribeOnBackend(tokenId, email);

    } catch (e) {
      print("Error en Pago con Tarjeta: $e");
      return false;
    }
  }

  Future<bool> processYapePayment({
    required String phone,
    required String approvalCode,
  }) async {
    try {
      // Nota: Culqi procesa Yape como "Cargos" directos o "Tokens" especiales.
      // Dependiendo de tu cuenta, Yape a veces va directo al backend (Java).
      // Aquí armamos el flujo asumiendo que mandamos el código al backend.
      
      final payload = {
        "provider": "YAPE",
        "phone": phone,
        "approval_code": approvalCode,
      };

      return await _subscribeOnBackend("YAPE_DIRECT", "usuario_yape@local.com", extraPayload: payload);
    } catch (e) {
      print("Error en Pago con Yape: $e");
      return false;
    }
  }

  Future<bool> _subscribeOnBackend(String paymentToken, String email, {Map<String, dynamic>? extraPayload}) async {
    try {
      final config = await _isarService.getAppConfig();
      
      final payload = {
        "paymentToken": paymentToken,
        "email": email,
        "business": {
          "name": config?.businessName,
          "ruc": config?.ruc,
          "phone": config?.phone,
        },
        if (extraPayload != null) ...extraPayload
      };

      // TODO: Reemplazar con el endpoint real de tu backend
      /*
      final response = await _dio.post(
        "$_backendUrl/subscriptions/checkout",
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final cloudToken = response.data['token']; // El JWT
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cloud_jwt_token', cloudToken);
        return true;
      }
      return false;
      */

      // SIMULACIÓN PARA EFECTOS VISUALES
      await Future.delayed(const Duration(seconds: 3));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cloud_jwt_token', "dummy_jwt_token_after_payment");
      return true;

    } catch (e) {
      print("Error conectando al backend: $e");
      return false;
    }
  }
}
