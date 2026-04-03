import 'package:flutter/material.dart';
import 'doc_tar_depCaj/cajero.dart' show DepositosCajeroPage;
import 'doc_tar_depCaj/santander.dart';
import 'doc_tar_depCaj/mifel.dart';
import 'doc_tar_depCaj/efecticard.dart';
import 'clientes/listadoClientes.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/guardarCorte_api.dart';
import 'api/telegramSend_api.dart';
import 'api/consumoPHP.dart';

class DatoCorte extends StatefulWidget {
  const DatoCorte({
    super.key,
    required this.fecha,
    required this.user,
    required this.idUsuario,
    required this.tipoZonaCorte,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
  });

  final String fecha;
  final String user;
  final int idUsuario;
  final String tipoZonaCorte;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;

  @override
  State<DatoCorte> createState() => _DatoCorteState();
}

class _DatoCorteState extends State<DatoCorte> {
  late String fecha;
  late String user;
  late int idUsuario;
  late String producto;
  late String nombre;
  late String apellidoPaterno;
  late String apellidoMaterno;

  late TextEditingController _ventaController;
  final TextEditingController _buzonController = TextEditingController();
  final TextEditingController _gastosController = TextEditingController();
  final TextEditingController _billetesController = TextEditingController();
  final TextEditingController _monedasController = TextEditingController();

  final TelegramApi _corteTelegram = TelegramApi(ApiService());

  double _totalSantander = 0;
  double _totalMifel = 0;
  double _totalEfecticar = 0;
  double _totalClientes = 0;
  double _totalCajero = 0;
  double totalFinal = 0;

  bool _guardando = false;

  SharedPreferences? _prefs;
  bool _prefsReady = false;

  // ======== FORMATO DINERO ========
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  String _fmt(double valor) => _currencyFormat.format(valor);

  // Key con contexto (evita mezclar datos entre usuarios/fechas/producto)
  String _k(String key) => '${key}_${idUsuario}_${fecha}_$producto';

  @override
  void initState() {
    super.initState();

    fecha = widget.fecha;
    user = widget.user;
    idUsuario = widget.idUsuario;
    producto = widget.tipoZonaCorte;
    nombre = widget.nombre;
    apellidoPaterno = widget.apellidoPaterno;
    apellidoMaterno = widget.apellidoMaterno;

    _ventaController = TextEditingController();

    _initPrefsAndLoad();
  }

  Future<void> _initPrefsAndLoad() async {
    _prefs = await SharedPreferences.getInstance();

    // Cargar valores texto
    _ventaController.text = _prefs!.getString(_k('ventaDia')) ?? '';
    _buzonController.text = _prefs!.getString(_k('buzon')) ?? '';
    _gastosController.text = _prefs!.getString(_k('gastos')) ?? '';

    // Cargar totales
    _totalSantander = _prefs!.getDouble(_k('totalSantander')) ?? 0.0;
    _totalMifel = _prefs!.getDouble(_k('totalMifel')) ?? 0.0;
    _totalEfecticar = _prefs!.getDouble(_k('totalEfecticar')) ?? 0.0;
    _totalCajero = _prefs!.getDouble(_k('totalCajero')) ?? 0.0;
    _totalClientes = _prefs!.getDouble(_k('totalClientes')) ?? 0.0;

    _prefsReady = true;

    _recalcularTotal();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ventaController.dispose();
    _buzonController.dispose();
    _gastosController.dispose();
    _billetesController.dispose();
    _monedasController.dispose();
    super.dispose();
  }

  // ======== RECALCULAR TOTAL ========
  void _recalcularTotal() {
    final venta = double.tryParse(_ventaController.text) ?? 0;

    final buz = double.tryParse(_buzonController.text) ?? 0;
    final gas = double.tryParse(_gastosController.text) ?? 0;
    final billetes = double.tryParse(_billetesController.text) ?? 0;
    final monedas = double.tryParse(_monedasController.text) ?? 0;

    setState(() {
      totalFinal = venta -
          _totalSantander -
          _totalMifel -
          _totalEfecticar -
          _totalClientes -
          _totalCajero -
          buz -
          gas -
          billetes -
          monedas;
    });
  }

  Future<void> _saveString(String key, String value) async {
    if (!_prefsReady || _prefs == null) return;
    await _prefs!.setString(_k(key), value);
  }

  Future<void> _saveDouble(String key, double value) async {
    if (!_prefsReady || _prefs == null) return;
    await _prefs!.setDouble(_k(key), value);
  }

  Future<void> _clearDraft() async {
    if (!_prefsReady || _prefs == null) return;

    await _prefs!.remove(_k('ventaDia'));
    await _prefs!.remove(_k('totalCajero'));
    await _prefs!.remove(_k('buzon'));
    await _prefs!.remove(_k('gastos'));
    await _prefs!.remove(_k('ajustedep'));
    await _prefs!.remove(_k('totalSantander'));
    await _prefs!.remove(_k('totalMifel'));
    await _prefs!.remove(_k('totalEfecticar'));
    await _prefs!.remove(_k('totalClientes'));
    await _prefs!.remove(_k('billetes'));
    await _prefs!.remove(_k('monedas'));
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
          producto: producto,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalSantander = resultado);
      await _saveDouble('totalSantander', resultado);
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
          producto: producto,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalMifel = resultado);
      await _saveDouble('totalMifel', resultado);
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
          producto: producto,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalEfecticar = resultado);
      await _saveDouble('totalEfecticar', resultado);
      _recalcularTotal();
    }
  }

  Future<void> _editarDepositosCajero() async {
    final resultado = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => DepositosCajeroPage(
          fecha: fecha,
          user: user,
          idUsuario: widget.idUsuario,
          producto: producto,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalCajero = resultado);
      await _saveDouble('totalCajero', resultado);
      _recalcularTotal();
    }
  }

  Future<void> _editarClientes() async {
    final resultado = await Navigator.push<double>(
      context,
      MaterialPageRoute(
        builder: (_) => Listadoclientes(
          fecha: fecha,
          user: user,
          idUsuario: widget.idUsuario,
          producto: producto,
        ),
      ),
    );

    if (resultado != null) {
      setState(() => _totalClientes = resultado);
      await _saveDouble('totalClientes', resultado);
      _recalcularTotal();
    }
  }

  // ======== BOTÓN GUARDAR ========
  Future<void> _onGuardarPressed() async {
    if (_guardando) return;

    final venta = double.tryParse(_ventaController.text) ?? 0;
    final billetes = double.tryParse(_billetesController.text) ?? 0;
    final monedas = double.tryParse(_monedasController.text) ?? 0;
    final buzon = double.tryParse(_buzonController.text) ?? 0;
    final gastos = double.tryParse(_gastosController.text) ?? 0;
    final depositos = _totalCajero;

    final santander = _totalSantander;
    final mifel = _totalMifel;
    final efecticar = _totalEfecticar;
    final clientes = _totalClientes;

    final total = totalFinal + billetes + monedas;

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
        producto,
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

      // Limpia borrador local cuando guardó exitosamente
      await _clearDraft();

      if (!mounted) return;
      setState(() => _guardando = false);

      _showCorteGuardadoDialog();
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
        color: const Color.fromARGB(255, 82, 80, 80),
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
    String usuario,
    String producto,
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
    final corteApi = CorteApi(ApiService());

    await corteApi.guardarCorte(
      fecha: fecha,
      idUsuario: idUsuario,
      usuario: "$nombre $apellidoPaterno $apellidoMaterno",
      producto: producto,
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

  // ======== ENVIAR A TELEGRAM ========
  Future<void> _enviarCorteTelegram() async {
    final mensaje = '''
<b>⛽ CORTE DE TURNO</b>
👤 <b>$nombre $apellidoPaterno $apellidoMaterno</b>

━━━━━━━━━━━━━━━━━━
⛽ <b>Producto:</b> <code>$producto</code>
📅 <b>Fecha:</b> <b>$fecha</b>
━━━━━━━━━━━━━━━━━━
💰 <b>Venta del día:</b> ${_fmt(double.tryParse(_ventaController.text) ?? 0)}

♨️ <b>Santander:</b> ${_fmt(_totalSantander)}

🏦 <b>Mifel:</b> ${_fmt(_totalMifel)}

💳 <b>Efecticar:</b> ${_fmt(_totalEfecticar)}

👥 <b>Total clientes:</b> ${_fmt(_totalClientes)}

━━━━━━━━━━━━━━━━━━
🏧 <b>Depósitos Cajero:</b> ${_fmt((_totalCajero))}
📥 <b>Buzón:</b> ${_fmt(double.tryParse(_buzonController.text) ?? 0)}
🧾 <b>Gastos:</b> ${_fmt(double.tryParse(_gastosController.text) ?? 0)}

━━━━━━━━━━━━━━━━━━
🔴 <b>TOTAL ENTREGADO:</b>
🟰 <b>${_fmt((totalFinal) + (double.tryParse(_billetesController.text) ?? 0) + (double.tryParse(_monedasController.text) ?? 0))}</b>

💵 <b>Billetes: ${_fmt(double.tryParse(_billetesController.text) ?? 0)}</b>
💰 <b>Monedas: ${_fmt(double.tryParse(_monedasController.text) ?? 0)}</b>
━━━━━━━━━━━━━━━━━━
🟢 <b>TOTAL EFECTIVO:</b>
💰 <b>${_fmt((double.tryParse(_ventaController.text) ?? 0) - _totalSantander - _totalMifel - _totalEfecticar - _totalClientes - (double.tryParse(_gastosController.text) ?? 0))}</b>
''';

    await _corteTelegram.sendMessage(mensaje);
  }

  //Show de confirmacion de corte guardado exitosamente
  void _showCorteGuardadoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Corte guardado y enviado a Telegram"),
        content: const Text("Tu corte ha sido guardado exitosamente."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$nombre $apellidoPaterno $apellidoMaterno",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text("Captura de corte $producto con fecha:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            Text(_formatoFecha(fecha),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
      ),
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
                  onChanged: (value) async {
                    await _saveString('ventaDia', value);

                    _recalcularTotal();
                  },
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
                const SizedBox(height: 20),
                const Text("Otros movimientos",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Card(
                  child: ListTile(
                    title: const Text("Depósitos en cajero"),
                    subtitle: Text(_fmt(_totalCajero)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _guardando ? null : _editarDepositosCajero,
                    ),
                  ),
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
                  onChanged: (value) async {
                    await _saveString('buzon', value);
                    _recalcularTotal();
                  },
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
                  onChanged: (value) async {
                    await _saveString('gastos', value);
                    _recalcularTotal();
                  },
                ),
                const SizedBox(height: 20),
                const Text("Detalle de efectivo entregado",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                  controller: _billetesController,
                  enabled: !_guardando,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Total Billetes",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) async {
                    await _saveString('billetes', value);
                    _recalcularTotal();
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _monedasController,
                  enabled: !_guardando,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: "Total Monedas",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) async {
                    await _saveString('monedas', value);
                    _recalcularTotal();
                  },
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: totalFinal > 0
                        ? Colors.yellowAccent
                        : Colors.tealAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    totalFinal < 0
                        ? "Diferencia a entregar: ${_fmt(totalFinal)} (SOBRANTE)"
                        : "Diferencia a entregar: ${_fmt(totalFinal)}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: totalFinal > 0 ? Colors.red : Colors.blue,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _guardando ? null : _onGuardarPressed,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Guardar Corte"),
                      SizedBox(width: 8),
                      Icon(Icons.save_rounded),
                    ],
                  ),
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

  //formato de fecha DD/MM/YYYY
  String _formatoFecha(String fecha) {
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
