import 'package:flutter/material.dart';
import 'db.dart';

class DatoCorte extends StatefulWidget {
  const DatoCorte({super.key, required this.fecha, required this.user});

  final String fecha;
  final String user;

  @override
  State<DatoCorte> createState() => _DatoCorteState();
}

class _DatoCorteState extends State<DatoCorte> {
  late String fecha;
  late String user;

  @override
  void initState() {
    super.initState();
    fecha = widget.fecha;
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Datos del Corte',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Usuario: $user'),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            Db db = Db();
            await db.consultarBD();
          },
          child: const Text('Consultar Datos'),
        ),
      ),
    );
  }
}
