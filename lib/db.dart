import 'package:mysql1/mysql1.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Db {
  final settings = ConnectionSettings(
    host: dotenv.env['DB_HOST'] ?? '',
    port: int.parse(dotenv.env['DB_PORT'] ?? '3306'),
    user: dotenv.env['DB_USER'] ?? '',
    password: dotenv.env['DB_PASS'] ?? '',
    db: dotenv.env['DB_NAME'] ?? '',
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

  // Trae registros MIFEL por usuario + fecha (para saber si existe y para eliminar por id)
  Future<List<Map<String, dynamic>>> obtenerMifelPorUsuarioFecha({
    required int idUsuario,
    required String fecha,
  }) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT idMifel, importe FROM Mifel WHERE idUsuario = ? AND fecha = ? ORDER BY idMifel ASC',
      [idUsuario, fecha],
    );

    await conn.close();

    return results.map((row) {
      return {
        'idMifel': int.parse(row[0].toString()),
        'importe': num.parse(row[1].toString()),
      };
    }).toList();
  }

  // Trae registros EFETICARD por usuario + fecha (para saber si existe y para eliminar por id)
  Future<List<Map<String, dynamic>>> obtenerEfecticardPorUsuarioFecha({
    required int idUsuario,
    required String fecha,
  }) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT idEfecticar, importe FROM Efecticar WHERE idUsuario = ? AND fecha = ? ORDER BY idEfecticar ASC',
      [idUsuario, fecha],
    );

    await conn.close();

    return results.map((row) {
      return {
        'idEfecticar': int.parse(row[0].toString()),
        'importe': num.parse(row[1].toString()),
      };
    }).toList();
  }

  // Trae registros EFETICARD por usuario + fecha (para saber si existe y para eliminar por id)
  Future<List<Map<String, dynamic>>> obtenerClientePorUsuarioFecha({
    required int idUsuario,
    required String fecha,
  }) async {
    final conn = await connection;
    final results = await conn.query(
      'SELECT idCliente, importe FROM Clientes WHERE idUsuario = ? AND fecha = ? ORDER BY idCliente ASC',
      [idUsuario, fecha],
    );

    await conn.close();

    return results.map((row) {
      return {
        'idCliente': int.parse(row[0].toString()),
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

  // Inserta varios bauchers (primer guardado)
  Future<void> insertarMifel({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
  }) async {
    final conn = await connection;

    for (final imp in importes) {
      await conn.query(
        'INSERT INTO Mifel (idUsuario, fecha, importe) VALUES (?, ?, ?)',
        [idUsuario, fecha, imp],
      );
    }

    await conn.close();
  }

  // Inserta varios bauchers (primer guardado)
  Future<void> insertarEfecticard({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
  }) async {
    final conn = await connection;

    for (final imp in importes) {
      await conn.query(
        'INSERT INTO Efecticar (idUsuario, fecha, importe) VALUES (?, ?, ?)',
        [idUsuario, fecha, imp],
      );
    }

    await conn.close();
  }

  // Inserta varios bauchers (primer guardado)
  Future<void> insertarCliente({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
  }) async {
    final conn = await connection;

    for (final imp in importes) {
      await conn.query(
        'INSERT INTO Clientes (idUsuario, fecha, importe) VALUES (?, ?, ?)',
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

  Future<void> eliminarMifelPorId(int idMifel) async {
    final conn = await connection;
    await conn.query(
      'DELETE FROM Mifel WHERE idMifel = ?',
      [idMifel],
    );
    await conn.close();
  }

  Future<void> eliminarEfecticardPorId(int idEfecticar) async {
    final conn = await connection;
    await conn.query(
      'DELETE FROM Efecticar WHERE idEfecticar = ?',
      [idEfecticar],
    );
    await conn.close();
  }

  Future<void> eliminarClientePorId(int idCliente) async {
    final conn = await connection;
    await conn.query(
      'DELETE FROM Clientes WHERE idCliente = ?',
      [idCliente],
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

  Future<void> reemplazarMifelPorUsuarioFecha({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
  }) async {
    final conn = await connection;

    // borrar todos los del día/usuario
    await conn.query(
      'DELETE FROM Mifel WHERE idUsuario = ? AND fecha = ?',
      [idUsuario, fecha],
    );

    // insertar los nuevos
    for (final imp in importes) {
      await conn.query(
        'INSERT INTO Mifel (idUsuario, fecha, importe) VALUES (?, ?, ?)',
        [idUsuario, fecha, imp],
      );
    }

    await conn.close();
  }

  Future<void> reemplazarEfecticardPorUsuarioFecha({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
  }) async {
    final conn = await connection;

    // borrar todos los del día/usuario
    await conn.query(
      'DELETE FROM Efecticar WHERE idUsuario = ? AND fecha = ?',
      [idUsuario, fecha],
    );

    // insertar los nuevos
    for (final imp in importes) {
      await conn.query(
        'INSERT INTO Efecticar (idUsuario, fecha, importe) VALUES (?, ?, ?)',
        [idUsuario, fecha, imp],
      );
    }

    await conn.close();
  }

  Future<void> reemplazarClientePorUsuarioFecha({
    required int idUsuario,
    required String fecha,
    required List<double> importes,
  }) async {
    final conn = await connection;

    // borrar todos los del día/usuario
    await conn.query(
      'DELETE FROM Clientes WHERE idUsuario = ? AND fecha = ?',
      [idUsuario, fecha],
    );

    // insertar los nuevos
    for (final imp in importes) {
      await conn.query(
        'INSERT INTO Clientes (idUsuario, fecha, importe) VALUES (?, ?, ?)',
        [idUsuario, fecha, imp],
      );
    }

    await conn.close();
  }

  Future<void> insertarCorte({
    required String fecha,
    required int idUsuario,
    required String usuario,
    required double venta,
    required double santander,
    required double mifel,
    required double efecticar,
    required double depositos,
    required double buzon,
    required double gastos,
    required double clientes,
    required double efectivoEntregado,
  }) async {
    final conn = await connection;

    try {
      await conn.query(
        'INSERT INTO Corte (fecha, idUsuario, usuario, venta, santander, mifel, efecticar, depositos, buzon, gastos, clientes, efectivoEntregado) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        [
          fecha,
          idUsuario,
          usuario,
          venta,
          santander,
          mifel,
          efecticar,
          depositos,
          buzon,
          gastos,
          clientes,
          efectivoEntregado
        ],
      );

      await conn.close();
    } catch (e) {
      print('Error al insertar corte: $e');
    }
  }
}
