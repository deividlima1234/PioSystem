import 'package:dio/dio.dart';
import 'isar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CloudSyncService {
  final String baseUrl = "https://api-piosystem.colegiohuanoquite.org.pe/api/v1";
  final Dio _dio = Dio();
  final IsarService _isarService = IsarService();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "$baseUrl/auth/login",
        data: {"email": email, "password": password},
      );
      
      if (response.statusCode == 200) {
        final token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cloud_jwt_token', token);
        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      return false;
    }
  }

  Future<bool> pushBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('cloud_jwt_token');
      
      if (token == null) return false;

      // Leer todo de la base de datos Isar
      final config = await _isarService.getAppConfig();
      final products = await _isarService.getAllProducts();
      final orders = await _isarService.getAllOrders();

      // Construir el gran paquete JSON
      final payload = {
        "appVersion": "1.2.0",
        "business": {
          "name": config?.businessName,
          "ruc": config?.ruc,
        },
        "products": products.map((p) => {
          "id": p.id,
          "name": p.name,
          "price": p.price,
          "category": p.category,
          "isAvailable": p.isAvailable
        }).toList(),
        "orders": orders.map((o) => {
          "id": o.id,
          "ticketNumber": o.ticketNumber,
          "totalAmount": o.totalAmount,
          "status": o.status.name,
          "createdAt": o.createdAt.toIso8601String()
        }).toList(),
      };

      final response = await _dio.post(
        "$baseUrl/backups/push",
        data: payload,
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Push Backup Error: $e");
      return false;
    }
  }
}
