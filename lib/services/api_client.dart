import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session.dart';

/// ============================================================
///  ApiClient — base HTTP con token, manejo de errores y reintentos
/// ============================================================

class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;
  ApiException(this.mensaje, [this.statusCode]);
  @override
  String toString() => mensaje;
}

class ApiClient {
  static const String defaultBaseUrl = 'https://web-production-b4b0c8.up.railway.app';
  static String baseUrl = defaultBaseUrl;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (Session().token != null) 'Authorization': 'Bearer ${Session().token}',
  };

  // ---------- GET ----------
  static Future<dynamic> get(String path, {int retryCount = 1}) async {
    final url = Uri.parse('$baseUrl$path');
    for (int attempt = 0; attempt <= retryCount; attempt++) {
      try {
        final response = await http.get(url, headers: _headers);
        return _handleResponse(response);
      } on ApiException {
        rethrow;
      } catch (e) {
        if (attempt == retryCount) throw ApiException('Error de conexión: $e');
        await Future.delayed(Duration(seconds: attempt + 1));
      }
    }
  }

  // ---------- POST ----------
  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.post(url, headers: _headers, body: jsonEncode(body));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  // ---------- PUT ----------
  static Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.put(url, headers: _headers, body: jsonEncode(body));
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  // ---------- DELETE ----------
  static Future<dynamic> delete(String path) async {
    final url = Uri.parse('$baseUrl$path');
    try {
      final response = await http.delete(url, headers: _headers);
      return _handleResponse(response);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Error de conexión: $e');
    }
  }

  // ---------- Manejo de respuesta ----------
  static dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    if (response.statusCode == 401) {
      Session().logout();
      throw ApiException('Sesión expirada. Inicie sesión de nuevo.', 401);
    }
    if (response.statusCode == 403) {
      throw ApiException(body['mensaje'] ?? 'Acceso denegado', 403);
    }
    throw ApiException(
      body['mensaje'] ?? 'Error del servidor (${response.statusCode})',
      response.statusCode,
    );
  }

  // ---------- Imágenes ----------
  static String imageUrl(String filename) => '$baseUrl/uploads/$filename';
}
