import 'package:flutter/material.dart';
import 'bauchers_clientes/santander.dart';

class DatoCorte extends StatefulWidget {
  const DatoCorte({
    super.key,
    required this.fecha,
    required this.user,
    required this.idUsuario, // 👈 nuevo
  });

  final String fecha;
  final String user; // nombre/alias
  final int idUsuario; // id numérico de BD

  @override
  State<DatoCorte> createState() => _DatoCorteState();
}

class _DatoCorteState extends State<DatoCorte> {
  late String fecha;
  late String user;
  late int idUsuario; // 👈 lo guardamos aquí

  late TextEditingController _ventaController;
  final TextEditingController _depositosController = TextEditingController();
  final TextEditingController _buzonController = TextEditingController();
  final TextEditingController _gastosController = TextEditingController();

  double _totalSantander = 0;
  double _totalMifel = 0;
  double _totalEfecticar = 0;
  double _totalClientes = 0;

  double totalFinal = 0;

  @override
  void initState() {
    super.initState();
    fecha = widget.fecha;
    user = widget.user;
    idUsuario = widget.idUsuario; // 👈 aquí
    _ventaController = TextEditingController();
  }

  @override
  void dispose() {
    _ventaController.dispose();
    _depositosController.dispose();
    _buzonController.dispose();
    _gastosController.dispose();
    super.dispose();
  }

  // ======== MÉTODO PARA RECALCULAR TOTAL ========
  void _recalcularTotal() {
    double venta = double.tryParse(_ventaController.text) ?? 0;
    double dep = double.tryParse(_depositosController.text) ?? 0;
    double buz = double.tryParse(_buzonController.text) ?? 0;
    double gas = double.tryParse(_gastosController.text) ?? 0;

    setState(() {
      totalFinal = venta -
          _totalSantander -
          _totalMifel -
          _totalEfecticar -
          _totalClientes -
          dep -
          buz -
          gas;
    });
  }

  // ======== FORMATO DINERO ========
  String _fmt(double valor) => '\$${valor.toStringAsFixed(2)}';

  // ======== EDITAR (PENDIENTE DE IMPLEMENTAR) ========

  Future<void> _editarSantander() async {
    final resultado = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => SantanderBauchersPage(
          fecha: fecha,
          user: user, idUsuario: idUsuario, // 👈 ahora le pasas el int, no user
        ),
      ),
    );

    if (resultado != null) {
      setState(() {
        _totalSantander = resultado;
      });
      _recalcularTotal();
    }
  }

  Future<void> _editarMifel() async {}

  Future<void> _editarEfecticar() async {}

  Future<void> _editarClientes() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Datos del Corte",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text("Usuario: $user"),
            Text("Fecha: $fecha"),
          ],
        ),
        centerTitle: true,
      ),

      // ================= CUERPO ====================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // VENTA DEL DÍA
            const Text("Venta del día",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ventaController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: "Venta del día",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) =>
                        _recalcularTotal(), // 👈 recalcula al escribir
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            const SizedBox(height: 20),

            // TARJETAS
            const Text("Tarjetas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              child: ListTile(
                title: const Text("Santander"),
                subtitle: Text(_fmt(_totalSantander)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editarSantander,
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Mifel"),
                subtitle: Text(_fmt(_totalMifel)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editarMifel,
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Efecticar"),
                subtitle: Text(_fmt(_totalEfecticar)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editarEfecticar,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // OTROS MOVIMIENTOS
            const Text("Otros movimientos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _depositosController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Depósitos Cajero",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _recalcularTotal(), // 👈 recalcula al escribir
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _buzonController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Buzón",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _recalcularTotal(), // 👈 recalcula al escribir
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _gastosController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Gastos",
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _recalcularTotal(), // 👈 recalcula al escribir
            ),

            const SizedBox(height: 20),

            // CLIENTES
            const Text("Clientes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Card(
              child: ListTile(
                title: const Text("Total clientes"),
                subtitle: Text(_fmt(_totalClientes)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _editarClientes,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =============== TOTAL FINAL ==================
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "TOTAL FINAL DEL CORTE: ${_fmt(totalFinal)}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÓN GUARDAR CORTE
            ElevatedButton(
              onPressed: () {
                // TODO guardar corte en BD
              },
              child: const Text("Guardar Corte"),
            ),
          ],
        ),
      ),
    );
  }
}
