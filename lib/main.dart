import 'package:cortes/administrador/homeAdmin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'db.dart';
import 'captura.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("ERROR cargando .env: $e");
    // No detenemos la app
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cortes Despachador",
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      // Localizaciones: esto elimina "No MaterialLocalizations found"
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('es'),
        Locale('en', 'US'),
      ],
      home: const Cortes(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const Cortes(), // pantalla de inicio de sesión
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/captura') {
          final args = settings.arguments as Map<String, dynamic>?;

          final usuario = args?['usuario'] as String? ?? '';
          final idUsuario = args?['idUsuario'] as int? ?? 0;

          return MaterialPageRoute(
            builder: (_) => Captura(
              usuario: usuario,
              idUsuario: idUsuario,
            ),
          );
        }
        return null;
      },
    );
  }
}

class Cortes extends StatefulWidget {
  const Cortes({super.key});

  @override
  State<Cortes> createState() => _CortesState();
}

class _CortesState extends State<Cortes> {
  final TextEditingController usuario = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController claveAcceso = TextEditingController();

  late Future<void> consultabd;

  @override
  void initState() {
    super.initState();
    usuario.text = "";
    pass.text = "";
    claveAcceso.text = "";
    final Db conn = Db();
    consultabd = conn.consultarBD();
  }

  @override
  void dispose() {
    usuario.dispose();
    pass.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final user = usuario.text.trim();
    final pwd = pass.text.trim();

    final idUsuario = await obtenerId(user, pwd);
    if (!mounted) return;

    if (idUsuario != -1) {
      Navigator.pushReplacementNamed(
        context,
        '/captura',
        arguments: {'usuario': user, 'idUsuario': idUsuario},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  // metodo pra consultar IdUsuario de la bd
  Future<int> obtenerId(String usuario, String pass) async {
    final db = Db();

    try {
      final conn = await db.connection;
      final results = await conn.query(
        'SELECT idUsuario FROM Usuarios WHERE usuarios = ? AND pass = ? LIMIT 1',
        [usuario, pass],
      );

      await conn.close();

      if (results.isEmpty) return -1;

      return int.parse(results.first[0].toString());
    } catch (e) {
      print('Error login: $e');
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          "Inicio de Sesión",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Bienvenido al sistema de Cortes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextField(
              textInputAction: TextInputAction.next,
              maxLength: 10,
              controller: usuario,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                labelText: 'Usuario',
                hintText: 'Ingrese su usuario',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLength: 10,
              controller: pass,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                labelText: 'Contraseña',
                hintText: 'Ingrese su contraseña',
                prefixIcon: Icon(Icons.lock),
              ),
              onSubmitted: (_) => _iniciarSesion(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _iniciarSesion,
              child:
                  const Text('Iniciar Sesión', style: TextStyle(fontSize: 20)),
            ),
            TextButton.icon(
              onPressed: () {
                mostrarDialogoClaveAcceso(context).then((accesoConcedido) {
                  if (accesoConcedido) {
                    claveAcceso.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeAdmin(),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Acceso concedido.'),
                      ),
                    );
                  } else {
                    claveAcceso.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Acceso denegado. Clave incorrecta.'),
                      ),
                    );
                  }
                });
              },
              icon: const Icon(Icons.person_add_alt_1,
                  color: Colors.black, size: 30),
              label: const Text('opciones de administrador',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  // ventana emergente para solicitar clave de acceso al registrar usuario
  Future<bool> mostrarDialogoClaveAcceso(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clave de Acceso Requerida'),
          content: TextField(
            keyboardType: TextInputType.number,
            controller: claveAcceso,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Ingrese la clave de acceso',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final clave = int.tryParse(claveAcceso.text.trim()) ?? 0;
                if (clave == 2021) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }
}
