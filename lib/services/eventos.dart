import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Evento {
  final String nombre;
  final String descripcion;
  final String imagen;
  final String uid;

  const Evento(
      {required this.nombre,
      required this.descripcion,
      required this.imagen,
      required this.uid});

  factory Evento.fromMap(DocumentSnapshot doc, Map<String, dynamic> json) {
    return Evento(
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        imagen: json["imagen"],
        uid: doc.id);
  }
}

class EventosServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future crearEvento({
    required String nombre,
    required String descripcion,
    required File? imagen,
  }) async {
    try {
      var respuesta_db = await db.collection("eventos").add({
        "nombre": nombre,
        "descripcion": descripcion,
        // "imagen": imagen,
      });

      String nombreFile = imagen!.path.split(Platform.pathSeparator).last;

      final Reference ref = storage.ref();
      final imagenEventoRef = ref.child("eventos/${respuesta_db.id}/$nombreFile");
      await imagenEventoRef.putFile(imagen);

      var fullPath = await imagenEventoRef.getDownloadURL();

      await db
          .collection("eventos")
          .doc(respuesta_db.id)
          .update({"imagen": fullPath});

      return {"success": true, "msg": "El evento ha sido creado correctamente"};
    } catch (e) {
      return {"success": false, "msg": e};
    }
  }

  Stream<List<Evento>> listarEventos() {
    return db.collection("eventos").snapshots().map((snap) => snap.docs.map((doc) => Evento.fromMap(doc, doc.data())).toList());
  }
}
