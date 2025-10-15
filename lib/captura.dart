import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Captura extends StatelessWidget {
  const Captura({super.key});

  @override
  Widget build(BuildContext context) {
    return const Ingreso();
  }
}

class Ingreso extends StatefulWidget {
  const Ingreso({super.key});

  @override
  State<Ingreso> createState() => _IngresoState();
}

class _IngresoState extends State<Ingreso> {
  final TextEditingController _fechaCtrl = TextEditingController();
  DateTime? _fechaSeleccionada;

  @override
  void dispose() {
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final hoy = DateTime.now();
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? hoy,
      firstDate: DateTime(hoy.year - 5),
      lastDate: DateTime(hoy.year + 5),
      // Puedes dejar sin locale y tomará la del sistema.
      // Si quieres forzar español y ya pusiste los delegados:
      locale: const Locale('es', 'MX'),
      useRootNavigator: true, // ayuda cuando hay navegadores anidados
    );

    if (fecha != null && mounted) {
      setState(() {
        _fechaSeleccionada = fecha;
        _fechaCtrl.text = DateFormat('dd/MM/yyyy').format(fecha);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Cortes Despachador",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Bienvenido a la pantalla de Ingreso",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: _fechaCtrl,
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
                        content: Text('Selecciona una fecha primero')),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Fecha: ${_fechaCtrl.text}')),
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
