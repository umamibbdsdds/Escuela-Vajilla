import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/boton_primario.dart';
import '../../widgets/boton_secundario.dart';

/// ============================================================
///  EntregaCodigoScreen — Input de código de entrega grande
///  Teclado numérico grande para escena de restaurante
/// ============================================================
class EntregaCodigoScreen extends StatefulWidget {
  final int mesaId;
  const EntregaCodigoScreen({super.key, required this.mesaId});
  @override
  State<EntregaCodigoScreen> createState() => _EntregaCodigoScreenState();
}

class _EntregaCodigoScreenState extends State<EntregaCodigoScreen> {
  String _codigo = '';
  bool _confirmando = false;
  String? _mensaje;
  bool _exito = false;

  void _agregarDigito(String d) {
    if (_codigo.length < 4) setState(() => _codigo += d);
  }

  void _borrar() {
    if (_codigo.isNotEmpty) setState(() => _codigo = _codigo.substring(0, _codigo.length - 1));
  }

  Future<void> _confirmar() async {
    if (_codigo.length < 4) return;
    setState(() { _confirmando = true; _mensaje = null; });
    try {
      await ApiService.meseroConfirmarEntrega(widget.mesaId, _codigo);
      setState(() { _exito = true; _mensaje = '¡Entrega confirmada!'; });
    } catch (e) {
      setState(() { _mensaje = 'Código incorrecto'; _codigo = ''; });
    } finally {
      setState(() => _confirmando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Entrega — Mesa ${widget.mesaId}')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Spacer(),
            // Código visible
            Text('Ingresa el código de entrega', style: AppTypography.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                width: 56,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: i < _codigo.length ? AppColors.primary.withOpacity(0.12) : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: i < _codigo.length ? AppColors.primary : AppColors.outline,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  i < _codigo.length ? _codigo[i] : '',
                  style: AppTypography.headlineWith(AppColors.primary),
                ),
              )),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_mensaje != null)
              Card(
                color: _exito ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(_mensaje!, style: AppTypography.bodyBold.copyWith(
                    color: _exito ? AppColors.success : AppColors.error,
                  )),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),
            // Teclado numérico
            SizedBox(
              width: 280,
              child: Column(
                children: [
                  for (final row in [['1','2','3'],['4','5','6'],['7','8','9']])
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: row.map((d) => SizedBox(
                          width: 72,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => _agregarDigito(d),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                              textStyle: AppTypography.headline,
                            ),
                            child: Text(d),
                          ),
                        )).toList(),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 56,
                          child: IconButton(
                            onPressed: _borrar,
                            icon: const Icon(Icons.backspace_rounded),
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 72,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () => _agregarDigito('0'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                              textStyle: AppTypography.headline,
                            ),
                            child: const Text('0'),
                          ),
                        ),
                        const SizedBox(width: 72), // espaciador
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Botones acción
            BotonPrimario(
              texto: 'Confirmar entrega',
              onPressed: _codigo.length == 4 && !_confirmando ? _confirmar : null,
              cargando: _confirmando,
            ),
            const SizedBox(height: AppSpacing.sm),
            BotonSecundario(
              texto: 'Cancelar',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
