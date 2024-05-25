import 'package:biblioteca_flutter_firebase/screens/HomePage.dart';
import 'package:biblioteca_flutter_firebase/screens/PrestamosPage.dart';
import 'package:biblioteca_flutter_firebase/screens/Validate.dart';
import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/prestamos.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';

import '../components/app_text_form_field.dart';
import '../services/libros.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_colors.dart';
import '../values/app_regex.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class LibrosPage extends StatefulWidget {
  final Usuario? user;
  const LibrosPage({super.key, required this.user});

  @override
  State<LibrosPage> createState() => _LibrosPageState();
}

class _LibrosPageState extends State<LibrosPage> {
  late Future<Usuario?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UsuariosServices().iniciarAppUsuario();
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
                    builder: (context) => LibrosPage(user: widget.user),
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
                    builder: (context) => LibrosPage(user: widget.user),
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
            if (widget.user!.rol == "administrador") {
              showNewBook(context);
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrestamosPage(
                      user: widget.user,
                    ),
                  ));
            }
          }
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: AppColors.darkBlue,
              size: 40,
            ),
            label: "Regresar al menú",
            backgroundColor: AppColors.darkBlue,
          ),
          widget.user!.rol == "administrador"
              ? const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add,
                    size: 40,
                    color: AppColors.darkBlue,
                  ),
                  label: "Agregar nuevo",
                )
              : const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.bookmark_added_sharp,
                    size: 40,
                    color: AppColors.darkBlue,
                  ),
                  label: "Mis prestamos",
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
                            "Libros",
                            style: AppTheme.titleLarge,
                          ),
                          SizedBox(height: 6),
                          Text("Administra los Libros disponibles",
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
                          child: StreamBuilder<List<Libro>>(
                            stream: LibrosServices().listarLibros(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else {
                                List<Libro> listadoLibros = snapshot.data!;
                                return ListView.builder(
                                    itemCount: listadoLibros.length,
                                    itemBuilder: ((context, index) {
                                      Libro libro = listadoLibros[index];
                                      return LibroCard(
                                          rol: user.rol,
                                          libro: libro,
                                          onEdit: () {
                                            showEditBook(context, libro);
                                          },
                                          onPrestar: () {
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
                                                  QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.loading,
                                                    title: 'Cargando',
                                                    showConfirmBtn: false,
                                                    text: "Por favor, espere",
                                                  );

                                                  PrestamosServices()
                                                      .crearPrestamo(
                                                          libroUid: libro.uid,
                                                          libro: libro,
                                                          usuarioUid: user.uid,
                                                          completado: false)
                                                      .then((respuesta) {
                                                    Navigator.of(context).pop();

                                                    if (respuesta["success"] ==
                                                        true) {
                                                      QuickAlert.show(
                                                        context: context,
                                                        type: QuickAlertType
                                                            .success,
                                                        title: '¡Genial!',
                                                        confirmBtnText:
                                                            "Aceptar",
                                                        confirmBtnColor:
                                                            AppColors.darkBlue,
                                                        text: respuesta["msg"],
                                                      );
                                                    } else {
                                                      QuickAlert.show(
                                                        context: context,
                                                        type: QuickAlertType
                                                            .error,
                                                        title: 'Oops...',
                                                        confirmBtnText:
                                                            "Aceptar",
                                                        confirmBtnColor:
                                                            AppColors.darkBlue,
                                                        text: respuesta["msg"],
                                                      );
                                                    }
                                                  });
                                                });
                                          },
                                          onDelete: () {
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
                                                  QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.loading,
                                                    title: 'Cargando',
                                                    showConfirmBtn: false,
                                                    text: "Por favor, espere",
                                                  );

                                                  LibrosServices()
                                                      .eliminarLibro(
                                                          uid: libro.uid)
                                                      .then((respuesta) {
                                                    Navigator.of(context).pop();

                                                    if (respuesta["success"] ==
                                                        true) {
                                                      QuickAlert.show(
                                                        context: context,
                                                        type: QuickAlertType
                                                            .success,
                                                        title: '¡Genial!',
                                                        confirmBtnText:
                                                            "Aceptar",
                                                        confirmBtnColor:
                                                            AppColors.darkBlue,
                                                        text: respuesta["msg"],
                                                      );
                                                    } else {
                                                      QuickAlert.show(
                                                        context: context,
                                                        type: QuickAlertType
                                                            .error,
                                                        title: 'Oops...',
                                                        confirmBtnText:
                                                            "Aceptar",
                                                        confirmBtnColor:
                                                            AppColors.darkBlue,
                                                        text: respuesta["msg"],
                                                      );
                                                    }
                                                  });
                                                });
                                          });
                                    }));
                              }
                            },
                          )))
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

class LibroCard extends StatelessWidget {
  final String rol;
  final Libro libro;
  final Function onEdit;
  final Function onDelete;
  final Function onPrestar;

  const LibroCard(
      {super.key,
      required this.rol,
      required this.libro,
      required this.onEdit,
      required this.onDelete,
      required this.onPrestar});

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
              libro.portada,
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
                    libro.titulo.toUpperCase(),
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
                        libro.autor.toUpperCase(),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primaryColor),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Aplica préstamo: ",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                      Text(
                        libro.aplicaPrestamo ? "SI" : "NO",
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primaryColor),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        "Stock: ",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                      Text(
                        libro.stock.toString(),
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.primaryColor),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              rol == "administrador"
                  ? IconButton(
                      onPressed: () {
                        onEdit();
                      },
                      icon: const Icon(Icons.edit),
                      color: AppColors.white,
                    )
                  : Container(),
              rol == "administrador"
                  ? IconButton(
                      onPressed: () {
                        onDelete();
                      },
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    )
                  : Container(),
              libro.stock > 0 &&
                      libro.aplicaPrestamo == true &&
                      rol == "cliente"
                  ? IconButton(
                      onPressed: () {
                        onPrestar();
                      },
                      icon: const Icon(Icons.bookmark_added),
                      color: AppColors.white,
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }
}

class ModalFormulario extends StatefulWidget {
  final VoidCallback onCompleted;
  final bool edit;
  final Libro? libro;

  const ModalFormulario(
      {super.key,
      required this.onCompleted,
      required this.edit,
      required this.libro});

  @override
  State<ModalFormulario> createState() => _ModalFormularioState();
}

class _ModalFormularioState extends State<ModalFormulario> {
  File? selectedImage;
  bool loading = false;
  bool? aplicaPrestamo = false;

  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  late final TextEditingController tituloController;
  late final TextEditingController autorController;
  late final TextEditingController stockController;

  void initializeControllers() {
    tituloController = TextEditingController()..addListener(controllerListener);
    autorController = TextEditingController()..addListener(controllerListener);
    stockController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    tituloController.dispose();
    autorController.dispose();
    stockController.dispose();
  }

  void controllerListener() {
    final titulo = tituloController.text;
    final autor = autorController.text;
    final stock = stockController.text;

    if (titulo.isEmpty && autor.isEmpty && stock.isEmpty) return;

    if (AppRegex.sevenMinRegex.hasMatch(titulo) &&
        AppRegex.sevenMinRegex.hasMatch(autor) &&
        selectedImage != null &&
        AppRegex.positiveNumberRegex.hasMatch(stock)) {
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
        if (AppRegex.sevenMinRegex.hasMatch(tituloController.text) &&
            AppRegex.sevenMinRegex.hasMatch(autorController.text) &&
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
      if (AppRegex.sevenMinRegex.hasMatch(tituloController.text) &&
          AppRegex.sevenMinRegex.hasMatch(autorController.text) &&
          selectedImage != null &&
          AppRegex.positiveNumberRegex.hasMatch(stockController.text)) {
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
    if (widget.edit == true && widget.libro != null) {
      tituloController.text = widget.libro!.titulo;
      autorController.text = widget.libro!.autor;
      stockController.text = widget.libro!.stock.toString();
      setState(() {
        toogleLoading();
        pickImageFromUrl(widget.libro!.portada)
            .then((value) => toogleLoading());
        aplicaPrestamo = widget.libro!.aplicaPrestamo;
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
                        ? AppStrings.updateLibro
                        : AppStrings.createLibro,
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
                            controller: tituloController,
                            labelText: AppStrings.titulo,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterTitulo
                                  : AppRegex.sevenMinRegex.hasMatch(value)
                                      ? null
                                      : AppStrings.invalidTitulo;
                            },
                          ),
                          AppTextFormField(
                            controller: autorController,
                            labelText: AppStrings.autor,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterAutor
                                  : AppRegex.sevenMinRegex.hasMatch(value)
                                      ? null
                                      : AppStrings.invalidAutor;
                            },
                          ),
                          AppTextFormField(
                            controller: stockController,
                            labelText: AppStrings.stock,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterStock
                                  : AppRegex.positiveNumberRegex.hasMatch(value)
                                      ? null
                                      : AppStrings.invalidStock;
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "¿Aplica préstamo?",
                                style: AppTheme.bodySmall
                                    .copyWith(color: AppColors.white),
                              ),
                              Checkbox(
                                  value: aplicaPrestamo,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      aplicaPrestamo = value;
                                    });
                                  }),
                            ],
                          ),
                          const SizedBox(height: 15),
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
                                          fieldValidNotifier.value = false;
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
                                        QuickAlert.show(
                                          context: context,
                                          type: QuickAlertType.warning,
                                          title: 'Confirmación',
                                          confirmBtnText: "Aceptar",
                                          cancelBtnText: "Cancelar",
                                          showCancelBtn: true,
                                          onConfirmBtnTap: () {
                                            toogleLoading();
                                            Navigator.of(context).pop();

                                            if (widget.edit == true &&
                                                widget.libro != null) {
                                              LibrosServices()
                                                  .actualizarLibro(
                                                      titulo:
                                                          tituloController.text,
                                                      autor:
                                                          autorController.text,
                                                      portada: selectedImage,
                                                      uid: widget.libro!.uid,
                                                      aplicaPrestamo:
                                                          aplicaPrestamo ??
                                                              false,
                                                      stock: int.parse(
                                                          stockController.text))
                                                  .then((respuesta) {
                                                toogleLoading();

                                                if (respuesta["success"] ==
                                                    true) {
                                                  QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.success,
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
                                            } else {
                                              LibrosServices()
                                                  .crearLibro(
                                                      titulo:
                                                          tituloController.text,
                                                      autor:
                                                          autorController.text,
                                                      portada: selectedImage,
                                                      stock: int.parse(
                                                          stockController.text),
                                                      aplicaPrestamo:
                                                          aplicaPrestamo ??
                                                              false)
                                                  .then((respuesta) {
                                                toogleLoading();

                                                if (respuesta["success"] ==
                                                    true) {
                                                  QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.success,
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
                                          },
                                          confirmBtnColor: AppColors.darkBlue,
                                          text:
                                              "¿Estás seguro de realizar esta acción?",
                                        );
                                      }
                                    : null,
                                child: Text(widget.edit == true
                                    ? AppStrings.updateLibro
                                    : AppStrings.createLibro),
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
