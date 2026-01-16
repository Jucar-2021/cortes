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
        print('IdUsuario: ${row[0]}, Usuario: ${row[1]}, Pass: ${row[2]}');
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

  // Trae registros Santander por usuario + fecha (para saber si existe y para eliminar por id)
  Future<List<Map<String, dynamic>>> obtenerSantanderPorUsuarioFecha({
    required int idUsuario,
    required String fecha,
  }) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT idSantander, importe FROM Santander WHERE idUsuario = ? AND fecha = ? ORDER BY idSantander ASC',
      [idUsuario, fecha],
    );

    await conn.close();

    return results.map((row) {
      return {
        'idSantander': int.parse(row[0].toString()),
        'importe': num.parse(row[1].toString()),
      };
    }).toList();
  }

// Inserta varios bauchers (primer guardado)
  Future<void> insertarSantander({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
  }) async {
    final conn = await connection;

    for (final imp in importes) {
      await conn.query(
        'INSERT INTO Santander (idUsuario, fecha, importe) VALUES (?, ?, ?)',
        [idUsuario, fecha, imp],
      );
    }

    await conn.close();
  }

// Elimina un registro específico
  Future<void> eliminarSantanderPorId(int idSantander) async {
    final conn = await connection;
    await conn.query(
      'DELETE FROM Santander WHERE idSantander = ?',
      [idSantander],
    );
    await conn.close();
  }

// Actualiza reemplazando todo por idUsuario + fecha (DELETE + INSERT)
  Future<void> reemplazarSantanderPorUsuarioFecha({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
  }) async {
    final conn = await connection;

    // borrar todos los del día/usuario
    await conn.query(
      'DELETE FROM Santander WHERE idUsuario = ? AND fecha = ?',
      [idUsuario, fecha],
    );

    // insertar los nuevos
    for (final imp in importes) {
      await conn.query(
        'INSERT INTO Santander (idUsuario, fecha, importe) VALUES (?, ?, ?)',
        [idUsuario, fecha, imp],
      );
    }

    await conn.close();
  }
}
