import 'dart:async';
import '../core/session.dart';

/// ============================================================
///  PollingService — Timer.periodic genérico a 5 s
///  Preparado para migrar a WebSocket sin cambiar la UI
/// ============================================================

typedef PollCallback = Future<void> Function();

class PollingService {
  static const Duration interval = Duration(seconds: 5);
  Timer? _timer;
  PollCallback? _callback;
  bool _running = false;

  bool get isRunning => _running;

  void start(PollCallback callback) {
    if (_running) return;
    _callback = callback;
    _running = true;
    // Ejecutar inmediatamente, luego cada 5 s
    _callback?.call();
    _timer = Timer.periodic(interval, (_) {
      if (Session().isLoggedIn || Session().isInvitado) {
        _callback?.call();
      }
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  void restart(PollCallback callback) {
    stop();
    start(callback);
  }

  void dispose() {
    stop();
    _callback = null;
  }
}
