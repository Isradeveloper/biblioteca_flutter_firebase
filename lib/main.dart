import 'package:biblioteca_flutter_firebase/screens/EventosPage.dart';
import 'package:biblioteca_flutter_firebase/screens/LibrosPage.dart';
import 'package:biblioteca_flutter_firebase/screens/LoginPage.dart';
import 'package:biblioteca_flutter_firebase/screens/RegisterPage.dart';
import 'package:biblioteca_flutter_firebase/screens/Validate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/usuarios.dart';
import 'utils/helpers/navigation_helper.dart';
import 'utils/helpers/snackbar_helper.dart';
import 'values/app_strings.dart';
import 'values/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
  );
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.loginAndRegister,
      theme: AppTheme.themeData,
      initialRoute: "/",
      scaffoldMessengerKey: SnackbarHelper.key,
      navigatorKey: NavigationHelper.key,
      routes: {
        '/': (context) => const Validate(),
        'events': (context) => const EventosPage(
              user: null,
            ),
        'books': (context) => const LibrosPage(
              user: null,
            ),
        'login': (context) => const LoginPage(),
        'register': (context) => const RegisterPage()
      },
    );
  }
}
