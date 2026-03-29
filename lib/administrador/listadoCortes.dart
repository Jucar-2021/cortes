import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/consumoPHP.dart';
import '../api/verCorte_api.dart';

class ListadoCortes extends StatelessWidget {
  final String fecha;

  const ListadoCortes({super.key, required this.fecha});

  @override
  Widget build(BuildContext context) {
    return VisualizarCorte(fecha: fecha);
  }
}

class VisualizarCorte extends StatefulWidget {
  const VisualizarCorte({super.key, required this.fecha});
  final String fecha;

  @override
  State<VisualizarCorte> createState() => _VisualizarCorteState();
}

class _VisualizarCorteState extends State<VisualizarCorte> {
  late String fecha;

  final ApiService apiService = ApiService();
  late final VerCorteAPI verCorteAPI = VerCorteAPI(apiService);
  late final VerCorteAPI consumoClientesAPI = VerCorteAPI(apiService);

  @override
  void initState() {
    super.initState();
    fecha = widget.fecha;
  }

  Future<List<dynamic>> _consumoClientes(
      {required String idUsuario,
      required String fecha,
      required String producto}) async {
    try {
      final data = await consumoClientesAPI.consumoClientes(
        idUsuario: idUsuario,
        fecha: fecha,
        producto: producto,
      );
      return data;
    } catch (e) {
      print("Error al obtener consumo de clientes: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cortes del día ${fecha}"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: verCorteAPI.obtenerCortes(fecha: fecha),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("Error al obtener cortes: ${snapshot.error}");
            return Center(child: Text("Error>>>: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("No se encontraron cortes para esta fecha."));
          } else {
            final cortes = snapshot.data!;
            return ListView.builder(
              itemCount: cortes.length,
              itemBuilder: (context, index) {
                final corte = cortes[index];
                return Card(
                  child: ListTile(
                    title: Text("${corte['usuario']}"),
                    subtitle: Text(
                        "Producto: ${corte['producto']} - Efectivo Entregado: \$${corte['efectivoEntregado']}"),
                    onTap: () async {
                      final consumoClientes = await _consumoClientes(
                        idUsuario: corte['idUsuario'].toString(),
                        fecha: fecha,
                        producto: corte['producto'].toString(),
                      );

                      _showCorteDetails(context, corte, consumoClientes);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // ======== FORMATO DINERO ========
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2);

  String _fmt(double valor) => _currencyFormat.format(valor);

  // Método auxiliar para convertir valores a double de forma segura
  double _parseToDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.tryParse(value) ?? 0;
    } else {
      return 0;
    }
  }

  void _showCorteDetails(BuildContext context, Map<String, dynamic> corte,
      List<dynamic> consumoClientes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Corte - ${corte['usuario']}",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Producto: ${corte['producto']}\n",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color.fromARGB(255, 0, 27, 180)),
              ),
              Text("Venta: ${_fmt(_parseToDouble(corte['venta']))}\n",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(
                  "Santander: ${_fmt(_parseToDouble(corte['santander']))}\nMifel: ${_fmt(_parseToDouble(corte['mifel']))}\nMonedero: ${_fmt(_parseToDouble(corte['efecticar']))}\n",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Consumo de Clientes:"),
              if (consumoClientes.isNotEmpty)
                ...consumoClientes.map((cliente) => Text(
                    "- ${cliente['razonSocial']} - ${_fmt(_parseToDouble(cliente['importe']))} \n"))
              else
                const Text("Sin consumo de clientes"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }
}
