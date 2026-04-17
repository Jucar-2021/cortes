import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/consumoPHP.dart';
import '../api/documentos/consultaDocSumados_api.dart';

class ReporteTarjetas extends StatefulWidget {
  const ReporteTarjetas({
    super.key,
    required this.fechaini,
    required this.fechafin,
  });

  final String fechaini;
  final String fechafin;

  @override
  State<ReporteTarjetas> createState() => _ReporteTarjetasState();
}

class _ReporteTarjetasState extends State<ReporteTarjetas> {
  final ApiService apiService = ApiService();
  late final ConsultaBancosApi consultaBancosApi =
      ConsultaBancosApi(apiService);

  bool _cargando = true;
  String? _error;
  List<Map<String, dynamic>> _datos = [];

  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    obtenerDatos(widget.fechaini, widget.fechafin);
  }

  double _parseToDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  String _fmt(double valor) => _currencyFormat.format(valor);

  Future<void> obtenerDatos(String fechaini, String fechafin) async {
    try {
      setState(() {
        _cargando = true;
        _error = null;
      });

      final datos = await consultaBancosApi.obtenerDocumentos(
        fechaIni: fechaini,
        fechaFin: fechafin,
      );

      setState(() {
        _datos = datos;
        _cargando = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSantander = _datos.fold<double>(
      0,
      (sum, item) => sum + _parseToDouble(item['totalSantander']),
    );

    final totalMifel = _datos.fold<double>(
      0,
      (sum, item) => sum + _parseToDouble(item['totalMifel']),
    );

    final totalMonedero = _datos.fold<double>(
      0,
      (sum, item) => sum + _parseToDouble(item['totalMonedero']),
    );

    final totalDepositos = _datos.fold<double>(
      0,
      (sum, item) => sum + _parseToDouble(item['totalDepositos']),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Reporte de Tarjetas'),
        centerTitle: true,
        backgroundColor: const Color(0xFF005498),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF005498), Color(0xFF1976D2)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rango consultado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicio: ${_formatoFecha2(widget.fechaini)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  Text(
                    'Fin: ${_formatoFecha2(widget.fechafin)}',
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _datos.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron datos para el rango seleccionado.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      headingRowColor:
                                          MaterialStateProperty.all(
                                        const Color(0xFF005498),
                                      ),
                                      dataRowMinHeight: 52,
                                      dataRowMaxHeight: 60,
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'Fecha',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Santander',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Mifel',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Efecticard',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'Cajero Global',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                      rows: [
                                        ..._datos.map((item) {
                                          return DataRow(
                                            cells: [
                                              DataCell(
                                                Text(
                                                  _formatoFecha(
                                                    '${item['fecha'] ?? ''}',
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  _fmt(_parseToDouble(
                                                      item['totalSantander'])),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  _fmt(_parseToDouble(
                                                      item['totalMifel'])),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  _fmt(_parseToDouble(
                                                      item['totalMonedero'])),
                                                ),
                                              ),
                                              DataCell(
                                                Text(
                                                  _fmt(_parseToDouble(
                                                      item['totalDepositos'])),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                        DataRow(
                                          color: MaterialStateProperty.all(
                                            const Color(0xFFE8F1FB),
                                          ),
                                          cells: [
                                            const DataCell(
                                              Text(
                                                'TOTAL',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF005498),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _fmt(totalSantander),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF005498),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _fmt(totalMifel),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF005498),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _fmt(totalMonedero),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF005498),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                _fmt(totalDepositos),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF005498),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatoFecha(String fecha) {
    try {
      final partes = fecha.split('-');
      if (partes.length != 3) return fecha;

      final an = partes[0];
      final mes = partes[1];
      final dia = partes[2];

      return '$dia-$mes-$an';
    } catch (e) {
      return fecha;
    }
  }

  String _formatoFecha2(String fecha) {
    try {
      final partes = fecha.split('/');
      if (partes.length != 3) return fecha;

      final an = partes[0];
      final mes = partes[1];
      final dia = partes[2];

      return '$dia/$mes/$an';
    } catch (e) {
      return fecha;
    }
  }
}
