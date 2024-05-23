import 'package:biblioteca_flutter_firebase/screens/HomePage.dart';
import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/eventos.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';

import '../components/app_text_form_field.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_colors.dart';
import '../values/app_regex.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

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

  Future<dynamic> showNewEvent(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ModalFormulario(
            onCompleted: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventosPage(user: widget.user),
                  ));
            },
            edit: false,
          );
        });
  }

  Future<dynamic> showEditEvent(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ModalFormulario(
            onCompleted: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventosPage(user: widget.user),
                  ));
            },
            edit: true,
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
            showNewEvent(context);
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
                                showEditEvent(context);
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
                  onPressed: () {
                    onEditPressed();
                  },
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

class ModalFormulario extends StatefulWidget {
  final VoidCallback onCompleted;
  final bool edit;
  const ModalFormulario(
      {super.key, required this.onCompleted, required this.edit});

  @override
  State<ModalFormulario> createState() => _ModalFormularioState();
}

class _ModalFormularioState extends State<ModalFormulario> {
  File? selectedImage;
  bool loading = false;

  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  late final TextEditingController nombreController;
  late final TextEditingController descripcionController;

  void initializeControllers() {
    nombreController = TextEditingController()..addListener(controllerListener);
    descripcionController = TextEditingController()
      ..addListener(controllerListener);
  }

  void disposeControllers() {
    nombreController.dispose();
    descripcionController.dispose();
  }

  void controllerListener() {
    final nombre = nombreController.text;
    final descripcion = descripcionController.text;

    if (nombre.isEmpty && descripcion.isEmpty) return;

    if (AppRegex.sevenMinRegex.hasMatch(nombre) &&
        AppRegex.sevenMinRegex.hasMatch(descripcion) &&
        selectedImage != null) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  Future pickImageFromUrl(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final uri = Uri.parse(imageUrl);
    final imageName = path.basename(uri.path);

    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$imageName');

      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        selectedImage = file;
        if (AppRegex.sevenMinRegex.hasMatch(nombreController.text) &&
            AppRegex.sevenMinRegex.hasMatch(descripcionController.text) &&
            selectedImage != null) {
          fieldValidNotifier.value = true;
        } else {
          fieldValidNotifier.value = false;
        }
      });
    } else {
      print('Failed to load image: ${response.statusCode}');
    }
  }

  Future pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) return;

    setState(() {
      selectedImage = File(returnedImage.path);
      if (AppRegex.sevenMinRegex.hasMatch(nombreController.text) &&
          AppRegex.sevenMinRegex.hasMatch(descripcionController.text) &&
          selectedImage != null) {
        fieldValidNotifier.value = true;
      } else {
        fieldValidNotifier.value = false;
      }
    });
  }

  void toogleLoading() {
    setState(() {
      loading = !loading;
    });
  }

  @override
  void initState() {
    super.initState();
    initializeControllers();
    if (widget.edit == true) {
      nombreController.text = "1234567";
      descripcionController.text = "1234567";
      setState(() {
        toogleLoading();
        pickImageFromUrl(
                "https://firebasestorage.googleapis.com/v0/b/biblioteca-flutter-4991e.appspot.com/o/gf6QiI5ARwg1BlbiUbx3%2F1000000033.jpg?alt=media&token=d7d38993-b590-4c5e-adac-14e242be746b")
            .then((value) => toogleLoading());
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            color: AppColors.darkBlue,
            padding: const EdgeInsets.all(20),
            child: ListView(children: [
              Column(
                children: [
                  Text(
                    widget.edit == true
                        ? AppStrings.updateEvento
                        : AppStrings.createEvento,
                    style: AppTheme.textMedium,
                  ),
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppTextFormField(
                            controller: nombreController,
                            labelText: AppStrings.nombre,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterNombre
                                  : AppRegex.sevenMinRegex.hasMatch(value)
                                      ? null
                                      : AppStrings.invalidNombre;
                            },
                          ),
                          AppTextFormField(
                            controller: descripcionController,
                            labelText: AppStrings.descripcion,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterDescripcion
                                  : AppRegex.sevenMinRegex.hasMatch(value)
                                      ? null
                                      : AppStrings.invalidDescripcion;
                            },
                          ),
                          selectedImage != null
                              ? Column(
                                  children: [
                                    Center(
                                      child: SizedBox(
                                        width: 500,
                                        height: 200,
                                        child: Image.file(selectedImage!,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedImage =
                                              null; // Limpiar la imagen
                                        });
                                      },
                                      child: const Text("Limpiar imagen"),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                          child: const Text("Subir imagen"),
                                          onPressed: () {
                                            pickImageFromGallery();
                                          })
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 20),
                          ValueListenableBuilder(
                            valueListenable: fieldValidNotifier,
                            builder: (_, isValid, __) {
                              return FilledButton(
                                onPressed: isValid
                                    ? () {
                                        toogleLoading();
                                        EventosServices()
                                            .crearEvento(
                                          nombre: nombreController.text,
                                          descripcion:
                                              descripcionController.text,
                                          imagen: selectedImage,
                                        )
                                            .then((respuesta) {
                                          toogleLoading();

                                          if (respuesta["success"] == true) {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.success,
                                              title: '¡Genial!',
                                              confirmBtnText: "Aceptar",
                                              onConfirmBtnTap: () {
                                                widget.onCompleted();
                                              },
                                              confirmBtnColor:
                                                  AppColors.darkBlue,
                                              text: respuesta["msg"],
                                            );
                                          } else {
                                            QuickAlert.show(
                                              context: context,
                                              type: QuickAlertType.error,
                                              title: 'Oops...',
                                              confirmBtnText: "Aceptar",
                                              confirmBtnColor:
                                                  AppColors.darkBlue,
                                              text: respuesta["msg"],
                                            );
                                          }
                                        });
                                      }
                                    : null,
                                child: Text(widget.edit == true
                                    ? AppStrings.updateEvento
                                    : AppStrings.createEvento),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ]));
  }
}
