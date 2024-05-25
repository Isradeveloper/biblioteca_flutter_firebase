import 'package:biblioteca_flutter_firebase/screens/HomePage.dart';
import 'package:biblioteca_flutter_firebase/screens/LibrosPage.dart';
import 'package:biblioteca_flutter_firebase/screens/Validate.dart';
import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/prestamos.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import '../services/libros.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_colors.dart';
import '../values/app_theme.dart';

class PrestamosPage extends StatefulWidget {
  final Usuario? user;
  const PrestamosPage({super.key, required this.user});

  @override
  State<PrestamosPage> createState() => _PrestamosPageState();
}

class _PrestamosPageState extends State<PrestamosPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> showNewBook(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ModalFormulario(
            onCompleted: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrestamosPage(user: widget.user),
                  ));
            },
            edit: false,
            libro: null,
          );
        });
  }

  Future<dynamic> showEditBook(BuildContext context, Libro evento) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ModalFormulario(
            onCompleted: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrestamosPage(user: widget.user),
                  ));
            },
            edit: true,
            libro: evento,
          );
        });
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
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LibrosPage(
                    user: widget.user,
                  ),
                ));
          }
        },
        items: const [
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
              Icons.book,
              size: 40,
              color: AppColors.darkBlue,
            ),
            label: "Libros",
          ),
        ],
      ),
      body: Container(
        color: AppColors.darkBlue,
        child: ListView(
          children: [
            //* HEADER
            Stack(
              children: [
                const GradientBackground(
                  colors: [AppColors.darkBlue, AppColors.primaryDarkColor],
                  children: [
                    Text(
                      "Prestamos",
                      style: AppTheme.titleLarge,
                    ),
                    SizedBox(height: 6),
                    Text("Administra los prestamos",
                        style: AppTheme.textMedium),
                  ],
                ),
                Positioned(
                  top: 25,
                  right: 20,
                  child: ElevatedButton(
                    child: const Text("Cerrar sesión"),
                    onPressed: () async {
                      await AuthServices().signOut().then((value) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Validate(),
                            ));
                      });
                    },
                  ),
                ),
              ],
            ),

            //* CONTENIDO

            Container(
                width: MediaQuery.of(context).size.width,
                height: 700,
                padding: const EdgeInsets.all(25),
                child: Container(
                    margin: const EdgeInsets.only(bottom: 70),
                    child: StreamBuilder<List<LibroPrestamo>>(
                      stream: PrestamosServices().obtenerLibrosPrestamosUsuario(
                          usuarioUid: widget.user!.uid, rol: widget.user!.rol),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: Text(
                            "No hay prestamos registrados",
                            style: AppTheme.textMediumPrimary,
                          ));
                        } else {
                          List<LibroPrestamo> listadoPrestamos = snapshot.data!;
                          return ListView.builder(
                              itemCount: listadoPrestamos.length,
                              itemBuilder: ((context, index) {
                                LibroPrestamo libroPrestamo =
                                    listadoPrestamos[index];
                                return LibroCard(
                                  libroPrestamo: libroPrestamo,
                                  onCompletar: () {
                                    QuickAlert.show(
                                        context: context,
                                        type: QuickAlertType.warning,
                                        title: 'Confirmación',
                                        text: "¿Estás seguro?",
                                        confirmBtnText: "Aceptar",
                                        cancelBtnText: "Cancelar",
                                        showCancelBtn: true,
                                        onConfirmBtnTap: () {
                                          Navigator.of(context).pop();

                                          PrestamosServices()
                                              .completarPrestamo(
                                                  uid:
                                                      libroPrestamo.prestamoUid,
                                                  libro: libroPrestamo.libro)
                                              .then((respuesta) {
                                            // if (respuesta["success"] ==
                                            //     true) {
                                            //   QuickAlert.show(
                                            //     context: context,
                                            //     type: QuickAlertType
                                            //         .success,
                                            //     title: '¡Genial!',
                                            //     confirmBtnText: "Aceptar",
                                            //     confirmBtnColor:
                                            //         AppColors.darkBlue,
                                            //     text: respuesta["msg"],
                                            //   );
                                            // } else {
                                            //   QuickAlert.show(
                                            //     context: context,
                                            //     type:
                                            //         QuickAlertType.error,
                                            //     title: 'Oops...',
                                            //     confirmBtnText: "Aceptar",
                                            //     confirmBtnColor:
                                            //         AppColors.darkBlue,
                                            //     text: respuesta["msg"],
                                            //   );
                                            // }
                                          });
                                        });
                                  },
                                );
                              }));
                        }
                      },
                    )))
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class LibroCard extends StatelessWidget {
  final LibroPrestamo libroPrestamo;
  void Function() onCompletar;

  LibroCard(
      {super.key, required this.libroPrestamo, required this.onCompletar});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkBlueShadow,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Image.network(
              libroPrestamo.libro.portada,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    libroPrestamo.libro.titulo.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primaryColor,
                    ),
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis if text overflows
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        "Autor: ",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                      Text(
                        libroPrestamo.libro.autor.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primaryColor),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                    ],
                  ),
                  // Row(
                  //   children: [
                  //     const Text(
                  //       "Prestado por: ",
                  //       style: TextStyle(fontSize: 14, color: Colors.white),
                  //       overflow: TextOverflow
                  //           .ellipsis, // Add ellipsis if text overflows
                  //     ),
                  //     Text(
                  //       libroPrestamo.usuario.nombres.toUpperCase(),
                  //       style: const TextStyle(
                  //           fontSize: 14, color: AppColors.primaryColor),
                  //       overflow: TextOverflow
                  //           .ellipsis, // Add ellipsis if text overflows
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: onCompletar,
                icon: const Icon(Icons.check_circle),
                color: AppColors.white,
              )
            ],
          ),
        ],
      ),
    );
  }
}
