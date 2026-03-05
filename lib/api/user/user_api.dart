import '../consumoPHP.dart';

class UserApi {
  final ApiService api;
  UserApi(this.api);

  Future<bool> registrarUsuario(String usuarios, String pass) async {
    await api.postJson('User/registrar.php', {
      'usuarios': usuarios,
      'pass': pass,
    });
    return true; // si postJson no lanza excepción, fue ok
  }

  Future<int> validarUsuario(String usuario, String pass) async {
    try {
      final res = await api.postJson('User/validar.php', {
        'usuarios': usuario,
        'pass': pass,
      });

      final id = res['idUsuario'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id) ?? -1;
      return -1;
    } catch (_) {
      return -1;
    }
  }
}
