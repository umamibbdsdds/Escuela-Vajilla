import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../core/session.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../widgets/campo_texto.dart';
import '../widgets/boton_primario.dart';
import '../widgets/boton_secundario.dart';
import 'admin/admin_drawer.dart';
import 'cliente/menu_cliente_screen.dart';

/// ============================================================
///  LoginScreen — Glassmorphism profesional con validación
/// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usuarioCtrl = TextEditingController();
  final claveCtrl = TextEditingController();
  bool _ocultarClave = true;
  bool _cargando = false;
  String? _errorUsuario;
  String? _errorClave;

  @override
  void dispose() {
    usuarioCtrl.dispose();
    claveCtrl.dispose();
    super.dispose();
  }

  void _validarYLogin() async {
    setState(() {
      _errorUsuario = usuarioCtrl.text.trim().isEmpty ? 'Ingresa tu usuario' : null;
      _errorClave = claveCtrl.text.isEmpty ? 'Ingresa tu contraseña' : null;
    });
    if (_errorUsuario != null || _errorClave != null) return;

    setState(() => _cargando = true);
    try {
      final ok = await AuthService.login(usuarioCtrl.text.trim(), claveCtrl.text);
      if (!mounted) return;
      if (ok) {
        _navegarSegunRol();
      } else {
        _mostrarSnackBar('Credenciales inválidas');
      }
    } on ApiException catch (e) {
      _mostrarSnackBar(e.mensaje);
    } catch (e) {
      _mostrarSnackBar('Error al conectar con el servidor');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _navegarSegunRol() {
    final rol = Session.instance.rol ?? 'invitado';
      'administrador' => Navigator.pushReplacementNamed(context, '/admin'),
      'mesero' => Navigator.pushReplacementNamed(context, '/mesero'),
      'cocinero' => Navigator.pushReplacementNamed(context, '/cocina'),
      'cliente' => Navigator.pushReplacementNamed(context, '/cliente'),
      _ => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MenuClienteScreen())),
  }

  void _entrarComoInvitado() {
    Session.instance.logout();
    // El invitado ve el menú sin sesión
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MenuClienteScreen()),
    );
  }

  void _mostrarSnackBar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con imagen
          Positioned.fill(
            child: Image.asset(
              'assets/icon/fondoR.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: AppColors.appBar),
            ),
          ),
          // Capa oscura
          Positioned.fill(
            child: Container(color: AppColors.overlay),
          ),
          // Contenido
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  // Logo
                  Image.asset(
                    'assets/icon/UMAMI_Logo_transparente.png',
                    height: 110,
                    errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_rounded, size: 80, color: AppColors.primaryLight),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('GESTIÓN DE RESTAURANTES',
                    style: AppTypography.overline.copyWith(color: Colors.white.withOpacity(0.85), letterSpacing: 2.0),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Tarjeta glassmorphic
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        width: size.width > 500 ? 420 : size.width * 0.9,
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Iniciar Sesión', style: AppTypography.title.copyWith(color: Colors.white)),
                            const SizedBox(height: AppSpacing.xl),
                            // Campo usuario
                            TextField(
                              controller: usuarioCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Usuario',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(Icons.person_rounded, color: Colors.white.withOpacity(0.7)),
                                errorText: _errorUsuario,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Campo clave
                            TextField(
                              controller: claveCtrl,
                              obscureText: _ocultarClave,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                prefixIcon: Icon(Icons.lock_rounded, color: Colors.white.withOpacity(0.7)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _ocultarClave ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  onPressed: () => setState(() => _ocultarClave = !_ocultarClave),
                                ),
                                errorText: _errorClave,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            // Botón login
                            BotonPrimario(
                              texto: 'Ingresar',
                              icono: Icons.login_rounded,
                              cargando: _cargando,
                              onPressed: _validarYLogin,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Invitado
                            BotonSecundario(
                              texto: 'Ver menú como invitado',
                              icono: Icons.visibility_rounded,
                              onPressed: _entrarComoInvitado,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
