import 'package:cortes/db.dart';
import 'package:flutter/material.dart';
import 'bauchers_clientes/santander.dart';
import 'bauchers_clientes/mifel.dart';
import 'bauchers_clientes/efecticard.dart';
import 'bauchers_clientes/clientes.dart';
import 'package:cortes/administrador/notifTelegram/configApi.dart';
import 'package:intl/intl.dart';

class DatoCorte extends StatefulWidget {
  const DatoCorte({
    super.key,
    required this.fecha,
    required this.user,
    required this.idUsuario,
  });

  final String fecha;
  final String user;
  final int idUsuario;

  @override
  State<DatoCorte> createState() => _DatoCorteState();
}

class _DatoCorteState extends State<DatoCorte> {
  late String fecha;
  late String user;
  late int idUsuario;

  late TextEditingController _ventaController;
  final TextEditingController _depositosController = TextEditingController();
  final TextEditingController _buzonController = TextEditingController();
  final TextEditingController _gastosController = TextEditingController();

  final NotificacionesTelegram _corteTelegram = NotificacionesTelegram();

  double _totalSantander = 0;
  double _totalMifel = 0;
  double _totalEfecticar = 0;
  double _totalClientes = 0;
  double totalFinal = 0;

  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    fecha = widget.fecha;
    user = widget.user;
    idUsuario = widget.idUsuario;

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

  // ======== RECALCULAR TOTAL ========
  void _recalcularTotal() {
    final venta = double.tryParse(_ventaController.text) ?? 0;
    final dep = double.tryParse(_depositosController.text) ?? 0;
    final buz = double.tryParse(_buzonController.text) ?? 0;
    final gas = double.tryParse(_gastosController.text) ?? 0;

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
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  String _fmt(double valor) {
    return _currencyFormat.format(valor);
  }

  // ======== NAVEGAR A PANTALLAS DE BAUCHERS ========
  Future<void> _editarSantander() async {
    final resultado = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => SantanderBauchersPage(
          fecha: fecha,
          user: user,
          idUsuario: widget.idUsuario,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalSantander = resultado);
      _recalcularTotal();
    }
  }

  Future<void> _editarMifel() async {
    final resultado = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => MifelBauchersPage(
          fecha: fecha,
          user: user,
          idUsuario: widget.idUsuario,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalMifel = resultado);
      _recalcularTotal();
    }
  }

  Future<void> _editarEfecticar() async {
    final resultado = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => EfecticarBauchersPage(
          fecha: fecha,
          user: user,
          idUsuario: widget.idUsuario,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalEfecticar = resultado);
      _recalcularTotal();
    }
  }

  Future<void> _editarClientes() async {
    // OJO: aquí estabas mandando MifelBauchersPage también.
    // Si tienes una pantalla de clientes, cámbiala.
    final resultado = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => ClientesBauchersPage(
          fecha: fecha,
          user: user,
          idUsuario: widget.idUsuario,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalClientes = resultado);
      _recalcularTotal();
    }
  }

  // ======== BOTÓN GUARDAR (CORRECTO) ========
  Future<void> _onGuardarPressed() async {
    if (_guardando) return;

    final venta = double.tryParse(_ventaController.text) ?? 0;
    final santander = _totalSantander;
    final mifel = _totalMifel;
    final efecticar = _totalEfecticar;
    final depositos = double.tryParse(_depositosController.text) ?? 0;
    final buzon = double.tryParse(_buzonController.text) ?? 0;
    final gastos = double.tryParse(_gastosController.text) ?? 0;
    final clientes = _totalClientes;
    final total = totalFinal;

    if (venta == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La venta del día no puede ser cero.")),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _guardando = true);

    try {
      await _guardarCorte(
        fecha,
        idUsuario,
        user,
        venta,
        santander,
        mifel,
        efecticar,
        depositos,
        buzon,
        gastos,
        clientes,
        total,
      );
      await _enviarCorteTelegram();

      if (!mounted) return;
      setState(() => _guardando = false);

      Navigator.pop(context); // ✅ solo al terminar
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar el corte: $e")),
      );
    }
  }

  // ======== OVERLAY GUARDANDO ========
  Widget _overlayGuardando() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.25),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 14),
                Text(
                  'Guardando tu corte $user ...',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======== GUARDAR CORTE EN BD ========
  Future<void> _guardarCorte(
    String fecha,
    int idUsuario,
    String user,
    double venta,
    double santander,
    double mifel,
    double efecticar,
    double depositos,
    double buzon,
    double gastos,
    double clientes,
    double total,
  ) async {
    final db = Db();

    await db.insertarCorte(
      fecha: fecha,
      idUsuario: idUsuario,
      usuario: user,
      venta: venta,
      santander: santander,
      mifel: mifel,
      efecticar: efecticar,
      depositos: depositos,
      buzon: buzon,
      gastos: gastos,
      clientes: clientes,
      efectivoEntregado: total,
    );
  }

  // Funcion para enviar corte por Telegram}
  Future<void> _enviarCorteTelegram() async {
    final mensaje = '''
<b>⛽ Corte de $user</b>

<b>$fecha</b>

<b>Venta del día:</b> ${_fmt(double.tryParse(_ventaController.text) ?? 0)}

<b>Santander:</b> ${_fmt(_totalSantander)}

<b>Mifel:</b> ${_fmt(_totalMifel)}

<b>Efecticar:</b> ${_fmt(_totalEfecticar)}

<b>Depósitos Cajero:</b> ${_fmt(double.tryParse(_depositosController.text) ?? 0)}

<b>Buzón:</b> ${_fmt(double.tryParse(_buzonController.text) ?? 0)}

<b>Gastos:</b> ${_fmt(double.tryParse(_gastosController.text) ?? 0)}

<b>Total clientes:</b> ${_fmt(_totalClientes)}

<b>Diferencia a entregar:</b> ${_fmt(totalFinal)}
''';

    await _corteTelegram.enviarNotificacion(mensaje);
  }

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

      // ✅ IMPORTANTE: Stack para overlay
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Venta del día",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _ventaController,
                  enabled: !_guardando,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Venta del día",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _recalcularTotal(),
                ),
                const SizedBox(height: 20),
                const Text("Tarjetas",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Card(
                  child: ListTile(
                    title: const Text("Santander"),
                    subtitle: Text(_fmt(_totalSantander)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _guardando ? null : _editarSantander,
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text("Mifel"),
                    subtitle: Text(_fmt(_totalMifel)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _guardando ? null : _editarMifel,
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: const Text("Efecticar"),
                    subtitle: Text(_fmt(_totalEfecticar)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _guardando ? null : _editarEfecticar,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Otros movimientos",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _depositosController,
                  enabled: !_guardando,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Depósitos Cajero",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _recalcularTotal(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _buzonController,
                  enabled: !_guardando,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Buzón",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _recalcularTotal(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _gastosController,
                  enabled: !_guardando,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Gastos",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _recalcularTotal(),
                ),
                const SizedBox(height: 20),
                const Text("Clientes",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Card(
                  child: ListTile(
                    title: const Text("Total clientes"),
                    subtitle: Text(_fmt(_totalClientes)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _guardando ? null : _editarClientes,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Diferencia a entregar: ${_fmt(totalFinal)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _guardando ? null : _onGuardarPressed,
                  child: const Text("Guardar Corte"),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (_guardando) _overlayGuardando(),
        ],
      ),
    );
  }
}
