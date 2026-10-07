import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../core/session.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'cliente/menu_cliente_screen.dart';

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
    switch (rol) {
      case 'administrador':
        Navigator.pushReplacementNamed(context, '/admin');
        break;
      case 'mesero':
        Navigator.pushReplacementNamed(context, '/mesero');
        break;
      case 'cocinero':
        Navigator.pushReplacementNamed(context, '/cocina');
        break;
      case 'cliente':
        Navigator.pushReplacementNamed(context, '/cliente');
        break;
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MenuClienteScreen()),
        );
    }
  }

  void _entrarComoInvitado() {
    Session.instance.logout();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. FONDO R (assets/icon/fondoR.png)
          Positioned.fill(
            child: Image.asset(
              'assets/icon/fondoR.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Capa oscura de sobreposición
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.40),
            ),
          ),

          // 2. CONTENIDO PRINCIPAL CON LOGO Y FORMULARIO
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // LOGO TRANSPARENTE (assets/icon/UMAMI_Logo_transparente.png)
                  Image.asset(
                    'assets/icon/UMAMI_Logo_transparente.png',
                    height: 125,
                  ),
                  const SizedBox(height: 10),

                  // Subtítulo
                  Text(
                    'GESTIÓN DE RESTAURANTES',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Tarjeta Glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: size.width > 480 ? 390 : size.width * 0.88,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22.0,
                          vertical: 28.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Campo Usuario
                            TextField(
                              controller: usuarioCtrl,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Usuario',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white.withOpacity(0.65),
                                  size: 20,
                                ),
                                errorText: _errorUsuario,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.06),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.orangeAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Campo Contraseña
                            TextField(
                              controller: claveCtrl,
                              obscureText: _ocultarClave,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Contraseña',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 13,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.white.withOpacity(0.65),
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _ocultarClave
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.white.withOpacity(0.65),
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _ocultarClave = !_ocultarClave),
                                ),
                                errorText: _errorClave,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.06),
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.25),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.orangeAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Botón Iniciar Sesión (Naranja)
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: ElevatedButton(
                                onPressed: _cargando ? null : _validarYLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6600),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: _cargando
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Enlace secundario
                            GestureDetector(
                              onTap: _entrarComoInvitado,
                              child: Text(
                                'Explorar Menú sin Iniciar Sesión →',
                                style: TextStyle(
                                  color: Colors.amber[300],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Pie de página
                  Text(
                    'Powered by Flutter',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
