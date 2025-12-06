import 'package:flutter/material.dart';
import 'package:cortes/db.dart';

class SantanderBauchersPage extends StatefulWidget {
  final int idUsuario; // 👈 ahora es int
  final String fecha; // "dd/MM/yyyy"

  const SantanderBauchersPage({
    super.key,
    required this.idUsuario,
    required this.fecha,
  });

  @override
  State<SantanderBauchersPage> createState() => _SantanderBauchersPageState();
}

class _SantanderBauchersPageState extends State<SantanderBauchersPage> {
  final List<TextEditingController> _controllers = [TextEditingController()];
  double _total = 0;
  bool _cargando = true;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ========== CARGAR DATOS EXISTENTES ==========
  Future<void> _cargarDatosIniciales() async {
    try {
      final db = Db();

      final importes = await db.obtenerBauchers(
        tabla: 'Santander',
        idUsuario: widget.idUsuario, // 👈 ya es int
        fecha: widget.fecha,
      );

      if (importes.isNotEmpty) {
        _controllers.clear();

        for (final imp in importes) {
          _controllers.add(
            TextEditingController(text: imp.toStringAsFixed(2)),
          );
        }
      }

      _recalcularTotal();
    } catch (e) {
      print('Error al cargar datos iniciales: $e');
      if (mounted) {
        setState(() {
          _errorCarga = 'Error al cargar bauchers: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    }
  }

  void _recalcularTotal() {
    double suma = 0;
    for (final c in _controllers) {
      final valor = double.tryParse(c.text) ?? 0;
      suma += valor;
    }
    setState(() {
      _total = suma;
    });
  }

  void _onChangedCampo(int index, String _) {
    _recalcularTotal();

    if (index == _controllers.length - 1 &&
        _controllers[index].text.isNotEmpty) {
      setState(() {
        _controllers.add(TextEditingController());
      });
    }
  }

  // ========== GUARDAR (DELETE + INSERT) ==========
  Future<void> _guardar() async {
    final List<double> importes = [];
    for (final c in _controllers) {
      final valor = double.tryParse(c.text);
      if (valor != null && valor > 0) {
        importes.add(valor);
      }
    }

    if (importes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Captura al menos un baucher con importe mayor a 0'),
        ),
      );
      return;
    }

    try {
      final db = Db();

      await db.reemplazarBauchers(
        tabla: 'Santander',
        idUsuario: widget.idUsuario, // 👈 ya es int
        fecha: widget.fecha,
        importes: importes,
      );

      Navigator.pop<double>(context, _total);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar bauchers: $e'),
        ),
      );
    }
  }

  String _fmt(double valor) => '\$${valor.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    // Mostrar SnackBar de error de carga si existe
    if (_errorCarga != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorCarga!)),
        );
      });
      _errorCarga = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bauchers Santander',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('idUsuario: ${widget.idUsuario}'),
            Text('Fecha: ${widget.fecha}'),
          ],
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'Ingresa los importes de los bauchers.\n'
                    'Cada vez que escribas en el último campo aparecerá uno nuevo.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _controllers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: TextField(
                            controller: _controllers[index],
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Baucher ${index + 1}',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) => _onChangedCampo(index, value),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'TOTAL SANTANDER: ${_fmt(_total)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar bauchers'),
                      onPressed: _guardar,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
