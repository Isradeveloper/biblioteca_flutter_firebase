import 'package:biblioteca_flutter_firebase/screens/HomePage.dart';
import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils/common_widgets/gradient_background.dart';
import '../values/app_colors.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';

import 'package:carousel_slider/carousel_slider.dart';

class EventosPage extends StatefulWidget {
  final Usuario? user;
  const EventosPage({super.key, required this.user});

  @override
  State<EventosPage> createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  late Future<Usuario?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UsuariosServices().iniciarAppUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primaryColor,
        iconSize: 40,
        unselectedFontSize: 14,
        onTap: (value) {
          if (value == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ));
          } else {
            print("nuevo");
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: AppColors.darkBlue,
              size: 40,
            ),
            label: "Regresar al menú",
            backgroundColor: AppColors.darkBlue,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
              size: 40,
              color: AppColors.darkBlue,
            ),
            label: "Agregar nuevo",
          ),
        ],
      ),
      body: FutureBuilder<Usuario?>(
        future: userFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return Container(
              color: AppColors.darkBlue,
              child: ListView(
                children: [
                  //* HEADER
                  Stack(
                    children: [
                      const GradientBackground(
                        colors: [
                          AppColors.darkBlue,
                          AppColors.primaryDarkColor
                        ],
                        children: [
                          Text(
                            "Eventos",
                            style: AppTheme.titleLarge,
                          ),
                          SizedBox(height: 6),
                          Text("Administra los eventos disponibles",
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

                  //* CONTENIDO

                  Container(
                      width: MediaQuery.of(context).size.width,
                      height: 700,
                      padding: const EdgeInsets.all(25),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 70),
                        child: ListView.builder(
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            final product = null;
                            return ProductCard(
                              imageUrl:
                                  "https://www.mascotahogar.com/1920x1080/wallpaper-de-buscando-a-nemo.jpg",
                              title: "12345678910 12345678910 12345678910",
                              subtitle: "12345678910 12345678910 12345678910",
                              onEditPressed: () {
                                // Handle edit functionality here
                                print('Edit product: ${index}');
                              },
                              onDeletePressed: () {
                                // Handle delete functionality here
                                print('Delete product: ${index}');
                              },
                            );
                          },
                        ),
                      ))
                ],
              ),
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

class ProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final Function onEditPressed;
  final Function onDeletePressed;

  const ProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onEditPressed,
    required this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkBlueShadow,
      child: Row(
        children: [
          Container(
            width: 150,
            height: 150,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10),
            width: 270,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  color: AppColors.white,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.delete),
                    color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
