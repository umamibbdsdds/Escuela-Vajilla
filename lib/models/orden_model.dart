/// ============================================================
///  OrdenModel — incluye estado, mesa, códigos
/// ============================================================

class DetalleOrdenModel {
  final int? id;
  final int platilloId;
  final String nombrePlatillo;
  final int cantidad;
  final double precio;
  final double subtotal;
  final String nota;

  DetalleOrdenModel({
    this.id,
    required this.platilloId,
    required this.nombrePlatillo,
    required this.cantidad,
    required this.precio,
    required this.subtotal,
    this.nota = '',
  });

  factory DetalleOrdenModel.fromJson(Map<String, dynamic> json) => DetalleOrdenModel(
    id: json['id'] as int?,
    platilloId: json['platillo_id'] as int? ?? json['platilloId'] as int? ?? 0,
    nombrePlatillo: json['nombre'] as String? ?? '',
    cantidad: json['cantidad'] as int? ?? 1,
    precio: (json['precio'] is double)
        ? json['precio']
        : double.tryParse(json['precio'].toString()) ?? 0.0,
    subtotal: (json['subtotal'] is double)
        ? json['subtotal']
        : double.tryParse(json['subtotal'].toString()) ?? 0.0,
    nota: json['nota'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'platillo_id': platilloId,
    'nombre': nombrePlatillo,
    'cantidad': cantidad,
    'precio': precio,
    'subtotal': subtotal,
    'nota': nota,
  };
}

class OrdenModel {
  final int id;
  final String? codigoPedido;
  final String? codigoEntrega;
  final String estado; // recibido, preparando, listo, entregado, cancelado
  final int? mesaId;
  final int? meseroId;
  final int? clienteId;
  final double total;
  final int intentosCodigo;
  final String? canceladoPor;
  final String? motivoCancelacion;
  final DateTime? createdAt;
  final DateTime? fecha; // alias de createdAt para compatibilidad con cola_cocina
  final List<DetalleOrdenModel> detalles;
  final int? mesaNumero;
  final String? meseroNombre;

  OrdenModel({
    required this.id,
    this.codigoPedido,
    this.codigoEntrega,
    this.estado = 'recibido',
    this.mesaId,
    this.meseroId,
    this.clienteId,
    this.total = 0,
    this.intentosCodigo = 0,
    this.canceladoPor,
    this.motivoCancelacion,
    this.createdAt,
    this.fecha,
    this.detalles = const [],
    this.mesaNumero,
    this.meseroNombre,
  });

  factory OrdenModel.fromJson(Map<String, dynamic> json) {
    List<DetalleOrdenModel> detallesList = [];
    if (json['detalles'] != null && json['detalles'] is List) {
      detallesList = (json['detalles'] as List)
          .map((d) => DetalleOrdenModel.fromJson(d as Map<String, dynamic>))
          .toList();
    }
    final creado = json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null;
    return OrdenModel(
      id: json['id'] as int,
      codigoPedido: json['codigo_pedido'] as String?,
      codigoEntrega: json['codigo_entrega'] as String?,
      estado: (json['estado'] as String?) ?? 'recibido',
      mesaId: json['mesa_id'] as int?,
      meseroId: json['mesero_id'] as int?,
      clienteId: json['cliente_id'] as int?,
      total: (json['total'] is double)
          ? json['total']
          : double.tryParse(json['total'].toString()) ?? 0.0,
      intentosCodigo: json['intentos_codigo'] as int? ?? 0,
      canceladoPor: json['cancelado_por'] as String?,
      motivoCancelacion: json['motivo_cancelacion'] as String?,
      createdAt: creado,
      fecha: creado, // mismo valor, dos nombres
      detalles: detallesList,
      mesaNumero: json['mesa_numero'] as int?,
      meseroNombre: json['mesero_nombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'codigo_pedido': codigoPedido,
    'codigo_entrega': codigoEntrega,
    'estado': estado,
    'mesa_id': mesaId,
    'total': total,
    'detalles': detalles.map((d) => d.toJson()).toList(),
  };
}

class MesaModel {
  final int id;
  final int numero;
  final String estado;
  final int? meseroId;
  final String? meseroNombre;
  final int pedidosActivos;

  MesaModel({
    required this.id,
    required this.numero,
    this.estado = 'libre',
    this.meseroId,
    this.meseroNombre,
    this.pedidosActivos = 0,
  });

  factory MesaModel.fromJson(Map<String, dynamic> json) => MesaModel(
    id: json['id'] as int,
    numero: json['numero'] as int? ?? json['id'] as int,
    estado: (json['estado'] as String?) ?? 'libre',
    meseroId: json['mesero_id'] as int?,
    meseroNombre: json['mesero_nombre'] as String?,
    pedidosActivos: json['pedidos_activos'] as int? ?? 0,
  );
}

class AlertaModel {
  final int id;
  final String tipo;
  final String mensaje;
  final bool leida;
  final int? mesaId;
  final int? ordenId;
  final int? mesaNumero;
  final DateTime? createdAt;

  AlertaModel({
    required this.id,
    required this.tipo,
    required this.mensaje,
    this.leida = false,
    this.mesaId,
    this.ordenId,
    this.mesaNumero,
    this.createdAt,
  });

  factory AlertaModel.fromJson(Map<String, dynamic> json) => AlertaModel(
    id: json['id'] as int,
    tipo: json['tipo'] as String? ?? 'otro',
    mensaje: json['mensaje'] as String? ?? '',
    leida: (json['leida'] is int) ? json['leida'] == 1 : json['leida'] == true,
    mesaId: json['mesa_id'] as int?,
    ordenId: json['orden_id'] as int?,
    mesaNumero: json['mesa_numero'] as int?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
  );
}
