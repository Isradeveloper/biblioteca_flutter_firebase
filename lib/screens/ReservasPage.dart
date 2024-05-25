import 'package:biblioteca_flutter_firebase/screens/HomePage.dart';
import 'package:biblioteca_flutter_firebase/screens/PrestamosPage.dart';
import 'package:biblioteca_flutter_firebase/screens/Validate.dart';
import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:biblioteca_flutter_firebase/services/reservas.dart';
import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:quickalert/quickalert.dart';
import '../components/app_text_form_field.dart';
import '../utils/common_widgets/gradient_background.dart';
import '../values/app_colors.dart';
import '../values/app_regex.dart';
import '../values/app_strings.dart';
import '../values/app_theme.dart';
import 'package:intl/intl_standalone.dart';

class ReservasPage extends StatefulWidget {
  final Usuario? user;
  const ReservasPage({super.key, required this.user});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  late Future<Usuario?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UsuariosServices().iniciarAppUsuario();
  }

  Future<dynamic> showNewReserva(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ModalFormulario(
            usuario: widget.user,
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
            showNewReserva(context);
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
                            "Reservas",
                            style: AppTheme.titleLarge,
                          ),
                          SizedBox(height: 6),
                          Text("Administra reservas",
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
                          child: StreamBuilder<List<Reserva>>(
                            stream: ReservasServices().listarReservas(user),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else {
                                List<Reserva> listadoReservas = snapshot.data!;
                                return ListView.builder(
                                    itemCount: listadoReservas.length,
                                    itemBuilder: ((context, index) {
                                      Reserva reserva = listadoReservas[index];
                                      return ReservaCard(
                                          usuario: user,
                                          reserva: reserva,
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
                                                  QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.loading,
                                                    title: 'Cargando',
                                                    showConfirmBtn: false,
                                                    text: "Por favor, espere",
                                                  );

                                                  ReservasServices()
                                                      .completarReserva(
                                                          uid: reserva.uid)
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

                                                  ReservasServices()
                                                      .cancelarReserva(
                                                          uid: reserva.uid)
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

class ReservaCard extends StatelessWidget {
  final Usuario usuario;
  final Reserva reserva;
  final void Function() onDelete;
  final void Function() onCompletar;

  const ReservaCard({
    super.key,
    required this.usuario,
    required this.reserva,
    required this.onDelete,
    required this.onCompletar,
  });

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
              "assets/biblioteca.jpg",
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
                    // "${reserva.fecha.year}-${reserva.fecha.month}-${reserva.fecha.day} ${reserva.fecha.hour}:${reserva.fecha.minute}",
                    DateFormat('yyyy-MM-dd HH:mm').format(reserva.fecha),

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
                        "Motivo: ",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        overflow: TextOverflow
                            .ellipsis, // Add ellipsis if text overflows
                      ),
                      Text(
                        reserva.motivo.toUpperCase(),
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
              usuario.rol == "administrador" && reserva.completado == false
                  ? IconButton(
                      onPressed: onCompletar,
                      icon: const Icon(Icons.check_circle),
                      color: AppColors.white,
                    )
                  : Container(),
              reserva.usuarioUid == usuario.uid && reserva.completado == false
                  ? IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    )
                  : Container()
            ],
          ),
        ],
      ),
    );
  }
}

class ModalFormulario extends StatefulWidget {
  final Usuario? usuario;

  const ModalFormulario({super.key, required this.usuario});

  @override
  State<ModalFormulario> createState() => _ModalFormularioState();
}

class _ModalFormularioState extends State<ModalFormulario> {
  bool loading = false;
  DateTime? datetime;

  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  late final TextEditingController fechaController;
  late final TextEditingController motivoController;

  void initializeControllers() {
    fechaController = TextEditingController()..addListener(controllerListener);
    motivoController = TextEditingController()..addListener(controllerListener);
  }

  void disposeControllers() {
    fechaController.dispose();
    motivoController.dispose();
  }

  void controllerListener() {
    final titulo = fechaController.text;
    final autor = motivoController.text;

    if (titulo.isEmpty && autor.isEmpty) return;

    if (titulo.isNotEmpty && AppRegex.sevenMinRegex.hasMatch(autor)) {
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
  }

  Future<void> selectDate() async {
    await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    ).then((selectedDate) {
      if (selectedDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((selectedTime) {
          // Handle the selected date and time here.
          if (selectedTime != null) {
            DateTime selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            setState(() {
              fechaController.text = selectedDateTime.toString();
              datetime = selectedDateTime;

              if (fechaController.text.isNotEmpty &&
                  AppRegex.sevenMinRegex.hasMatch(motivoController.text)) {
                fieldValidNotifier.value = true;
              } else {
                fieldValidNotifier.value = false;
              }
            });
          }
        });
      }
    });
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
                  const Text(
                    AppStrings.createReserva,
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
                            controller: fechaController,
                            labelText: AppStrings.fecha,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterFecha
                                  : null;
                            },
                            readOnly: true,
                            onTap: selectDate,
                          ),
                          AppTextFormField(
                            controller: motivoController,
                            labelText: AppStrings.motivo,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => _formKey.currentState?.validate(),
                            validator: (value) {
                              return value!.isEmpty
                                  ? AppStrings.pleaseEnterMotivo
                                  : AppRegex.sevenMinRegex.hasMatch(value)
                                      ? null
                                      : AppStrings.invalidMotivo;
                            },
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

                                            ReservasServices()
                                                .crearReserva(
                                                    fecha: datetime,
                                                    motivo:
                                                        motivoController.text,
                                                    usuarioUid:
                                                        widget.usuario!.uid)
                                                .then((respuesta) {
                                              toogleLoading();

                                              if (respuesta["success"] ==
                                                  true) {
                                                QuickAlert.show(
                                                  context: context,
                                                  type: QuickAlertType.success,
                                                  title: '¡Genial!',
                                                  confirmBtnText: "Aceptar",
                                                  onConfirmBtnTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ReservasPage(
                                                            user:
                                                                widget.usuario,
                                                          ),
                                                        ));
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
                                          },
                                          confirmBtnColor: AppColors.darkBlue,
                                          text:
                                              "¿Estás seguro de realizar esta acción?",
                                        );
                                      }
                                    : null,
                                child: const Text(AppStrings.createReserva),
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
