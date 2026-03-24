import '../consumoPHP.dart';

class MifelApi {
  final ApiService api;
  MifelApi(this.api);

  Future<List<Map<String, dynamic>>> obtenerTarjetasMifel({
    required int idUsuario,
    required String fecha,
    required String producto,
  }) async {
    final res = await api.postJson('Mifel/obtener.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
    });

    final data = res['data'];

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      throw Exception('Respuesta inesperada: "data" no es una lista');
    }
  }

  // registro de targetas mifel
  Future<void> registrarTarjetasMifel({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
  }) async {
    await api.postJson('Mifel/registrar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
    });
  }

  // Actualizacion de tarjeta mifel
  Future<void> actualizarTarjetasMifel({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
  }) async {
    await api.postJson('Mifel/actualizar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
    });
  }

  // Eliminacion de tarjeta mifel
  Future<void> eliminarTarjetaMifel(int idMifel) async {
    await api.postJson('Mifel/eliminar.php', {
      'idMifel': idMifel,
    });
  }
}
