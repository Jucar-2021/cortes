import '../consumoPHP.dart';

class EfecticardApi {
  final ApiService api;
  EfecticardApi(this.api);

  Future<List<Map<String, dynamic>>> obtenerTarjetasEfecticard({
    required int idUsuario,
    required String fecha,
    required String producto,
  }) async {
    final res = await api.postJson('Efecticard/obtener.php', {
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

  // registro de targetas efecticard
  Future<void> registrarTarjetasEfecticard({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
  }) async {
    await api.postJson('Efecticard/registrar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
    });
  }

  // Actualizacion de tarjeta efecticard
  Future<void> actualizarTarjetasEfecticard({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
  }) async {
    await api.postJson('Efecticard/actualizar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
    });
  }

  // Eliminacion de tarjeta efecticard
  Future<void> eliminarTarjetaEfecticard(int idEfecticard) async {
    print('Eliminando tarjeta Efecticard con id: $idEfecticard');
    await api.postJson('Efecticard/eliminar.php', {
      'idEfecticard': idEfecticard,
    });
  }
}
