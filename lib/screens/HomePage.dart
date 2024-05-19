import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text(
            "Loading..."), // Display loading text while fetching data
      ),
      body: FutureBuilder<Usuario?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return Column(
              children: [
                Text(user.email),
                Text(user.nombres),
                FloatingActionButton(onPressed: () {
                  AuthServices().signOut();
                })
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
