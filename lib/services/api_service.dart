import '../models/platillo_model.dart';
import '../models/orden_model.dart';
import '../models/usuario_model.dart';
import 'api_client.dart';

/// ============================================================
///  ApiService — todas las llamadas de negocio
///  Capa preparada para polling 5s → WebSocket después
/// ============================================================

class ApiService {
  // ==================== PLATILLOS ====================
  static Future<List<dynamic>> getPlatillos() async {
    return await ApiClient.get('/api/platillos');
  }

  static Future<void> createPlatillo(Map<String, dynamic> body) async {
    await ApiClient.post('/api/platillos', body);
  }

  static Future<void> updatePlatillo(int id, Map<String, dynamic> body) async {
    await ApiClient.put('/api/platillos/$id', body);
  }

  static Future<void> deletePlatillo(int id) async {
    await ApiClient.delete('/api/platillos/$id');
  }

  static Future<void> setDisponibilidad(int id, bool disponible) async {
    await ApiClient.put('/api/platillos/$id/disponibilidad', {'disponible': disponible});
  }

  // ==================== CATEGORÍAS ====================
  static Future<List<dynamic>> getCategorias() async {
    return await ApiClient.get('/api/categorias');
  }

  // ==================== MESAS ====================
  static Future<List<dynamic>> getMesas() async {
    return await ApiClient.get('/api/mesas');
  }

  static Future<void> createMesa(int numero) async {
    await ApiClient.post('/api/mesas', {'numero': numero});
  }

  static Future<void> updateMesa(int id, {int? numero, int? meseroId}) async {
    await ApiClient.put('/api/mesas/$id', {
      'numero': numero,
      'mesero_id': meseroId,
    });
  }

  // ==================== CLIENTE — PEDIDOS ====================
  static Future<Map<String, dynamic>> postClienteOrden(Map<String, dynamic> body) async {
    return await ApiClient.post('/api/cliente/ordenes', body);
  }

  static Future<Map<String, dynamic>?> getClienteOrdenActiva(int mesaId) async {
    final data = await ApiClient.get('/api/cliente/orden-activa/$mesaId');
    if (data['status'] == 'ninguna') return null;
    return data['orden'] ?? data;
  }

  static Future<void> clienteLlamarMesero(int mesaId) async {
    await ApiClient.post('/api/cliente/llamar-mesero', {'mesa_id': mesaId});
  }

  static Future<void> clientePedirCuenta(int mesaId) async {
    await ApiClient.post('/api/cliente/pedir-cuenta', {'mesa_id': mesaId});
  }

  // ==================== COCINA ====================
  static Future<List<dynamic>> getCocinaOrdenes() async {
    return await ApiClient.get('/api/cocina/ordenes');
  }

  static Future<void> putCocinaOrdenEstado(int ordenId, String estado) async {
    await ApiClient.put('/api/cocina/ordenes/$ordenId/estado', {'estado': estado});
  }

  // ==================== MESERO ====================
  static Future<List<dynamic>> getMeseroMesas() async {
    return await ApiClient.get('/api/mesero/mesas');
  }

  static Future<void> meseroConfirmarEntrega(int mesaId, String codigo) async {
    await ApiClient.post('/api/mesero/confirmar-entrega', {
      'mesa_id': mesaId,
      'codigo_entrega': codigo,
    });
  }

  static Future<void> cancelarOrden(int ordenId, {String motivo = ''}) async {
    await ApiClient.put('/api/mesero/ordenes/$ordenId/cancelar', {'motivo': motivo});
  }

  // ==================== ADMIN — USUARIOS ====================
  static Future<List<dynamic>> getAdminUsuarios() async {
    return await ApiClient.get('/api/admin/usuarios');
  }

  static Future<void> createAdminUsuario(Map<String, dynamic> body) async {
    await ApiClient.post('/api/admin/usuarios', body);
  }

  static Future<void> updateAdminUsuario(int id, Map<String, dynamic> body) async {
    await ApiClient.put('/api/admin/usuarios/$id', body);
  }

  static Future<void> toggleAdminUsuarioActivo(int id, bool activo) async {
    await ApiClient.put('/api/admin/usuarios/$id/estado', {'activo': activo});
  }

  // ==================== ALERTAS ====================
  static Future<List<dynamic>> getAlertas() async {
    return await ApiClient.get('/api/alertas');
  }

  static Future<void> markAlertaLeida(int id) async {
    await ApiClient.put('/api/alertas/$id/leer', {});
  }

  static Future<int> getAlertasCount() async {
    final data = await ApiClient.get('/api/alertas/count');
    return data['total'] as int? ?? 0;
  }

  // ==================== ADMIN — RESUMEN ====================
  static Future<Map<String, dynamic>> getAdminResumen() async {
    return await ApiClient.get('/api/admin/resumen');
  }

  // ==================== REPORTES (legacy compat) ====================
  static Future<Map<String, dynamic>> getReporteTotal() async {
    return await ApiClient.get('/reportes/total');
  }

  static Future<Map<String, dynamic>> getReportePromedio() async {
    return await ApiClient.get('/reportes/promedio');
  }

  static Future<List<dynamic>> getReporteMasVendido() async {
    return await ApiClient.get('/reportes/masvendido');
  }

  static Future<Map<String, dynamic>> getReporteMesero(int id) async {
    return await ApiClient.get('/reportes/mesero/$id');
  }

  static Future<Map<String, dynamic>> getReporteCliente(int id) async {
    return await ApiClient.get('/reportes/cliente/$id');
  }

  static Future<List<dynamic>> getAdminReporteMeseros() async {
    return await ApiClient.get('/admin/reporte-meseros');
  }

  static Future<List<dynamic>> getAdminReporteClientes() async {
    return await ApiClient.get('/admin/reporte-clientes');
  }

  // ==================== ESTADÍSTICAS (legacy compat) ====================
  static Future<List<dynamic>> getEstadisticasMeseros() async {
    return await ApiClient.get('/estadisticas/meseros');
  }

  static Future<List<dynamic>> getEstadisticasClientes() async {
    return await ApiClient.get('/estadisticas/clientes');
  }

  // ==================== EXPORTAR (legacy compat) ====================
  static Future<List<dynamic>> getExport(String tipo) async {
    return await ApiClient.get('/export/$tipo');
  }

  // ==================== OPERACIONES (legacy) ====================
  static Future<List<dynamic>> getOperaciones() async {
    return await ApiClient.get('/operaciones');
  }

  static Future<void> createOperacion(Map<String, dynamic> body) async {
    await ApiClient.post('/operaciones', body);
  }

  // ==================== HISTORIAL (legacy) ====================
  static Future<List<dynamic>> getHistorial() async {
    return await ApiClient.get('/historial');
  }

  static Future<List<dynamic>> getOrdenesMesero(int id) async {
    return await ApiClient.get('/ordenes/mesero/$id');
  }

  static Future<List<dynamic>> getOrdenesCliente(int id) async {
    return await ApiClient.get('/ordenes/cliente/$id');
  }

  // ==================== LEGACY — USUARIOS (sin auth) ====================
  static Future<List<dynamic>> getMeserosLegacy() async {
    return await ApiClient.get('/usuarios/meseros');
  }

  static Future<List<dynamic>> getClientesLegacy() async {
    return await ApiClient.get('/usuarios/clientes');
  }
}
