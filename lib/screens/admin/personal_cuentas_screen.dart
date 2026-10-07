import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/session.dart';
import '../../models/usuario_model.dart';
import '../../services/api_service.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/boton_primario.dart';
import '../../widgets/campo_texto.dart';

/// ============================================================
///  PersonalCuentasScreen — CRUD de usuarios desde el admin
///  Crear, editar, activar/desactivar (sin borrar)
/// ============================================================
class PersonalCuentasScreen extends StatefulWidget {
  const PersonalCuentasScreen({super.key});
  @override
  State<PersonalCuentasScreen> createState() => _PersonalCuentasScreenState();
}

class _PersonalCuentasScreenState extends State<PersonalCuentasScreen> {
  List<UsuarioModel> _usuarios = [];
  bool _cargando = true;
  String? _error;
  String _filtroRol = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final data = await ApiService.getAdminUsuarios();
      _usuarios = data.map((e) => UsuarioModel.fromJson(e)).toList();
      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  List<UsuarioModel> get _filtrados => _filtroRol == 'Todos'
    ? _usuarios
    : _usuarios.where((u) => u.rol == _filtroRol).toList();

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const IndicadorCarga(mensaje: 'Cargando personal...');
    if (_error != null) return MensajeError(mensaje: _error!, onReintentar: _cargar);

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          EncabezadoSeccion(
            titulo: 'Personal y cuentas',
            subtitulo: '${_usuarios.length} usuarios registrados',
            trailing: FilledButton.icon(
              onPressed: () => _mostrarDialogoCrear(),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Nuevo'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todos', ...Session.roles].map((r) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: FilterChip(
                  label: Text(r),
                  selected: _filtroRol == r,
                  onSelected: (_) => setState(() => _filtroRol = r),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Lista
          if (_filtrados.isEmpty)
            const EstadoVacio(icono: Icons.people_outline_rounded, mensaje: 'No hay usuarios para este filtro')
          else
            ..._filtrados.map((u) => _buildUserCard(u)),
        ],
      ),
    );
  }

  Widget _buildUserCard(UsuarioModel u) {
    final colorRol = _colorRol(u.rol);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Avatar con inicial
            CircleAvatar(
              backgroundColor: colorRol.withOpacity(0.15),
              child: Text(u.usuario[0].toUpperCase(), style: AppTypography.subtitleWith(colorRol)),
            ),
            const SizedBox(width: AppSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.usuario, style: AppTypography.subtitle),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorRol.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(u.rol, style: AppTypography.overline.copyWith(color: colorRol)),
                      ),
                      if (u.rol == 'Cliente' && u.mesaId != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text('Mesa ${u.mesaId}', style: AppTypography.label),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Estado activo/inactivo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
              decoration: BoxDecoration(
                color: u.activo ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(u.activo ? 'Activo' : 'Inactivo',
                style: AppTypography.overline.copyWith(color: u.activo ? AppColors.success : AppColors.error),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Acciones
            PopupMenuButton<String>(
              onSelected: (action) => _handleAction(action, u),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'editar', child: Text('Editar')),
                const PopupMenuItem(value: 'restablecer', child: Text('Restablecer contraseña')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(u.activo ? 'Desactivar cuenta' : 'Activar cuenta'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorRol(String rol) {
    switch (rol) {
      case 'Administrador': return AppColors.primary;
      case 'Mesero': return AppColors.info;
      case 'Cocinero': return AppColors.warning;
      case 'Cliente': return AppColors.success;
      default: return AppColors.neutral;
    }
  }

  void _handleAction(String action, UsuarioModel u) async {
    if (action == 'editar') {
      _mostrarDialogoEditar(u);
    } else if (action == 'restablecer') {
      _mostrarDialogoRestablecer(u);
    } else if (action == 'toggle') {
      _confirmarToggle(u);
    }
  }

  // ==================== DIÁLOGO CREAR ====================
  void _mostrarDialogoCrear() {
    final usuarioCtrl = TextEditingController();
    final claveCtrl = TextEditingController();
    String rolSeleccionado = 'Mesero';
    int? mesaIdSeleccionada;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Crear nuevo usuario', style: AppTypography.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampoTexto(label: 'Nombre de usuario', controller: usuarioCtrl, prefixIcon: Icons.person_rounded),
                const SizedBox(height: AppSpacing.md),
                CampoTexto(label: 'Contraseña (mín. 4)', controller: claveCtrl, prefixIcon: Icons.lock_rounded, ocultar: true),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: rolSeleccionado,
                  decoration: const InputDecoration(labelText: 'Rol', prefixIcon: Icon(Icons.badge_rounded)),
                  items: Session.roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setDialogState(() => rolSeleccionado = v ?? 'Mesero'),
                ),
                if (rolSeleccionado == 'Cliente') ...[
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<int>(
                    value: mesaIdSeleccionada,
                    decoration: const InputDecoration(labelText: 'Mesa asignada', prefixIcon: Icon(Icons.table_restaurant_rounded)),
                    items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('Mesa ${i + 1}'))),
                    onChanged: (v) => setDialogState(() => mesaIdSeleccionada = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                if (usuarioCtrl.text.trim().isEmpty || claveCtrl.text.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verifica los datos')),
                  );
                  return;
                }
                try {
                  await ApiService.createAdminUsuario({
                    'usuario': usuarioCtrl.text.trim(),
                    'clave': claveCtrl.text,
                    'rol': rolSeleccionado,
                    'mesa_id': rolSeleccionado == 'Cliente' ? mesaIdSeleccionada : null,
                  });
                  if (mounted) {
                    Navigator.pop(ctx);
                    _cargar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario creado exitosamente')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DIÁLOGO EDITAR ====================
  void _mostrarDialogoEditar(UsuarioModel u) {
    final usuarioCtrl = TextEditingController(text: u.usuario);
    String rolSeleccionado = u.rol;
    int? mesaIdSeleccionada = u.mesaId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Editar usuario', style: AppTypography.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CampoTexto(label: 'Nombre de usuario', controller: usuarioCtrl, prefixIcon: Icons.person_rounded),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  value: rolSeleccionado,
                  decoration: const InputDecoration(labelText: 'Rol', prefixIcon: Icon(Icons.badge_rounded)),
                  items: Session.roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setDialogState(() => rolSeleccionado = v ?? u.rol),
                ),
                if (rolSeleccionado == 'Cliente') ...[
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<int>(
                    value: mesaIdSeleccionada,
                    decoration: const InputDecoration(labelText: 'Mesa asignada', prefixIcon: Icon(Icons.table_restaurant_rounded)),
                    items: List.generate(8, (i) => DropdownMenuItem(value: i + 1, child: Text('Mesa ${i + 1}'))),
                    onChanged: (v) => setDialogState(() => mesaIdSeleccionada = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () async {
                try {
                  await ApiService.updateAdminUsuario(u.id, {
                    'usuario': usuarioCtrl.text.trim(),
                    'rol': rolSeleccionado,
                    'mesa_id': rolSeleccionado == 'Cliente' ? mesaIdSeleccionada : null,
                  });
                  if (mounted) {
                    Navigator.pop(ctx);
                    _cargar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Usuario actualizado')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== RESTABLECER CONTRASEÑA ====================
  void _mostrarDialogoRestablecer(UsuarioModel u) {
    final claveCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Restablecer contraseña', style: AppTypography.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Usuario: ${u.usuario}', style: AppTypography.body),
            const SizedBox(height: AppSpacing.lg),
            CampoTexto(label: 'Nueva contraseña (mín. 4)', controller: claveCtrl, prefixIcon: Icons.lock_rounded, ocultar: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (claveCtrl.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La contraseña debe tener al menos 4 caracteres')),
                );
                return;
              }
              try {
                await ApiService.updateAdminUsuario(u.id, {
                  'usuario': u.usuario,
                  'clave': claveCtrl.text,
                  'rol': u.rol,
                  'mesa_id': u.mesaId,
                });
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña restablecida')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  // ==================== CONFIRMAR TOGGLE ACTIVO ====================
  void _confirmarToggle(UsuarioModel u) {
    final accion = u.activo ? 'desactivar' : 'activar';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('¿${u.activo ? 'Desactivar' : 'Activar'} cuenta?'),
        content: Text(
          '¿Estás seguro de que deseas $accion la cuenta de ${u.usuario}?\n'
          '${u.activo ? 'No podrá iniciar sesión hasta que se reactive.' : 'Podrá iniciar sesión de nuevo.'}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: u.activo ? AppColors.error : AppColors.success,
            ),
            onPressed: () async {
              try {
                await ApiService.toggleAdminUsuarioActivo(u.id, !u.activo);
                if (mounted) {
                  Navigator.pop(ctx);
                  _cargar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cuenta ${u.activo ? 'desactivada' : 'activada'}')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: Text(u.activo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }
}
