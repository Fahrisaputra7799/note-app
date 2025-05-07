import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:note_app/models/note_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

    // Mendapatkan daftar catatan untuk pengguna yang sedang login
  Stream<List<Note>> getNotes() {
    return _firestore
        .collection('notes')
        .where('userId', isEqualTo: _auth.currentUser?.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Note(
                  id: doc.id,
                  title: doc['title'],
                  content: doc['content'],
                  userId: doc['userId'],
                ))
            .toList());
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

  Future<void> updateNote(Note note) async {
     await _firestore.collection('notes').doc(note.id).update({
      'title': note.title,
      'content': note.content,
      'userId': note.userId,
    });
  }
}
