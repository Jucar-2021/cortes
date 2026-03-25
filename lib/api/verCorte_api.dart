import 'consumoPHP.dart';

class VerCorteAPI {
  final ApiService api;

  VerCorteAPI(this.api);

  Future<List<dynamic>> obtenerCortes({required String fecha}) async {
    final response = await api.postJson(
      'Consultas/Cortes/cortesDia.php',
      {'fecha': fecha},
    );

    final data = response['data'];
    if (data is List) {
      return data;
    }
    return [];
  }
}
