// ignore: unused_import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../providers/search_query_provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/note_tile.dart';
import 'login_screen.dart';
import 'note_form_screen.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final query = ref.read(searchQueryProvider);
    _searchController = TextEditingController(text: query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesStream = ref.watch(firestoreServiceProvider).getNotes();
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchField(),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: notesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notes = snapshot.data ?? [];


                final filteredNotes =
                    notes.where((note) {
                      final title = note.title.toLowerCase();
                      final content = note.content.toLowerCase();
                      return title.contains(searchQuery) ||
                          content.contains(searchQuery);
                    }).toList();

                if (filteredNotes.isEmpty) {
                  return const Center(child: Text('Tidak ada catatan.'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return Dismissible(
                      key: Key(note.id),
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Row(
                          children: [
                            Icon(Icons.push_pin, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Pin', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Hapus',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: const Text('Hapus Catatan'),
                                  content: const Text(
                                    'Yakin ingin menghapus catatan ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirm ?? false) {
                            await ref
                                .read(firestoreServiceProvider)
                                .deleteNote(note.id);
                          }
                          return confirm ?? false;
                        } else if (direction == DismissDirection.startToEnd) {
                          await ref
                              .read(firestoreServiceProvider)
                              .saveNote(
                                noteId: note.id,
                                title: note.title,
                                content: note.content,
                                isPinned: !(note.isPinned ?? false),
                                timestamp: DateTime.now(),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                note.isPinned == true
                                    ? 'Catatan tidak dipin'
                                    : 'Catatan dipin',
                              ),
                            ),
                          );
                          return false;
                        }
                        return false;
                      },
                      child: NoteTile(note: note),
                    );
                  },
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 8),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoteFormScreen()),
            ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari catatan...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          ref.read(searchQueryProvider.notifier).state = value.toLowerCase();
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text('Yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(authServiceProvider).signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginScreen()),
                  );
                },
                child: const Text('Ya, Keluar'),
              ),
            ],
          ),
    );
  }
}
