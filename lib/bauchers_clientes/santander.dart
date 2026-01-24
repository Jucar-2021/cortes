import 'package:flutter/material.dart';
import 'package:cortes/db.dart';

class _BaucherItem {
  final int? idSantander; // null = aún no existe en BD
  final TextEditingController controller;
  final FocusNode focusNode;

  _BaucherItem({
    required this.idSantander,
    required this.controller,
    required this.focusNode,
  });
}

class SantanderBauchersPage extends StatefulWidget {
  final int idUsuario;
  final String fecha; // "dd/MM/yyyy"

  const SantanderBauchersPage({
    super.key,
    required this.idUsuario,
    required this.fecha,
    required String user, // compatibilidad con tu llamada actual
  });

  @override
  State<SantanderBauchersPage> createState() => _SantanderBauchersPageState();
}

class _SantanderBauchersPageState extends State<SantanderBauchersPage> {
  final List<_BaucherItem> _items = [];

  double _total = 0;
  bool _cargando = true;
  String? _errorCarga;

  bool _yaExistia = false; // controla "Guardar" vs "Actualizar"
  bool _guardando = false; // overlay "Registrando vouchers..."

  @override
  void initState() {
    super.initState();
    _items.add(_nuevoItemVacio());
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    for (final it in _items) {
      it.controller.dispose();
      it.focusNode.dispose();
    }
    super.dispose();
  }

  _BaucherItem _nuevoItemVacio() {
    return _BaucherItem(
      idSantander: null,
      controller: TextEditingController(),
      focusNode: FocusNode(),
    );
  }

  _BaucherItem _itemDesdeBD(
      {required int idSantander, required double importe}) {
    return _BaucherItem(
      idSantander: idSantander,
      controller: TextEditingController(text: importe.toStringAsFixed(2)),
      focusNode: FocusNode(),
    );
  }

  // ===================== CARGA INICIAL =====================
  Future<void> _cargarDatosIniciales() async {
    try {
      final db = Db();

      final rows = await db.obtenerSantanderPorUsuarioFecha(
        idUsuario: widget.idUsuario,
        fecha: widget.fecha,
      );

      if (!mounted) return;

      // limpiar items actuales
      for (final it in _items) {
        it.controller.dispose();
        it.focusNode.dispose();
      }
      _items.clear();

      if (rows.isNotEmpty) {
        _yaExistia = true;

        for (final r in rows) {
          final idSantander = r['idSantander'] as int;
          final importe = (r['importe'] as num).toDouble();
          _items.add(_itemDesdeBD(idSantander: idSantander, importe: importe));
        }
      } else {
        _yaExistia = false;
      }

      // deja un campo extra vacío al final
      _items.add(_nuevoItemVacio());

      _recalcularTotal();
    } catch (e) {
      if (!mounted) return;
      _errorCarga = 'Error al cargar bauchers: $e';
    } finally {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  // ===================== TOTALES =====================
  void _recalcularTotal() {
    double suma = 0;
    for (final it in _items) {
      final v = double.tryParse(it.controller.text) ?? 0;
      suma += v;
    }
    if (mounted) setState(() => _total = suma);
  }

  // ===================== NEXT / DONE =====================
  void _onSubmittedCampo(int index) {
    // si es el último campo y ya tiene texto, crea uno nuevo y enfoca
    if (index == _items.length - 1 &&
        _items[index].controller.text.isNotEmpty) {
      setState(() => _items.add(_nuevoItemVacio()));

      Future.microtask(() {
        if (!mounted) return;
        FocusScope.of(context).requestFocus(_items[index + 1].focusNode);
      });
      return;
    }

    // si hay siguiente, enfócalo
    if (index + 1 < _items.length) {
      FocusScope.of(context).requestFocus(_items[index + 1].focusNode);
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  void _onChangedCampo(int index, String _) {
    _recalcularTotal();

    // si escriben en el último y ya tiene texto, agrega otro vacío
    if (index == _items.length - 1 &&
        _items[index].controller.text.isNotEmpty) {
      setState(() => _items.add(_nuevoItemVacio()));
    }
  }

  List<double> _obtenerImportesValidos() {
    final List<double> importes = [];
    for (final it in _items) {
      final v = double.tryParse(it.controller.text);
      if (v != null && v > 0) importes.add(v);
    }
    return importes;
  }

  // ===================== GUARDAR / ACTUALIZAR =====================
  Future<void> _guardarNuevo(List<double> importes) async {
    final db = Db();
    await db.insertarSantander(
      idUsuario: widget.idUsuario,
      fecha: widget.fecha,
      importes: importes,
    );
  }

  Future<void> _actualizar(List<double> importes) async {
    final db = Db();
    await db.reemplazarSantanderPorUsuarioFecha(
      idUsuario: widget.idUsuario,
      fecha: widget.fecha,
      importes: importes,
    );
  }

  Future<void> _guardar() async {
    // Si ya está guardando, no hacer nada
    if (_guardando) return;

    // Cierra teclado
    FocusScope.of(context).unfocus();

    final importes = _obtenerImportesValidos();

    // ✅ NUEVO: si no hay importes, regresar sin pedir nada
    if (importes.isEmpty) {
      Navigator.pop<double>(context, _total);
      return;
    }

    try {
      if (!mounted) return;
      setState(() => _guardando = true);

      if (_yaExistia) {
        await _actualizar(importes);
      } else {
        await _guardarNuevo(importes);
      }

      if (!mounted) return;
      setState(() => _guardando = false);

      Navigator.pop<double>(context, _total);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar vouchers: $e')),
      );
    }
  }

  // ===================== ELIMINAR POR FILA =====================
  Future<void> _eliminarRegistro(int index) async {
    if (_guardando) return; // bloquea mientras guarda

    final item = _items[index];

    // No eliminar el último campo vacío
    final esUltimoYVacio =
        index == _items.length - 1 && item.controller.text.isEmpty;
    if (esUltimoYVacio) return;

    // Si no existe en BD aún, solo quítalo de la lista
    if (item.idSantander == null) {
      setState(() {
        item.controller.dispose();
        item.focusNode.dispose();
        _items.removeAt(index);
        if (_items.isEmpty) _items.add(_nuevoItemVacio());
      });
      _recalcularTotal();
      return;
    }

    try {
      final db = Db();
      await db.eliminarSantanderPorId(item.idSantander!);

      if (!mounted) return;

      setState(() {
        item.controller.dispose();
        item.focusNode.dispose();
        _items.removeAt(index);
        if (_items.isEmpty) _items.add(_nuevoItemVacio());
      });

      // si ya no hay registros reales en BD, cambia a Guardar
      final quedanReales = _items.any((x) => x.idSantander != null);
      _yaExistia = quedanReales;

      _recalcularTotal();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  String _fmt(double valor) => '\$${valor.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
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
          ],
        ),
        centerTitle: true,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text(
                        'Ingresa los importes de los bauchers.\n'
                        'Presiona "Siguiente" para brincar al siguiente campo.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];

                            final esUltimo = index == _items.length - 1;
                            final action = esUltimo
                                ? TextInputAction.done
                                : TextInputAction.next;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: item.controller,
                                      focusNode: item.focusNode,
                                      enabled: !_guardando,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      textInputAction: action,
                                      decoration: InputDecoration(
                                        labelText: 'Baucher ${index + 1}',
                                        border: const OutlineInputBorder(),
                                      ),
                                      onChanged: (value) =>
                                          _onChangedCampo(index, value),
                                      onSubmitted: (_) =>
                                          _onSubmittedCampo(index),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Focus(
                                    canRequestFocus: false,
                                    skipTraversal: true,
                                    child: IconButton(
                                      tooltip: 'Eliminar',
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: _guardando
                                          ? null
                                          : () => _eliminarRegistro(index),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'TOTAL: ${_fmt(_total)}',
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
                          label: Text(_yaExistia
                              ? 'Actualizar bauchers'
                              : 'Guardar bauchers'),
                          onPressed: _guardando ? null : _guardar,
                        ),
                      ),
                    ],
                  ),
                ),

                // ================= OVERLAY "REGISTRANDO..." =================
                if (_guardando)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 14),
                              Text(
                                'Registrando vouchers...',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
