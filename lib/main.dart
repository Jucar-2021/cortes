import 'package:flutter/material.dart';
import 'db.dart';
import 'loggin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cortes Despachador",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Cortes(),
    );
  }
}

class Cortes extends StatefulWidget {
  const Cortes({super.key});

  @override
  State<Cortes> createState() => _CortesState();
}

class _CortesState extends State<Cortes> {
  TextEditingController usuario = TextEditingController();
  TextEditingController pass = TextEditingController();

  //prueba de conexxion mediante el uso del metodo creado en db.dart
  late Future<void> consultabd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    usuario.text = "";
    pass.text = "";
    Db conn = Db();
    consultabd = conn.consultarBD();
  }

  //consulta bd

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "Inicio de Sesion",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Bienvenido al sistema de Cortes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextField(
              maxLength: 10,
              controller: usuario,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Usuario',
                hintText: 'Ingrese su usuario',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              maxLength: 10,
              controller: pass,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
                hintText: 'Ingrese su contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                bool inicioExitoso =
                    await consultarUsuario(usuario.text, pass.text);
                if (inicioExitoso) {
                  // Navegar a la siguiente pantalla
                  print("validacion correcta");
                } else {
                  // Mostrar mensaje de error
                  print("validacion incorrecta");
                }
              },
              child: Text('Iniciar Sesión', style: TextStyle(fontSize: 20)),
            ),
            TextButton.icon(
              onPressed: () {
                //aceptar pagina de crear usuario
              },
              label: Text('Crear Usuario',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
              icon: Icon(Icons.person_add_alt_1, color: Colors.black, size: 30),
            )
          ],
        ),
      ),
    );
  }
}
