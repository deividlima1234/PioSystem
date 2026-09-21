import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
  final dio = Dio();
  const url = "https://raw.githubusercontent.com/deividlima1234/PioSystem/main/update.json";
  try {
    final response = await dio.get(
      "$url?t=${DateTime.now().millisecondsSinceEpoch}",
      options: Options(
        headers: {
          "Cache-Control": "no-cache",
        }
      )
    );
    print("Status code: ${response.statusCode}");
    print("Data: ${response.data}");
    
    final data = response.data is String ? jsonDecode(response.data) : response.data;
    print("Parsed JSON: $data");
  } catch (e) {
    print("Error: $e");
  }
}
