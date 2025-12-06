import 'package:flutter/material.dart';
import 'loggin.dart'; // para usar registrarUsuario

class Registro extends StatelessWidget {
  const Registro({super.key});

  @override
  Widget build(BuildContext context) {
    return NuevoUsuario();
  }
}

class NuevoUsuario extends StatefulWidget {
  const NuevoUsuario({super.key});

  @override
  State<NuevoUsuario> createState() => _NuevoUsuarioState();
}

class _NuevoUsuarioState extends State<NuevoUsuario> {
  final TextEditingController usuarios = TextEditingController();
  final TextEditingController pass = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    usuarios.text = "";
    pass.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Registro de Usuario",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.yellow[100],
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Registro de Nuevo Usuario",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextField(
              maxLength: 10,
              controller: usuarios,
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
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implementar lógica de registro

                if (usuarios.text.isEmpty || pass.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, complete todos los campos')),
                  );
                  return;
                }
                registrarUsuario(usuarios.text, pass.text).then((success) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Usuario registrado con éxito')),
                    );
                    Navigator.pop(context); // Volver a la pantalla anterior
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Error al registrar el usuario. Intente nuevamente.')),
                    );
                  }
                });
              },
              child: const Text('Registrar', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
