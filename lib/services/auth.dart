import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Error al loguear usuario: $e");
      rethrow;
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String nombres,
    required String apellidos,
  }) async {
    try {
      var userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName("$nombres $apellidos");

      //* CREA USUARIO
      var userResponse = await UsuariosServices().crearUsuario(
          nombres: nombres,
          apellidos: apellidos,
          rol: "cliente",
          email: email,
          uid: userCredential.user!.uid);

      if (userResponse["success"] == false) {
        throw userResponse["msg"];
      }

      return userCredential.user;
    } catch (e) {
      // Capturar y registrar cualquier error que ocurra
      print("Error al crear usuario: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
