import 'dart:async';
import '../core/session.dart';

/// ============================================================
///  PollingService — Timer.periodic genérico a 5 s
///  API estática para usarse como PollingService.start() y .stop()
/// ============================================================

typedef PollCallback = Future<void> Function(Timer);

class PollingService {
  static const Duration interval = Duration(seconds: 5);
  static Timer? _timer;
  static bool _running = false;

  static bool get isRunning => _running;

  /// Inicia el polling. segundos: intervalo, callback: función a ejecutar
  static void start(int segundos, void Function(Timer) callback) {
    if (_running) return;
    _running = true;
    // Ejecutar inmediatamente al inicio
    callback(Timer(Duration.zero, () {}));
    _timer = Timer.periodic(Duration(seconds: segundos), (t) {
      if (Session.instance.isLoggedIn || Session.instance.isInvitado) {
        callback(t);
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  static void restart(int segundos, void Function(Timer) callback) {
    stop();
    start(segundos, callback);
  }
}
