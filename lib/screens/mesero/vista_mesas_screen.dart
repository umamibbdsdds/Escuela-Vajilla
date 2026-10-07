import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/session.dart';
import '../../services/api_service.dart';
import '../../services/polling_service.dart';
import '../../models/orden_model.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/tarjeta_mesa.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/boton_secundario.dart';
import 'entrega_codigo_screen.dart';

class VistaMesasScreen extends StatefulWidget {
  const VistaMesasScreen({super.key});
  @override
  State<VistaMesasScreen> createState() => _VistaMesasScreenState();
}

class _VistaMesasScreenState extends State<VistaMesasScreen> {
  List<MesaModel> _mesas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
    PollingService.start(5, (_) => _cargar());
  }

  @override
  void dispose() {
    PollingService.stop();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final data = await ApiService.getMeseroMesas();
      final models = (data as List).map((m) => MesaModel.fromJson(m)).toList();
      if (mounted) setState(() { _mesas = models; _cargando = false; });
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  void _entregar(int mesaId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EntregaCodigoScreen(mesaId: mesaId)));
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando && _mesas.isEmpty) return const IndicadorCarga(mensaje: 'Cargando mesas...');
    if (_error != null) return MensajeError(mensaje: _error!, onReintentar: _cargar);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis mesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _cargar,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: _mesas.isEmpty
            // Quitado 'const' — AppTypography.body no es constante
            ? Center(child: Text('No tienes mesas asignadas', style: AppTypography.body))
            : GridView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.0,
                ),
                itemCount: _mesas.length,
                itemBuilder: (_, i) {
                  final m = _mesas[i];
                  return TarjetaMesa(
                    mesa: m,
                    onTap: m.estado == 'lista' ? () => _entregar(m.id) : null,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cargar,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Actualizar'),
      ),
    );
  }
}
