import 'package:flutter/material.dart';
import 'package:note_app/services/firestore_service.dart';
import '../../models/note_model.dart';
import '../../screens/note_form_screen.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  const NoteTile({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    final previewText = note.content.length > 100
        ? '${note.content.substring(0, 50)}...'
        : note.content;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text(
            note.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            previewText,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteFormScreen(note: note)),
              ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Konfirmasi'),
                    content: Text('Yakin pengen hapus catatan mu?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await firestore.deleteNote(note.id);
                        },
                        child: Text('Yakin'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
