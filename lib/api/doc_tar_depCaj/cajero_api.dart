import '../consumoPHP.dart';

class CajeroApi {
  final ApiService api;
  CajeroApi(this.api);

  Future<List<Map<String, dynamic>>> obtenerDepositosCajero({
    required int idUsuario,
    required String fecha,
    required String producto,
  }) async {
    final res = await api.postJson('Cajero/obtener.php', {
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

  // registro de depositos cajero
  Future<void> registrarDepositosCajero({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
  }) async {
    await api.postJson('Cajero/registrar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
    });
  }

  // Actualizacion de depositos cajero
  Future<void> actualizarDepositosCajero({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
    required String producto,
  }) async {
    await api.postJson('Cajero/actualizar.php', {
      'idUsuario': idUsuario,
      'fecha': fecha,
      'producto': producto,
      'importes': importes,
    });
  }

  // Eliminacion de depositos cajero
  Future<void> eliminarDepositosCajero(int idCajero) async {
    await api.postJson('Cajero/eliminar.php', {
      'idCajero': idCajero,
    });
  }
}
