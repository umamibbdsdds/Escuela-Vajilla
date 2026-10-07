import '../core/session.dart';
import 'api_client.dart';

/// ============================================================
///  AuthService — login, logout, verificación de sesión
/// ============================================================

class AuthService {
  static Future<bool> login(String usuario, String clave) async {
    try {
      final data = await ApiClient.post('/api/login', {
        'usuario': usuario,
        'clave': clave,
      });

      if (data['status'] == 'ok') {
        final u = data['usuario'];
        Session.instance.login(
          id: u['id'] as int,
          usuario: u['usuario'] as String,
          rol: u['rol'] as String,
          token: data['token'] as String,
          mesaId: u['mesa_id'] as int?,
        );
        return true;
      }
      return false;
    } on ApiException {
      rethrow;
    }
  }

  static Future<void> logout() async {
    try {
      await ApiClient.post('/api/logout', {});
    } catch (_) {}
    Session.instance.logout();
  }

  static Future<Map<String, dynamic>?> me() async {
    try {
      final data = await ApiClient.get('/api/me');
      if (data['status'] == 'ok') return data['usuario'] as Map<String, dynamic>;
      return null;
    } catch (_) {
      return null;
    }
  }
}
