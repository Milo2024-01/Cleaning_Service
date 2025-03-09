import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class EmailService {
  static const String serviceId = 'service_2329r2d';
  static const String templateId = 'template_4ggkiqv';
  static const String userId = 'iftJdd3HapoZq9bzR';

  static Future<void> sendEmail({
    required int totalCost,
    required String fileBase64,
    required String fileName,
    required String fileMimeType,
    required String email,
    required String firstName,
    required String address,
    required LatLng location,
  }) async {
    final requestBody = {
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'totalCost': totalCost.toString(),
        'fileBase64': fileBase64,
        'fileName': fileName,
        'fileMimeType': fileMimeType,
        'email': email,
        'first_name': firstName,
        'address': address,
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
      },
    };

    final response = await http.post(
      Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send email: ${response.body}');
    }
  }
}
