import 'package:flutter/material.dart';
import '../core/session.dart';

/// ============================================================
///  RoleGuard — widget que oculta/muestra hijos según rol
///  Nada se borra: lo que no corresponda al rol se oculta.
/// ============================================================

class RoleGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final session = Session();
    if (session.rol != null && allowedRoles.contains(session.rol)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

/// Extensión para envolver rutas completas
class RoleRouteGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;
  final Widget loginScreen;

  const RoleRouteGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    required this.loginScreen,
  });

  @override
  Widget build(BuildContext context) {
    final session = Session();
    if (!session.isLoggedIn && !session.isInvitado) return loginScreen;
    if (session.isInvitado && !allowedRoles.contains('Invitado')) {
      // Invitado solo ve rutas explícitamente permitidas
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso restringido')),
        body: Center(
          child: Text('No tienes permiso para ver esta sección.',
            style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }
    if (session.rol != null && !allowedRoles.contains(session.rol)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Acceso restringido')),
        body: Center(
          child: Text('Tu rol (${session.rol}) no tiene acceso a esta sección.',
            style: Theme.of(context).textTheme.bodyLarge),
        ),
      );
    }
    return child;
  }
}
