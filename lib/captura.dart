import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'datosCorte.dart';

class Captura extends StatelessWidget {
  final String usuario;
  final int idUsuario;
  const Captura({super.key, required this.usuario, required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return Ingreso(usuario: usuario, idUsuario: idUsuario);
  }
}

class Ingreso extends StatefulWidget {
  const Ingreso({super.key, required this.usuario, required this.idUsuario});
  final String usuario;
  final int idUsuario;

  @override
  State<Ingreso> createState() => _IngresoState();
}

class _IngresoState extends State<Ingreso> {
  final TextEditingController _fechaSelec = TextEditingController();
  DateTime? _fechaSeleccionada;

  late String user;
  late int idUsuario;

  @override
  void initState() {
    super.initState();
    user = widget.usuario;
    idUsuario = widget.idUsuario;
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

  void _continuar() {
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha primero')),
      );
      return;
    }

    final fecha = _fechaSelec.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DatoCorte(
          fecha: fecha,
          user: user,
          idUsuario: idUsuario,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ Esto ayuda cuando aparece teclado
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cortes Despachador",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Text(
              "Usuario: $user",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withOpacity(0.12),
              cs.surface,
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 14),

                    // Encabezado tipo "sección"
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Selecciona la fecha del corte",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Elige la fecha que vas a capturar para continuar.",
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card principal
                    Card(
                      elevation: 8,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _fechaSelec,
                              readOnly: true,
                              onTap: _seleccionarFecha,
                              decoration: InputDecoration(
                                labelText: 'Fecha',
                                hintText: 'Selecciona una fecha',
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.event),
                                  onPressed: _seleccionarFecha,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: _continuar,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text(
                                  "Continuar",
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Footer discreto
                    Text(
                      "Consejo: si capturas siempre al cierre, elige la fecha del día.",
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withOpacity(0.55),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
