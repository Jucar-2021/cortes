import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    fecha = widget.fecha;
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
                return ListTile(
                  title: Text(
                      "Usuario: ${corte['usuario']} - Venta: \$${corte['venta']}"),
                  subtitle: Text(
                      "Producto: ${corte['producto']} - Efectivo Entregado: \$${corte['efectivoEntregado']}"),
                );
              },
            );
          }
        },
      ),
    );
  }
}
