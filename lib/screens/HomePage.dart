import 'package:biblioteca_flutter_firebase/screens/EventosPage.dart';
import 'package:biblioteca_flutter_firebase/screens/LibrosPage.dart';
import 'package:biblioteca_flutter_firebase/screens/PrestamosPage.dart';
import 'package:biblioteca_flutter_firebase/screens/UsuariosPage.dart';
import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../services/eventos.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_colors.dart';
import '../values/app_theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'ReservasPage.dart';
import 'Validate.dart';

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
    userFuture = UsuariosServices().iniciarAppUsuario();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    userFuture = UsuariosServices().iniciarAppUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            await AuthServices().signOut().then((value) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Validate(),
                                  ));
                            });
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Eventos y novedades",
                          style: AppTheme.textMediumPrimary,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder(
                          stream: EventosServices().listarEventos(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              List<Evento> listadoEventos = snapshot.data!;
                              return CarouselSlider(
                                  options: CarouselOptions(
                                    height: 350.0,
                                    enlargeCenterPage: true,
                                    enableInfiniteScroll: true,
                                    autoPlay: true,
                                    autoPlayAnimationDuration:
                                        const Duration(milliseconds: 1000),
                                  ),
                                  items: listadoEventos.map((i) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return ImagenConDescripcion(
                                            urlImagen: i.imagen,
                                            nombre: i.nombre,
                                            descripcion: i.descripcion);
                                      },
                                    );
                                  }).toList());
                            }
                          },
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Accesos rápidos",
                          style: AppTheme.textMediumPrimary,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Expanded(
                            child: SizedBox(
                          height: 20,
                          width: MediaQuery.of(context).size.width,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  user.rol == "administrador"
                                      ? AccesoCard(
                                          nombre: "Usuarios",
                                          icono: Icons.person,
                                          ruta: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UsuariosPage(user: user),
                                                ));
                                          },
                                          usuario: user,
                                        )
                                      : Container(),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  user.rol == "administrador"
                                      ? AccesoCard(
                                          nombre: "Eventos",
                                          icono: Icons.event_available,
                                          ruta: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EventosPage(user: user),
                                                ));
                                          },
                                          usuario: user,
                                        )
                                      : Container(),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  AccesoCard(
                                    nombre: "Libros",
                                    icono: Icons.book,
                                    ruta: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                LibrosPage(user: user),
                                          ));
                                    },
                                    usuario: user,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  AccesoCard(
                                    nombre: "Prestamos",
                                    icono: Icons.bookmark_added,
                                    ruta: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PrestamosPage(user: user),
                                          ));
                                    },
                                    usuario: user,
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  AccesoCard(
                                    nombre: "Reservas",
                                    icono: Icons.calendar_month,
                                    ruta: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ReservasPage(user: user),
                                          ));
                                    },
                                    usuario: user,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ))
                      ],
                    ),
                  )
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

class AccesoCard extends StatelessWidget {
  const AccesoCard(
      {super.key,
      required this.nombre,
      required this.icono,
      required this.ruta,
      required this.usuario});

  final String nombre;
  final IconData icono;
  final void Function() ruta;
  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.darkBlueShadow,
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          width: 100,
          height: 100,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
                borderRadius: const BorderRadius.all(Radius.circular(40)),
                onTap: ruta,
                child: Center(
                  child: Icon(
                    icono,
                    size: 50,
                    color: Colors.white,
                  ),
                )),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          nombre,
          style: AppTheme.textAccesoRapido,
        )
      ],
    );
  }
}

class ImagenConDescripcion extends StatelessWidget {
  const ImagenConDescripcion(
      {super.key,
      required this.urlImagen,
      required this.nombre,
      required this.descripcion});

  final String urlImagen;
  final String nombre;
  final String descripcion;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: Stack(
          children: <Widget>[
            Image.network(
              urlImagen,
              fit: BoxFit.cover,
              width: 1000.0,
              height: 350,
            ),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0)
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        nombre,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        descripcion,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
