import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils/common_widgets/gradient_background.dart';
import '../values/app_colors.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Usuario?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture =
        UsuariosServices().iniciarAppUsuario(); // Fetch data in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Usuario?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return ListView(
              children: [
                Stack(
                  children: [
                    GradientBackground(
                      colors: const [
                        AppColors.darkBlue,
                        AppColors.primaryDarkColor
                      ],
                      children: [
                        Text(
                          "¡Hola!, ${user.nombres}",
                          style: AppTheme.titleLarge,
                        ),
                        const SizedBox(height: 6),
                        const Text("¿Qué quieres leer hoy?",
                            style: AppTheme.textMedium),
                      ],
                    ),
                    Positioned(
                      top: 25,
                      right: 20,
                      child: ElevatedButton(
                        child: const Text("Cerrar sesión"),
                        onPressed: () async {
                          await AuthServices().signOut();
                        },
                      ),
                    )
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}")); // Handle errors
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
