import 'package:flutter/material.dart';
import 'package:cortes/db.dart';

class _BaucherItem {
  final int? idSantander; // null = aún no existe en BD
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? user;

  _BaucherItem(
      {required this.idSantander,
      required this.controller,
      required this.focusNode,
      this.user});
}

class SantanderBauchersPage extends StatefulWidget {
  final int idUsuario;
  final String fecha; // "dd/MM/yyyy"
  final String user;

  const SantanderBauchersPage({
    super.key,
    required this.idUsuario,
    required this.fecha,
    required this.user, // compatibilidad con tu llamada actual
  });

  @override
  State<SantanderBauchersPage> createState() => _SantanderBauchersPageState();
}

class _SantanderBauchersPageState extends State<SantanderBauchersPage> {
  final List<_BaucherItem> _items = [];
  double _total = 0;
  bool _cargando = true;
  String? _errorCarga;
  bool _yaExistia = false;
  String? us;

  @override
  void initState() {
    super.initState();
    // inicializa con un campo vacío
    _items.add(_nuevoItemVacio());
    _cargarDatosIniciales();
    us = widget.user;
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

      // limpiar
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

      // agrega el campo extra vacío al final
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

  // ===================== ENTRAR / NEXT =====================
  void _onSubmittedCampo(int index) {
    // Si es el último (campo vacío final) y ya tiene texto, crea uno nuevo
    if (index == _items.length - 1 &&
        _items[index].controller.text.isNotEmpty) {
      setState(() {
        _items.add(_nuevoItemVacio());
      });

      // enfocar el nuevo campo
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

    // si están escribiendo en el último y ya tiene texto, agrega otro vacío
    if (index == _items.length - 1 &&
        _items[index].controller.text.isNotEmpty) {
      setState(() {
        _items.add(_nuevoItemVacio());
      });
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
  Future<void> _guardarNuevo() async {
    final importes = _obtenerImportesValidos();

    if (importes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Captura al menos un baucher con importe mayor a 0')),
      );
      return;
    }

    try {
      final db = Db();
      await db.insertarSantander(
        idUsuario: widget.idUsuario,
        fecha: widget.fecha,
        importes: importes,
      );

      if (!mounted) return;
      setState(() => _yaExistia = true);
      Navigator.pop<double>(context, _total);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar bauchers: $e')),
      );
    }
  }

  Future<void> _actualizar() async {
    final importes = _obtenerImportesValidos();

    if (importes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Captura al menos un baucher con importe mayor a 0')),
      );
      return;
    }

    try {
      final db = Db();
      await db.reemplazarSantanderPorUsuarioFecha(
        idUsuario: widget.idUsuario,
        fecha: widget.fecha,
        importes: importes,
      );

      if (!mounted) return;
      Navigator.pop<double>(context, _total);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar bauchers: $e')),
      );
    }
  }

  Future<void> _guardar() async {
    // cierra teclado
    FocusScope.of(context).unfocus();

    if (_yaExistia) {
      await _actualizar();
    } else {
      await _guardarNuevo();
    }
  }

  // ===================== ELIMINAR POR FILA =====================
  Future<void> _eliminarRegistro(int index) async {
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

        // si se quedó sin campos, agrega uno vacío
        if (_items.isEmpty) {
          _items.add(_nuevoItemVacio());
        }
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

        if (_items.isEmpty) {
          _items.add(_nuevoItemVacio());
        }
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
            Text('Usuario: ${us}'),
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
                    'Presiona "Siguiente" en el teclado para brincar al siguiente campo.',
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
                                  onSubmitted: (_) => _onSubmittedCampo(index),
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
                                  onPressed: () => _eliminarRegistro(index),
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
                      label: Text(_yaExistia
                          ? 'Actualizar bauchers'
                          : 'Guardar bauchers'),
                      onPressed: _guardar,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
