import 'package:biblioteca_flutter_firebase/services/usuarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Reserva {
  final DateTime fecha;
  final String motivo;
  final String usuarioUid;
  final String uid;
  final bool completado;

  const Reserva(
      {required this.fecha,
      required this.motivo,
      required this.uid,
      required this.usuarioUid,
      required this.completado});

  factory Reserva.fromMap(DocumentSnapshot doc, Map<String, dynamic> json) {
    return Reserva(
      fecha: DateTime.fromMicrosecondsSinceEpoch(
          json["fecha"].microsecondsSinceEpoch),
      motivo: json["motivo"],
      usuarioUid: json["usuarioUid"],
      completado: json["completado"],
      uid: doc.id,
    );
  }
}

class ReservasServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>> cancelarReserva({required String uid}) async {
    try {
      await db.runTransaction((transaction) async {
        DocumentReference reservaRef = db.collection("reservas").doc(uid);
        transaction.delete(reservaRef);
      });

      return {
        "success": true,
        "msg": "La reserva ha sido eliminada correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Future<Map<String, dynamic>> crearReserva({
    required DateTime? fecha,
    required String motivo,
    required String usuarioUid,
  }) async {
    try {
      DocumentReference reservaRef = db.collection("reservas").doc();
      await db.runTransaction((transaction) async {
        transaction.set(reservaRef, {
          "fecha": fecha,
          "motivo": motivo,
          "usuarioUid": usuarioUid,
          "completado": false
        });
      });

      return {
        "success": true,
        "msg": "La reserva ha sido creada correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Future<Map<String, dynamic>> completarReserva({
    required String uid,
  }) async {
    try {
      DocumentReference reservasRef = db.collection("reservas").doc(uid);

      await db.runTransaction((transaction) async {
        transaction.update(reservasRef, {
          "completado": true,
        });
      });

      return {
        "success": true,
        "msg": "La reserva se ha completado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Stream<List<Reserva>> listarReservas(Usuario usuario) {
    if (usuario.rol == "administrador") {
      return db.collection("reservas").snapshots().map((snap) =>
          snap.docs.map((doc) => Reserva.fromMap(doc, doc.data())).toList());
    } else {
      return db
          .collection("reservas")
          .where("usuarioUid", isEqualTo: usuario.uid)
          .where("completado", isEqualTo: false)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => Reserva.fromMap(doc, doc.data()))
              .toList());
    }
  }
}
