import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Evento {
  final String nombre;
  final String descripcion;
  final String imagen;
  final String uid;

  const Evento({
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.uid,
  });

  factory Evento.fromMap(DocumentSnapshot doc, Map<String, dynamic> json) {
    return Evento(
      nombre: json["nombre"],
      descripcion: json["descripcion"],
      imagen: json["imagen"],
      uid: doc.id,
    );
  }
}

class EventosServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>> eliminarEvento({required String uid}) async {
    try {
      await db.runTransaction((transaction) async {
        DocumentReference eventoRef = db.collection("eventos").doc(uid);
        transaction.delete(eventoRef);

        final Reference ref = storage.ref();
        final imagenEventoAntiguoRef = ref.child("eventos/$uid");

        var files = await imagenEventoAntiguoRef.listAll();

        for (var item in files.items) {
          await item.delete();
        }
      });

      return {
        "success": true,
        "msg": "El evento ha sido eliminado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Future<Map<String, dynamic>> crearEvento({
    required String nombre,
    required String descripcion,
    required File? imagen,
  }) async {
    try {
      DocumentReference eventoRef = db.collection("eventos").doc();
      await db.runTransaction((transaction) async {
        transaction.set(eventoRef, {
          "nombre": nombre,
          "descripcion": descripcion,
        });
      });

      if (imagen != null) {
        final Reference ref = storage.ref();
        final imagenEventoRef = ref.child("eventos/${eventoRef.id}");
        await imagenEventoRef.putFile(imagen);

        var fullPath = await imagenEventoRef.getDownloadURL();

        await db.runTransaction((transaction) async {
          transaction.update(eventoRef, {"imagen": fullPath});
        });
      }

      return {
        "success": true,
        "msg": "El evento ha sido creado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Future<Map<String, dynamic>> actualizarEvento({
    required String nombre,
    required String descripcion,
    required File? imagen,
    required String uid,
  }) async {
    try {
      DocumentReference eventoRef = db.collection("eventos").doc(uid);

      await db.runTransaction((transaction) async {
        transaction.update(eventoRef, {
          "nombre": nombre,
          "descripcion": descripcion,
        });
      });

      if (imagen != null) {
        final Reference ref = storage.ref();
        final imagenEventoAntiguoRef = ref.child("eventos/$uid");

        var files = await imagenEventoAntiguoRef.listAll();
        for (var item in files.items) {
          await item.delete();
        }

        final imagenEventoRef = ref.child("eventos/$uid");
        await imagenEventoRef.putFile(imagen);

        var fullPath = await imagenEventoRef.getDownloadURL();

        await db.runTransaction((transaction) async {
          transaction.update(eventoRef, {"imagen": fullPath});
        });
      }

      return {
        "success": true,
        "msg": "El evento ha sido actualizado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Stream<List<Evento>> listarEventos() {
    return db.collection("eventos").snapshots().map((snap) => snap.docs
        .map((doc) => Evento.fromMap(doc, doc.data()))
        .toList());
  }
}
