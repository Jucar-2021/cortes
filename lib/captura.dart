import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'datosCorte.dart';

class Captura extends StatelessWidget {
  final String usuario;
  const Captura({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Ingreso(usuario: usuario);
  }
}

class Ingreso extends StatefulWidget {
  const Ingreso({super.key, required this.usuario});
  final String usuario;
  @override
  State<Ingreso> createState() => _IngresoState();
}

class _IngresoState extends State<Ingreso> {
  final TextEditingController _fechaSelec = TextEditingController();
  DateTime? _fechaSeleccionada;
  late String user;

  get idUsuario => null;

  @override
  void initState() {
    super.initState();
    user = widget.usuario;
  }

  @override
  void dispose() {
    _fechaSelec.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? hoy,
      firstDate: DateTime(hoy.year - 5),
      lastDate: DateTime(hoy.year + 5),
      locale: const Locale('es', 'MX'),
      useRootNavigator: true,
    );

    if (fecha != null && mounted) {
      setState(() {
        _fechaSeleccionada = fecha;
        _fechaSelec.text = DateFormat('dd/MM/yyyy').format(fecha);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Cortes Despachador",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            Text(
              "Usuario: $user",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 30),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Fecha del corte a capturar",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _fechaSelec,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Fecha',
                hintText: 'Selecciona una fecha',
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.event),
                  onPressed: _seleccionarFecha,
                ),
                border: const OutlineInputBorder(),
              ),
              onTap: _seleccionarFecha,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_fechaSeleccionada == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona una fecha primero'),
                    ),
                  );
                  return;
                }

                String fecha = _fechaSelec.text;
                print(fecha);
                // SnackBar opcional ANTES de navegar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fecha: $fecha')),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DatoCorte(
                      fecha: fecha,
                      user: user,
                      idUsuario: 0, // 👈 pasa un valor entero predeterminado
                    ),
                  ),
                );
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
