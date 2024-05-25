import 'package:biblioteca_flutter_firebase/screens/HomePage.dart';
import 'package:biblioteca_flutter_firebase/screens/Validate.dart';
import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

import '../components/app_text_form_field.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_colors.dart';
import '../values/app_constants.dart';
import '../values/app_regex.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';

class UsuariosPage extends StatefulWidget {
  final Usuario? user;
  const UsuariosPage({super.key, required this.user});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  late Future<Usuario?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UsuariosServices().iniciarAppUsuario();
  }

  Future<dynamic> showNewUsuario(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ModalFormulario(
            onCompleted: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsuariosPage(user: widget.user),
                  ));
            },
            edit: false,
            usuario: null,
          );
        });
  }

  Future<dynamic> showEditUsuario(BuildContext context, Usuario usuario) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ModalFormulario(
            onCompleted: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsuariosPage(user: widget.user),
                  ));
            },
            edit: true,
            usuario: usuario,
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
            showNewUsuario(context);
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
          )
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
                            "Usuarios",
                            style: AppTheme.titleLarge,
                          ),
                          SizedBox(height: 6),
                          Text("Administra los usuarios",
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
                          child: StreamBuilder<List<Usuario>>(
                            stream: UsuariosServices().listarUsuarios(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else {
                                List<Usuario> listadoUsuarios = snapshot.data!;
                                return ListView.builder(
                                    itemCount: listadoUsuarios.length,
                                    itemBuilder: ((context, index) {
                                      Usuario usuario = listadoUsuarios[index];
                                      return UsuarioCard(
                                        usuario: usuario,
                                        onEdit: () {
                                          showEditUsuario(context, usuario);
                                        },
                                      );
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

class UsuarioCard extends StatelessWidget {
  final Function onEdit;
  final Usuario usuario;

  const UsuarioCard({super.key, required this.onEdit, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkBlueShadow,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Image.asset(
              "assets/usuario.jpg",
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
                    usuario.uid.toUpperCase(),
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
                        "Nombres: ",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                      Text(
                        usuario.nombres.toUpperCase(),
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
                        "Apellidos: ",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                      Text(
                        usuario.apellidos.toUpperCase(),
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
                        "Rol: ",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                      Text(
                        usuario.rol.toUpperCase(),
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
              IconButton(
                onPressed: () {
                  onEdit();
                },
                icon: const Icon(Icons.edit),
                color: AppColors.white,
              )
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
  final Usuario? usuario;

  const ModalFormulario(
      {super.key,
      required this.onCompleted,
      required this.edit,
      required this.usuario});

  @override
  State<ModalFormulario> createState() => _ModalFormularioState();
}

class _ModalFormularioState extends State<ModalFormulario> {
  bool loading = false;
  bool administrador = false;

  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> confirmPasswordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  late final TextEditingController nombresController;
  late final TextEditingController apellidosController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController passwordRController;

  void initializeControllers() {
    nombresController = TextEditingController()
      ..addListener(controllerListener);
    apellidosController = TextEditingController()
      ..addListener(controllerListener);
    emailController = TextEditingController()..addListener(controllerListener);
    passwordController = TextEditingController()
      ..addListener(controllerListener);
    passwordRController = TextEditingController()
      ..addListener(controllerListener);
  }

  void disposeControllers() {
    nombresController.dispose();
    apellidosController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordRController.dispose();
  }

  void controllerListener() {
    final nombres = nombresController.text;
    final apellidos = apellidosController.text;
    final email = emailController.text;
    final password = passwordController.text;
    final passwordR = passwordController.text;

    if (nombres.isEmpty && apellidos.isEmpty && email.isEmpty) return;

    if ((!widget.edit &&
            AppRegex.sevenMinRegex.hasMatch(password) &&
            passwordR == password &&
            AppRegex.sevenMinRegex.hasMatch(email)) ||
        (widget.edit &&
            AppRegex.sevenMinRegex.hasMatch(nombres) &&
            AppRegex.sevenMinRegex.hasMatch(apellidos))) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
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
    if (widget.edit == true && widget.usuario != null) {
      setState(() {
        toogleLoading();
        nombresController.text = widget.usuario!.nombres;
        apellidosController.text = widget.usuario!.apellidos;
        administrador = widget.usuario!.rol == "administrador" ? true : false;
        toogleLoading();
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
                        ? AppStrings.editUsuario
                        : AppStrings.createUsuario,
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
                            controller: nombresController,
                            labelText: AppStrings.nombre,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterNombre
                                  : AppRegex.sevenMinRegex.hasMatch(value)
                                      ? null
                                      : AppStrings.invalidName;
                            },
                          ),
                          AppTextFormField(
                            controller: apellidosController,
                            labelText: AppStrings.lastName,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterLastName
                                  : AppRegex.sevenMinRegex.hasMatch(value)
                                      ? null
                                      : AppStrings.invalidLastName;
                            },
                          ),
                          widget.edit == true
                              ? Container()
                              : Column(
                                  children: [
                                    AppTextFormField(
                                      controller: emailController,
                                      labelText: AppStrings.email,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      onChanged: (_) =>
                                          _formKey.currentState?.validate(),
                                      validator: (value) {
                                        return value!.isEmpty
                                            ? AppStrings.pleaseEnterEmailAddress
                                            : AppRegex.emailRegex
                                                    .hasMatch(value)
                                                ? null
                                                : AppStrings
                                                    .invalidEmailAddress;
                                      },
                                    ),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: passwordNotifier,
                                      builder: (_, passwordObscure, __) {
                                        return AppTextFormField(
                                          obscureText: passwordObscure,
                                          controller: passwordController,
                                          labelText: AppStrings.password,
                                          textInputAction: TextInputAction.next,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          onChanged: (_) =>
                                              _formKey.currentState?.validate(),
                                          validator: (value) {
                                            return value!.isEmpty
                                                ? AppStrings.pleaseEnterPassword
                                                : AppConstants.passwordRegex
                                                        .hasMatch(value)
                                                    ? null
                                                    : AppStrings
                                                        .invalidPassword;
                                          },
                                          suffixIcon: Focus(
                                            descendantsAreFocusable: false,
                                            child: IconButton(
                                              onPressed: () => passwordNotifier
                                                  .value = !passwordObscure,
                                              style: IconButton.styleFrom(
                                                minimumSize:
                                                    const Size.square(48),
                                              ),
                                              icon: Icon(
                                                passwordObscure
                                                    ? Icons
                                                        .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: confirmPasswordNotifier,
                                      builder: (_, confirmPasswordObscure, __) {
                                        return AppTextFormField(
                                          labelText: AppStrings.confirmPassword,
                                          controller: passwordRController,
                                          obscureText: confirmPasswordObscure,
                                          textInputAction: TextInputAction.done,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          onChanged: (_) =>
                                              _formKey.currentState?.validate(),
                                          validator: (value) {
                                            return value!.isEmpty
                                                ? AppStrings
                                                    .pleaseReEnterPassword
                                                : AppConstants.passwordRegex
                                                        .hasMatch(value)
                                                    ? passwordController.text ==
                                                            passwordRController
                                                                .text
                                                        ? null
                                                        : AppStrings
                                                            .passwordNotMatched
                                                    : AppStrings
                                                        .invalidPassword;
                                          },
                                          suffixIcon: Focus(
                                            descendantsAreFocusable: false,
                                            child: IconButton(
                                              onPressed: () =>
                                                  confirmPasswordNotifier
                                                          .value =
                                                      !confirmPasswordObscure,
                                              style: IconButton.styleFrom(
                                                minimumSize:
                                                    const Size.square(48),
                                              ),
                                              icon: Icon(
                                                confirmPasswordObscure
                                                    ? Icons
                                                        .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: AppColors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "¿Es administrador?",
                                style: AppTheme.bodySmall
                                    .copyWith(color: AppColors.white),
                              ),
                              Checkbox(
                                  value: administrador,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      administrador = value ?? false;
                                    });
                                  }),
                            ],
                          ),
                          const SizedBox(height: 15),
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
                                                widget.usuario != null) {
                                              UsuariosServices()
                                                  .actualizarUsuario(
                                                nombres: nombresController.text,
                                                apellidos:
                                                    apellidosController.text,
                                                rol: administrador == true
                                                    ? "administrador"
                                                    : "cliente",
                                                uid: widget.usuario!.uid,
                                              )
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
                                              AuthServices()
                                                  .createUserWithEmailAndPassword(
                                                      nombres: nombresController
                                                          .text,
                                                      apellidos:
                                                          apellidosController
                                                              .text,
                                                      email:
                                                          emailController.text,
                                                      password:
                                                          passwordController
                                                              .text,
                                                      rol: administrador == true
                                                          ? "administrador"
                                                          : "cliente")
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
                                    ? AppStrings.editUsuario
                                    : AppStrings.createUsuario),
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
