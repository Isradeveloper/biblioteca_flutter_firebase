import 'package:biblioteca_flutter_firebase/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Usuario {
  final String nombres;
  final String apellidos;
  final String rol;
  final String email;
  final String uid;

  const Usuario({
    required this.nombres,
    required this.apellidos,
    required this.rol,
    required this.email,
    required this.uid,
  });

  factory Usuario.fromMap(DocumentSnapshot doc, Map<String, dynamic> json) {
    return Usuario(
        nombres: json["nombres"],
        apellidos: json["apellidos"],
        rol: json["rol"],
        email: json["email"],
        uid: doc.id);
  }
}

class UsuariosServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<Usuario?> iniciarAppUsuario() async {
    final User? usuarioAuth = AuthServices().currentUser;

    try {
      if (usuarioAuth != null) {
        final DocumentSnapshot doc =
            await db.collection("usuarios").doc(usuarioAuth.uid).get();
        final data = doc.data() as Map<String, dynamic>;
        return Usuario.fromMap(doc, data);
      } else {
        await AuthServices().signOut();
        return null;
      }
    } catch (e) {
      await AuthServices().signOut();
      return null;
    }
  }

  Future crearUsuario({
    required String nombres,
    required String apellidos,
    required String rol,
    required String email,
    required String uid,
  }) async {
    try {
      await db.collection("usuarios").doc(uid).set({
        "nombres": nombres,
        "apellidos": apellidos,
        "rol": rol,
        "email": email
      });
      return {
        "success": true,
        "msg": "El usuario ha sido creado correctamente"
      };
    } catch (e) {
      return {"success": false, "msg": e};
    }
  }

  Future<Map<String, dynamic>> actualizarUsuario({
    required String nombres,
    required String apellidos,
    required String rol,
    required String uid,
  }) async {
    try {
      DocumentReference usuarioRef = db.collection("usuarios").doc(uid);

      await db.runTransaction((transaction) async {
        transaction.update(usuarioRef, {
          "nombres": nombres,
          "apellidos": apellidos,
          "rol": rol,
        });
      });

      return {
        "success": true,
        "msg": "El usuario ha sido actualizado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Stream<List<Usuario>> listarUsuarios() {
    return db.collection("usuarios").snapshots().map((snap) =>
        snap.docs.map((doc) => Usuario.fromMap(doc, doc.data())).toList());
  }
}
