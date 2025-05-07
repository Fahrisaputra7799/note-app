import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan daftar catatan untuk pengguna yang sedang login
  Stream<QuerySnapshot> getNotes() {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .snapshots();
  }

  // Menambah atau memperbarui catatan
  Future<void> saveNote({String? noteId, required String title, required String content}) async {
    if (noteId != null) {
      await _firestore.collection('notes').doc(noteId).update({
        'title': title,
        'content': content,
      });
    } else {
      await _firestore.collection('notes').add({
        'title': title,
        'content': content,
        'userId': _auth.currentUser?.uid,
      });
    }
  }

  // Menghapus catatan
  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }
}
