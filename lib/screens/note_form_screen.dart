import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;
  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirestoreService();

  bool _isPinned = false;
  late DateTime _timestamp;

  @override
  void initState() {
    super.initState();
    _timestamp = DateTime.now();

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _isPinned = widget.note!.isPinned ?? false;
      _timestamp = widget.note!.timestamp ?? DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Catatan' : 'Tambah Catatan'),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? Colors.amber : null,
            ),
            onPressed: () => setState(() => _isPinned = !_isPinned),
            tooltip: _isPinned ? 'Unpin' : 'Pin',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: Text(
                  'Create at: ${DateFormat('dd MMM yyyy, HH:mm').format(_timestamp)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator:
                  (value) => value!.trim().isEmpty ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Isi Catatan',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              validator:
                  (value) => value!.trim().isEmpty ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            Divider(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text('Tambah Lampiran (Coming Soon)'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                backgroundColor: Colors.grey.shade200,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur lampiran belum tersedia.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                label: Text(
                  isEditing ? 'Simpan Perubahan' : 'Simpan Catatan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Color(0xFF1D3557),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final note = Note(
                      id: widget.note?.id ?? '',
                      title: _titleController.text.trim(),
                      content: _contentController.text.trim(),
                      isPinned: _isPinned,
                      timestamp: DateTime.now(),
                      userId: null,
                    );
                    if (isEditing) {
                      await _firestore.saveNote(
                        noteId: note.id,
                        title: note.title,
                        content: note.content,
                        isPinned: note.isPinned,
                        timestamp: note.timestamp!,
                      );
                    } else {
                      await _firestore.saveNote(
                        title: note.title,
                        content: note.content,
                        isPinned: note.isPinned,
                        timestamp: note.timestamp!,
                      );
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
