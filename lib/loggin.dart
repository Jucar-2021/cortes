import 'db.dart';

//funcion para consultar si exixte el usuario y pass en la bd
Future<bool> consultarUsuario(String usuario, String pass) async {
  try {
    Db db = Db();
    var conn = await db.connection;
    var results = await conn.query(
      'SELECT * FROM Usuarios WHERE usuarios = ? AND pass = ?',
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

Future<bool> registrarUsuario(String usuarios, String pass) async {
  try {
    Db db = Db();
    var conn = await db.connection;
    // Verificar si el usuario ya existe
    var checkResults = await conn.query(
      'SELECT * FROM Usuarios WHERE usuarios = ?',
      [usuarios],
    );
    if (checkResults.isNotEmpty) {
      print('El usuario ya existe. Por favor, elige otro nombre de usuario.');
      return false;
    } else {
      var results = await conn.query(
        'INSERT INTO Usuarios (usuarios, pass) VALUES (?, ?)',
        [usuarios, pass],
      );
      print('Usuario registrado con éxito. ID: ${results.insertId}');
      await conn.close();
      return true;
    }
    // Insertar el nuevo usuario
  } catch (e) {
    print('Error al registrar el usuario en la base de datos: $e');
  }
  return false;
}
