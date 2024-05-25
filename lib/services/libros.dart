import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Libro {
  final String titulo;
  final String autor;
  final String portada;
  final int stock;
  final bool aplicaPrestamo;
  final String uid;

  const Libro(
      {required this.titulo,
      required this.autor,
      required this.portada,
      required this.uid,
      required this.stock,
      required this.aplicaPrestamo});

  factory Libro.fromMap(DocumentSnapshot doc, Map<String, dynamic> json) {
    return Libro(
      titulo: json["titulo"],
      autor: json["autor"],
      portada: json["portada"],
      stock: json["stock"],
      aplicaPrestamo: json["aplicaPrestamo"],
      uid: doc.id,
    );
  }
}

class LibrosServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>> eliminarLibro({required String uid}) async {
    try {
      await db.runTransaction((transaction) async {
        DocumentReference eventoRef = db.collection("libros").doc(uid);
        transaction.delete(eventoRef);

        final Reference ref = storage.ref();
        final portadaEventoAntiguoRef = ref.child("libros/$uid");

        var files = await portadaEventoAntiguoRef.listAll();

        for (var item in files.items) {
          await item.delete();
        }
      });

      return {
        "success": true,
        "msg": "El libro ha sido eliminado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Future<Map<String, dynamic>> crearLibro(
      {required String titulo,
      required String autor,
      required File? portada,
      required int stock,
      required bool aplicaPrestamo}) async {
    try {
      DocumentReference eventoRef = db.collection("libros").doc();
      await db.runTransaction((transaction) async {
        transaction.set(eventoRef, {
          "titulo": titulo,
          "autor": autor,
          "stock": stock,
          "aplicaPrestamo": aplicaPrestamo
        });
      });

      if (portada != null) {
        final Reference ref = storage.ref();
        final portadaEventoRef = ref.child("libros/${eventoRef.id}");
        await portadaEventoRef.putFile(portada);

        var fullPath = await portadaEventoRef.getDownloadURL();

        await db.runTransaction((transaction) async {
          transaction.update(eventoRef, {"portada": fullPath});
        });
      }

      return {
        "success": true,
        "msg": "El libro ha sido creado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Future<Map<String, dynamic>> actualizarLibro({
    required String titulo,
    required String autor,
    required File? portada,
    required int stock,
    required bool aplicaPrestamo,
    required String uid,
  }) async {
    try {
      DocumentReference eventoRef = db.collection("libros").doc(uid);

      await db.runTransaction((transaction) async {
        transaction.update(eventoRef, {
          "titulo": titulo,
          "autor": autor,
          "stock": stock,
          "aplicaPrestamo": aplicaPrestamo
        });
      });

      if (portada != null) {
        final Reference ref = storage.ref();
        final portadaEventoAntiguoRef = ref.child("libros/$uid");

        var files = await portadaEventoAntiguoRef.listAll();
        for (var item in files.items) {
          await item.delete();
        }

        final portadaEventoRef = ref.child("libros/$uid");
        await portadaEventoRef.putFile(portada);

        var fullPath = await portadaEventoRef.getDownloadURL();

        await db.runTransaction((transaction) async {
          transaction.update(eventoRef, {"portada": fullPath});
        });
      }

      return {
        "success": true,
        "msg": "El libro ha sido actualizado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Stream<List<Libro>> listarLibros() {
    return db.collection("libros").snapshots().map((snap) =>
        snap.docs.map((doc) => Libro.fromMap(doc, doc.data())).toList());
  }
}
