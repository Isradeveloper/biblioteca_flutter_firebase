import 'package:biblioteca_flutter_firebase/services/libros.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Prestamo {
  final String libroUid;
  final String usuarioUid;
  final String uid;
  final bool completado;

  const Prestamo({
    required this.libroUid,
    required this.usuarioUid,
    required this.completado,
    required this.uid,
  });

  factory Prestamo.fromMap(DocumentSnapshot doc, Map<String, dynamic> json) {
    return Prestamo(
      libroUid: json["libroUid"],
      usuarioUid: json["usuarioUid"],
      completado: json["completado"],
      uid: doc.id,
    );
  }
}

class LibroPrestamo {
  final String prestamoUid;
  final Libro libro;

  const LibroPrestamo({
    required this.prestamoUid,
    required this.libro,
  });
}

class PrestamosServices {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>> crearPrestamo(
      {required String libroUid,
      required String usuarioUid,
      required bool completado,
      Libro? libro}) async {
    try {
      DocumentReference prestamoRef = db.collection("prestamos").doc();
      DocumentReference librosRef = db.collection("libros").doc(libroUid);

      QuerySnapshot prestamoQuery = await db
          .collection("prestamos")
          .where("libroUid", isEqualTo: libroUid)
          .where("usuarioUid", isEqualTo: usuarioUid)
          .where("completado", isEqualTo: false)
          .get();

      DocumentSnapshot libroSnapshot = await librosRef.get();

      if (prestamoQuery.docs.isNotEmpty) {
        return {
          "success": false,
          "msg": "Ya tienes un prestamo activo de este libro"
        };
      }

      if (libroSnapshot.exists &&
          (libroSnapshot.data() as Map<String, dynamic>)["stock"] <= 0) {
        return {
          "success": false,
          "msg": "No hay disponibilidad para este libro"
        };
      }

      await db.runTransaction((transaction) async {
        transaction.set(prestamoRef, {
          "libroUid": libroUid,
          "usuarioUid": usuarioUid,
          "completado": completado,
        });
      });

      await db.runTransaction((transaction) async {
        transaction.update(librosRef, {
          "stock": libro!.stock - 1,
        });
      });

      return {
        "success": true,
        "msg": "El préstamo ha sido creado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Future<Map<String, dynamic>> completarPrestamo(
      {required String uid, required Libro libro}) async {
    try {
      DocumentReference prestamoRef = db.collection("prestamos").doc(uid);
      DocumentReference libroRef = db.collection("libros").doc(libro.uid);

      await db.runTransaction((transaction) async {
        transaction.update(prestamoRef, {"completado": true});
      });

      await db.runTransaction((transaction) async {
        transaction.update(libroRef, {"stock": libro.stock + 1});
      });

      return {
        "success": true,
        "msg": "El préstamo ha sido completado correctamente",
      };
    } catch (e) {
      return {"success": false, "msg": e.toString()};
    }
  }

  Stream<List<LibroPrestamo>> obtenerLibrosPrestamosUsuario({
    required String usuarioUid,
    required String rol,
  }) {
    Stream<List<Prestamo>> prestamoDocSnapshot;
    if (rol != "administrador") {
      prestamoDocSnapshot = db
          .collection("prestamos")
          .where("usuarioUid", isEqualTo: usuarioUid)
          .where("completado", isEqualTo: false)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => Prestamo.fromMap(doc, doc.data()))
              .toList());
    } else {
      prestamoDocSnapshot = db
          .collection("prestamos")
          .where("completado", isEqualTo: false)
          .snapshots()
          .map((snap) => snap.docs
              .map((doc) => Prestamo.fromMap(doc, doc.data()))
              .toList());
    }

    final Stream<List<LibroPrestamo>> librosPrestamosSnapshot =
        prestamoDocSnapshot.asyncMap((prestamos) async {
      final List<String> librosPrestadosIds =
          prestamos.map((prestamo) => prestamo.libroUid).toList();

      final librosSnapshot = await db
          .collection("libros")
          .where(FieldPath.documentId, whereIn: librosPrestadosIds)
          .get();

      final Map<String, dynamic> librosMap = Map.fromEntries(librosSnapshot.docs
          .map((doc) => MapEntry(doc.id, Libro.fromMap(doc, doc.data()))));

      final List<LibroPrestamo> librosPrestamos = prestamos
          .map((prestamo) => LibroPrestamo(
                prestamoUid: prestamo.uid,
                libro: librosMap[prestamo.libroUid],
              ))
          .toList();

      return librosPrestamos;
    });

    return librosPrestamosSnapshot;
  }
}
