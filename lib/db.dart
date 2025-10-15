import 'package:mysql1/mysql1.dart';

class Db {
  var settings = ConnectionSettings(
    host: 'mysql-carlos08.alwaysdata.net',
    port: 3306,
    user: 'carlos08',
    password: 'carlos.1992',
    db: 'carlos08_cortes',
  );

  Future<MySqlConnection> get connection async {
    return await MySqlConnection.connect(settings);
  }

  Future<void> consultarBD() async {
    try {
      var conn = await connection;
      var results = await conn.query('SELECT * FROM Usuarios');
      for (var row in results) {
        print('Usuario: ${row[1]}, Pass: ${row[2]}');
      }
      await conn.close();
    } catch (e) {
      print('Error al consultar la base de datos: $e');
    }
  }
}
