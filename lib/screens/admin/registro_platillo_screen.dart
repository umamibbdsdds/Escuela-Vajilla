import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/api_client.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/tarjeta_platillo.dart';
import '../../widgets/boton_primario.dart';
import '../../widgets/campo_texto.dart';

class RegistroPlatilloScreen extends StatefulWidget {
  const RegistroPlatilloScreen({super.key});
  @override
  State<RegistroPlatilloScreen> createState() => _RegistroPlatilloScreenState();
}

class _RegistroPlatilloScreenState extends State<RegistroPlatilloScreen> {
  List<dynamic> _platillos = [];
  List<dynamic> _categorias = []; // era List<String>, cambiado a List<dynamic>
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      _platillos = await ApiService.getPlatillos();
      _categorias = await ApiService.getCategorias();
      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const IndicadorCarga(mensaje: 'Cargando platillos...');
    if (_error != null) return MensajeError(mensaje: _error!, onReintentar: _cargar);

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          EncabezadoSeccion(
            titulo: 'Platillos',
            subtitulo: '${_platillos.length} registrados',
            trailing: FilledButton.icon(
              onPressed: () => _mostrarDialogoCrear(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Nuevo'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_platillos.isEmpty)
            const EstadoVacio(icono: Icons.restaurant_menu_rounded, mensaje: 'Aún no hay platillos', submensaje: 'Agrega el primer platillo')
          else
            ..._platillos.map((p) => _buildPlatilloItem(p)),
        ],
      ),
    );
  }

  Widget _buildPlatilloItem(Map<String, dynamic> p) {
    final disponible = p['disponible'] == true || p['disponible'] == 1;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: p['imagen'] != null && p['imagen'].toString().isNotEmpty
                ? Image.network(ApiClient.imageUrl(p['imagen'].toString()),
                    width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                : _placeholder(),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['nombre'] ?? '', style: AppTypography.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(p['categoria'] ?? '', style: AppTypography.label),
                  if (!disponible) Text('AGOTADO', style: AppTypography.overline.copyWith(color: AppColors.error)),
                ],
              ),
            ),
            Text('\$${(double.tryParse(p['precio']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}',
              style: AppTypography.subtitleWith(AppColors.primary)),
            const SizedBox(width: AppSpacing.sm),
            Switch.adaptive(
              value: disponible,
              activeColor: AppColors.success,
              onChanged: (v) async {
                try {
                  await ApiService.setDisponibilidad(p['id'], v);
                  _cargar();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: () => _mostrarDialogoEditar(p),
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded, size: 20, color: AppColors.error),
              onPressed: () => _confirmarEliminar(p),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _placeholder() => Container(
    width: 60, height: 60,
    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(AppRadius.md)),
    child: const Icon(Icons.fastfood_rounded, color: AppColors.primaryLight, size: 24),
  );

  void _mostrarDialogoCrear({Map<String, dynamic>? existente}) {
    final nombreCtrl = TextEditingController(text: existente?['nombre'] ?? '');
    final descCtrl = TextEditingController(text: existente?['descripcion'] ?? '');
    final precioCtrl = TextEditingController(text: existente?['precio']?.toString() ?? '');
    String? categoria = existente?['categoria'] ?? 'Platos Fuertes';
    bool disponible = existente?['disponible'] == true || existente?['disponible'] == 1 || existente == null;
    final esEdicion = existente != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(esEdicion ? 'Editar platillo' : 'Nuevo platillo', style: AppTypography.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampoTexto(label: 'Nombre', controller: nombreCtrl, prefixIcon: Icons.restaurant_rounded),
                const SizedBox(height: AppSpacing.md),
                CampoTexto(label: 'Descripción', controller: descCtrl, prefixIcon: Icons.description_rounded, maxLines: 3),
                const SizedBox(height: AppSpacing.md),
                CampoTexto(label: 'Precio', controller: precioCtrl, prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: categoria,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: _categorias.map((c) => DropdownMenuItem(value: c.toString(), child: Text(c.toString()))).toList()
                    ..add(const DropdownMenuItem(value: 'Platos Fuertes', child: Text('Platos Fuertes'))),
                  onChanged: (v) => setState(() => categoria = v),
                ),
                const SizedBox(height: AppSpacing.md),
                SwitchListTile.adaptive(
                  title: const Text('Disponible'),
                  value: disponible,
                  activeColor: AppColors.success,
                  onChanged: (v) => setState(() => disponible = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (nombreCtrl.text.trim().isEmpty || precioCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre y precio son obligatorios')),
                  );
                  return;
                }
                final body = {
                  'nombre': nombreCtrl.text.trim(),
                  'descripcion': descCtrl.text.trim(),
                  'precio': double.tryParse(precioCtrl.text) ?? 0.0,
                  'categoria': categoria ?? 'Platos Fuertes',
                  'disponible': disponible,
                };
                try {
                  if (esEdicion) {
                    await ApiService.updatePlatillo(existente!['id'], body);
                  } else {
                    await ApiService.createPlatillo(body);
                  }
                  if (mounted) {
                    Navigator.pop(ctx);
                    _cargar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(esEdicion ? 'Platillo actualizado' : 'Platillo creado')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text(esEdicion ? 'Guardar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoEditar(Map<String, dynamic> p) => _mostrarDialogoCrear(existente: p);

  void _confirmarEliminar(Map<String, dynamic> p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar platillo?'),
        content: Text('Se eliminará "${p['nombre']}" de forma permanente.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              try {
                await ApiService.deletePlatillo(p['id']);
                if (mounted) {
                  Navigator.pop(ctx);
                  _cargar();
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
