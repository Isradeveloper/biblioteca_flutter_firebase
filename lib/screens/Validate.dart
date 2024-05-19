import 'package:biblioteca_flutter_firebase/screens/HomePage.dart';
import 'package:biblioteca_flutter_firebase/screens/LoginPage.dart';
import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Validate extends StatefulWidget {
  const Validate({Key? key}) : super(key: key);

  @override
  State<Validate> createState() => _ValidateState();
}

class _ValidateState extends State<Validate> {
  late Stream<User?> _userStream;

  @override
  void initState() {
    super.initState();
    _userStream = AuthServices().authStateChanges;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
