/// ============================================================
///  PlatilloModel
/// ============================================================

class PlatilloModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String categoria;
  final String? imagen;
  final String? imagenUrl; // alias para compatibilidad con tarjeta_platillo y carrito
  final bool disponible;

  PlatilloModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.precio,
    this.categoria = 'Platos Fuertes',
    this.imagen,
    this.imagenUrl,
    this.disponible = true,
  });

  factory PlatilloModel.fromJson(Map<String, dynamic> json) {
    final img = json['imagen'] as String?;
    return PlatilloModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      precio: (json['precio'] is double)
          ? json['precio']
          : double.tryParse(json['precio'].toString()) ?? 0.0,
      categoria: (json['categoria'] as String?) ?? 'Platos Fuertes',
      imagen: img,
      imagenUrl: img, // mismo valor, dos nombres
      disponible: (json['disponible'] is int)
          ? json['disponible'] == 1
          : json['disponible'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'precio': precio,
    'categoria': categoria,
    'imagen': imagen,
    'disponible': disponible,
  };
}
