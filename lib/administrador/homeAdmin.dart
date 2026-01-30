import 'package:cortes/administrador/registroUser.dart';
import 'package:flutter/material.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 4,
        centerTitle: true,
        title: const Text(
          "Panel de Administrador",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            // ================= REGISTRAR USUARIO =================
            _adminButton(
              context,
              icon: Icons.person_add_alt_1,
              label: "Registrar Usuario",
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Registro(),
                  ),
                );
              },
            ),

            // ================= OPCIÓN FUTURA =================
            _adminButton(
              context,
              icon: Icons.delete_forever,
              label: "Reiniciar Sistema",
              color: Colors.red,
              onTap: () {
                // futura función
              },
            ),

            // ================= OPCIÓN FUTURA =================
            _adminButton(
              context,
              icon: Icons.analytics,
              label: "Reportes",
              color: Colors.deepPurple,
              onTap: () {
                // futura función
              },
            ),

            // ================= OPCIÓN FUTURA =================
            _adminButton(
              context,
              icon: Icons.settings,
              label: "Configuración",
              color: Colors.orange,
              onTap: () {
                // futura función
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===================== BOTÓN REUTILIZABLE =====================
  Widget _adminButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: color,
            ),
            const SizedBox(height: 15),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
