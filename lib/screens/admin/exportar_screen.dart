import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';

class ExportarScreen extends StatefulWidget {
  const ExportarScreen({super.key});
  @override
  State<ExportarScreen> createState() => _ExportarScreenState();
}

class _ExportarScreenState extends State<ExportarScreen> {
  String _tipo = 'ordenes';
  List<dynamic>? _datos;
  bool _cargando = false;
  String? _error;

  Future<void> _exportar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      _datos = await ApiService.getExport(_tipo);
      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        EncabezadoSeccion(titulo: 'Exportar datos'),
        const SizedBox(height: AppSpacing.md),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'ordenes', label: Text('Órdenes'), icon: Icon(Icons.receipt_long_rounded)),
            ButtonSegment(value: 'meseros', label: Text('Meseros'), icon: Icon(Icons.person_rounded)),
            ButtonSegment(value: 'clientes', label: Text('Clientes'), icon: Icon(Icons.group_rounded)),
          ],
          selected: {_tipo},
          onSelectionChanged: (s) => setState(() { _tipo = s.first; _datos = null; }),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: _cargando ? null : _exportar,
          icon: const Icon(Icons.file_download_rounded),
          label: const Text('Exportar'),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_cargando) const IndicadorCarga(),
        if (_error != null) MensajeError(mensaje: _error!, onReintentar: _exportar),
        if (_datos != null && _datos!.isNotEmpty)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
              columns: (_datos!.first as Map).keys.map((k) => DataColumn(label: Text(k.toString(), style: AppTypography.caption))).toList(),
              rows: _datos!.map((row) => DataRow(cells: (row as Map).values.map((v) => DataCell(Text(v.toString(), style: AppTypography.body))).toList())).toList(),
            ),
          ),
      ],
    );
  }
}
