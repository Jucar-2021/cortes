import 'package:flutter/material.dart';
import '../api/consumoPHP.dart';
import '../api/documentos/consultas_api.dart';

class ReporteTarjetas extends StatefulWidget {
  const ReporteTarjetas(
      {super.key, required this.fechaini, required this.fechafin});

  final String fechaini;
  final String fechafin;

  @override
  State<ReporteTarjetas> createState() => _ReporteTarjetasState();
}

class _ReporteTarjetasState extends State<ReporteTarjetas> {
  final ApiService apiService = ApiService();
  late final ConsultaBancosApi consultaBancosApi =
      ConsultaBancosApi(apiService);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Llamar a la función para obtener los datos al iniciar el widget

    obtenerDatos(widget.fechaini, widget.fechafin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Tarjetas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fecha de Inicio: ${widget.fechaini}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Fecha de Fin: ${widget.fechafin}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  void obtenerDatos(String fechaini, String fechafin) {
    print('Fechas recibidas: ${fechaini} - ${fechafin}');
    consultaBancosApi
        .obtenerDocumentos(fechaIni: fechaini, fechaFin: fechafin)
        .then((datos) {})
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener datos: $error')),
      );
    });
  }
}
