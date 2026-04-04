import '../consumoPHP.dart';

class CorteApi {
  final ApiService api;
  CorteApi(this.api);

  Future<void> guardarCorte({
    required String fecha,
    required int idUsuario,
    required String usuario,
    required String producto,
    required double venta,
    required double santander,
    required double mifel,
    required double efecticar,
    required double depositos,
    required double buzon,
    required double gastos,
    required double clientes,
  }) async {
    await api.postJson('Cortes/registrar.php', {
      'fecha': fecha,
      'idUsuario': idUsuario,
      'usuario': usuario,
      'venta': venta,
      'santander': santander,
      'mifel': mifel,
      'efecticar': efecticar,
      'depositos': depositos,
      'buzon': buzon,
      'gastos': gastos,
      'clientes': clientes,
      'producto': producto,
    });
  }
}
