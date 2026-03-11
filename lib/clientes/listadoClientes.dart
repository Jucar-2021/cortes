import 'package:flutter/material.dart';
import '../api/clientes_api.dart';
import '../api/consumoPHP.dart';
import 'clientes.dart';

class Listadoclientes extends StatefulWidget {
  const Listadoclientes({
    super.key,
    required this.idUsuario,
    required this.fecha,
    required this.user,
    required this.producto,
  });

  final int idUsuario;
  final String fecha;
  final String user;
  final String producto;

  @override
  State<Listadoclientes> createState() => _ListadoclientesState();
}

class _ListadoclientesState extends State<Listadoclientes> {
  final ApiService apiService = ApiService();
  late final ClientesApi clientesApi;
  late Future<List<Map<String, dynamic>>> _futureClientes;

  @override
  void initState() {
    super.initState();
    clientesApi = ClientesApi(apiService);
    _futureClientes = fetchClientes();
  }

  Future<List<Map<String, dynamic>>> fetchClientes() async {
    try {
      final clientes = await clientesApi.getClientes();
      debugPrint("Clientes obtenidos: $clientes");
      return clientes;
    } catch (e) {
      debugPrint('Error al obtener clientes: $e');
      return [];
    }
  }

  String _formatearSaldo(dynamic saldo) {
    final value = saldo is num
        ? saldo.toDouble()
        : double.tryParse(saldo.toString()) ?? 0.0;

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Clientes'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureClientes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No se encontraron clientes'),
            );
          }

          final clientes = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final cliente = clientes[index];

              final int idCliente =
                  (cliente['IdCliente'] as num?)?.toInt() ?? 0;
              final String razonSocial =
                  cliente['razonSocial']?.toString() ?? 'Sin nombre';
              final String saldo = _formatearSaldo(cliente['saldoTotal'] ?? 0);

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        razonSocial,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Saldo total: \$ $saldo',
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ClientesCapturaPage(
                                  idCliente: idCliente,
                                  razonSocial: razonSocial,
                                  idUsuario: widget.idUsuario,
                                  fecha: widget.fecha,
                                  producto: widget.producto,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_document),
                          label: const Text('Capturar'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
