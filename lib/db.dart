import 'package:mysql1/mysql1.dart';

class Db {
  final settings = ConnectionSettings(
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
      final conn = await connection;
      final results = await conn.query('SELECT * FROM Usuarios');
      for (var row in results) {
        print('Usuario: ${row[1]}, Pass: ${row[2]}');
      }
      await conn.close();
    } catch (e) {
      print(
          'Error al consultar la base de datos>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: $e');
    }
  }

  // ============= NUEVO: OBTENER BAUCHERS (para editar) ============
  Future<List<double>> obtenerBauchers({
    required String tabla,
    required int idUsuario,
    required String fecha, // "dd/MM/yyyy"
  }) async {
    MySqlConnection? conn;
    final importes = <double>[];

    try {
      conn = await connection;
      final results = await conn.query(
        'SELECT importe FROM $tabla WHERE idUsuario = ? AND fecha = ?',
        [idUsuario, fecha],
      );

      for (final row in results) {
        final num valor = row['importe'];
        importes.add(valor.toDouble());
      }
    } catch (e) {
      print('Error al obtener bauchers de $tabla: $e');
    } finally {
      await conn?.close();
    }

    return importes;
  }

  // ============= NUEVO: REEMPLAZAR BAUCHERS (DELETE + INSERT) ============
  Future<void> reemplazarBauchers({
    required String tabla,
    required int idUsuario,
    required String fecha, // "dd/MM/yyyy"
    required List<double> importes,
  }) async {
    MySqlConnection? conn;

    try {
      conn = await connection;

      await conn.transaction((txn) async {
        // Borramos lo que hubiera para ese usuario + fecha
        await txn.query(
          'DELETE FROM $tabla WHERE idUsuario = ? AND fecha = ?',
          [idUsuario, fecha],
        );

        // Insertamos los nuevos importes
        for (final importe in importes) {
          await txn.query(
            '''
            INSERT INTO $tabla (idUsuario, fecha, importe)
            VALUES (?, ?, ?)
            ''',
            [idUsuario, fecha, importe],
          );
        }
      });

      print(
          'Bauchers de $tabla guardados para usuario $idUsuario, fecha $fecha');
    } catch (e) {
      print('Error al guardar bauchers en $tabla: $e');
      rethrow;
    } finally {
      await conn?.close();
    }
  }
}
