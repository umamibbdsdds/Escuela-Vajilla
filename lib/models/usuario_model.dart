/// ============================================================
///  UsuarioModel
/// ============================================================

class UsuarioModel {
  final int id;
  final String usuario;
  final String rol;
  final int? mesaId;
  final bool activo;

  UsuarioModel({
    required this.id,
    required this.usuario,
    required this.rol,
    this.mesaId,
    this.activo = true,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
    id: json['id'] as int,
    usuario: json['usuario'] as String,
    rol: json['rol'] as String,
    mesaId: json['mesa_id'] as int?,
    activo: (json['activo'] is int) ? json['activo'] == 1 : json['activo'] == true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'usuario': usuario,
    'rol': rol,
    'mesa_id': mesaId,
    'activo': activo,
  };

  String get rolDisplay {
    switch (rol) {
      case 'Administrador': return 'Administrador';
      case 'Mesero': return 'Mesero';
      case 'Cocinero': return 'Cocinero';
      case 'Cliente': return 'Cliente (Mesa ${mesaId ?? '?'})';
      default: return rol;
    }
  }
}
