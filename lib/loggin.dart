import 'db.dart';

//funcion para consultar si exixte el usuario y pass en la bd
Future<bool> consultarUsuario(String usuario, String pass) async {
  try {
    Db db = Db();
    var conn = await db.connection;
    var results = await conn.query(
      'SELECT * FROM Usuarios WHERE usuario = ? AND pass = ?',
      [usuario, pass],
    );
    if (results.isNotEmpty) {
      return true;
    } else {
      print('Usuario o contraseña incorrectos.');
      return false;
    }
  } catch (e) {
    print('Error al consultar la base de datos: $e');
  }
  return false;
}
