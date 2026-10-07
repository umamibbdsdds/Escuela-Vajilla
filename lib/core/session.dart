import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================
///  Session — estado global del usuario logueado
///  Reemplaza las variables globales sueltas del main.dart original.
///  El rol se normaliza a minúsculas para comparaciones internas.
/// ============================================================

class Session {
  static final Session _instance = Session._internal();
  factory Session() => _instance;
  static Session get instance => _instance;
  Session._internal();

  int? id;
  String? usuario;
  String? _rol; // siempre en minúsculas internamente
  int? mesaId;
  String? token;
  bool _isDarkMode = false;

  bool get isLoggedIn => token != null && id != null;
  bool get isDarkMode => _isDarkMode;

  /// Rol normalizado a minúsculas (ej: 'administrador')
  String? get rol => _rol;

  void login({
    required int id,
    required String usuario,
    required String rol,
    required String token,
    int? mesaId,
  }) {
    this.id = id;
    this.usuario = usuario;
    _rol = rol.toLowerCase();
    this.token = token;
    this.mesaId = mesaId;
    _persist();
  }

  void logout() {
    id = null;
    usuario = null;
    _rol = null;
    mesaId = null;
    token = null;
    _clearPersist();
  }

  /// Alias para logout
  void limpiar() => logout();

  void setDarkMode(bool value) => _isDarkMode = value;

  // Permisos por rol (comparación en minúsculas)
  bool get isAdmin => _rol == 'administrador';
  bool get isMesero => _rol == 'mesero';
  bool get isCocinero => _rol == 'cocinero';
  bool get isCliente => _rol == 'cliente';
  bool get isInvitado => _rol == 'invitado' || _rol == null;

  // Lista de roles del sistema
  static const List<String> roles = ['Administrador', 'Mesero', 'Cocinero', 'Cliente'];

  // Persistencia ligera en SharedPreferences
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session', jsonEncode({
        'id': id, 'usuario': usuario, 'rol': _rol,
        'token': token, 'mesaId': mesaId, 'darkMode': _isDarkMode,
      }));
    } catch (_) {}
  }

  Future<void> _clearPersist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('session');
    } catch (_) {}
  }

  Future<bool> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('session');
      if (raw == null) return false;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      id = map['id'] as int?;
      usuario = map['usuario'] as String?;
      _rol = map['rol'] as String?;
      token = map['token'] as String?;
      mesaId = map['mesaId'] as int?;
      _isDarkMode = map['darkMode'] as bool? ?? false;
      return isLoggedIn;
    } catch (_) { return false; }
  }
}
