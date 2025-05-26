import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- MODEL DATA ---
class Note {
  String title;
  String content;
  DateTime createdAt;

  Note({
    required this.title,
    required this.content,
    required this.createdAt,
  });
}

class Folder {
  String name;
  List<Note> notes;

  Folder({required this.name, List<Note>? initialNotes})
      : notes = initialNotes ?? [];
}

// --- PROVIDER (STATE MANAGEMENT) ---
class NotesProvider extends ChangeNotifier {
  final List<Folder> _folders = [
    // Contoh folder dan catatan awal
    Folder(name: 'Pekerjaan', initialNotes: [
      Note(title: 'Rapat Proyek X', content: 'Pembahasan fitur baru', createdAt: DateTime.now().subtract(const Duration(days: 2))),
      Note(title: 'Revisi Dokumen A', content: 'Perbaiki bagian pendahuluan', createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    ]),
    Folder(name: 'Pribadi', initialNotes: [
      Note(title: 'Ide Liburan Bali', content: 'Cari penginapan dan destinasi wisata', createdAt: DateTime.now().subtract(const Duration(days: 7))),
    ]),
  ];

  List<Folder> get folders => _folders;

  // Menambah folder baru
  void addFolder(String name) {
    if (name.trim().isNotEmpty) {
      _folders.add(Folder(name: name));
      notifyListeners(); // Memberi tahu UI bahwa data telah berubah
    }
  }

  // Menghapus folder
  void deleteFolder(Folder folder) {
    _folders.remove(folder);
    notifyListeners();
  }

  // Menambah catatan ke dalam folder tertentu
  void addNoteToFolder(Folder folder, String title, String content) {
    if (title.trim().isNotEmpty && content.trim().isNotEmpty) {
      folder.notes.add(Note(title: title, content: content, createdAt: DateTime.now()));
      notifyListeners();
    }
  }

  // Menghapus catatan dari folder
  void deleteNoteFromFolder(Folder folder, Note note) {
    folder.notes.remove(note);
    notifyListeners();
  }

  // Mengedit catatan
  void editNote(Folder folder, Note oldNote, String newTitle, String newContent) {
    final index = folder.notes.indexOf(oldNote);
    if (index != -1) {
      folder.notes[index].title = newTitle;
      folder.notes[index].content = newContent;
      notifyListeners();
    }
  }
}

// --- APLIKASI UTAMA ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Catatan',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const WelcomeScreen(), // Mengatur WelcomeScreen sebagai halaman awal
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- HALAMAN SELAMAT DATANG (SPLASH SCREEN) ---
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.book,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Catatanku',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Organisir Ide-idemu',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// --- BERANDA (HOME SCREEN) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _addFolder() {
    TextEditingController folderNameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buat Folder Catatan Baru'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(hintText: 'Nama Folder'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<NotesProvider>(context, listen: false)
                    .addFolder(folderNameController.text);
                Navigator.pop(context);
              },
              child: const Text('Buat'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda Catatan'),
        centerTitle: true,
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (notesProvider.folders.isEmpty) {
            return const Center(
                child: Text('Belum ada folder. Buat folder baru!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: notesProvider.folders.length,
            itemBuilder: (context, index) {
              final folder = notesProvider.folders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.folder_open, color: Colors.indigo),
                  title: Text(
                    folder.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      '${folder.notes.length} catatan'), // Menampilkan jumlah catatan
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => notesProvider.deleteFolder(folder),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FolderDetailScreen(folder: folder),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolder,
        tooltip: 'Tambah Folder Baru',
        child: const Icon(Icons.create_new_folder),
      ),
    );
  }
}

// --- HALAMAN DETAIL FOLDER ---
class FolderDetailScreen extends StatefulWidget {
  final Folder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Catatan di ${widget.folder.name}'),
      ),
      body: notesProvider.folders.firstWhere((f) => f == widget.folder).notes.isEmpty
          ? const Center(child: Text('Belum ada catatan di folder ini.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: notesProvider.folders.firstWhere((f) => f == widget.folder).notes.length,
              itemBuilder: (context, index) {
                final note = notesProvider.folders.firstWhere((f) => f == widget.folder).notes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(
                      note.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      note.content.length > 50
                          ? '${note.content.substring(0, 50)}...'
                          : note.content,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editNote(context, widget.folder, note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => notesProvider.deleteNoteFromFolder(widget.folder, note),
                        ),
                      ],
                    ),
                    onTap: () => _viewNoteDetail(context, note),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context, widget.folder),
        tooltip: 'Tambah Catatan Baru',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNote(BuildContext context, Folder folder) {
    TextEditingController titleController = TextEditingController();
    TextEditingController contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Catatan Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Catatan'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Isi Catatan'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<NotesProvider>(context, listen: false)
                    .addNoteToFolder(folder, titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _editNote(BuildContext context, Folder folder, Note noteToEdit) {
    TextEditingController titleController = TextEditingController(text: noteToEdit.title);
    TextEditingController contentController = TextEditingController(text: noteToEdit.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Judul Catatan'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Isi Catatan'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<NotesProvider>(context, listen: false)
                    .editNote(folder, noteToEdit, titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: const Text('Simpan Perubahan'),
            ),
          ],
        );
      },
    );
  }

  void _viewNoteDetail(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note.title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(note.content),
                const SizedBox(height: 10),
                Text(
                  'Dibuat pada: ${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year} ${note.createdAt.hour}:${note.createdAt.minute}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

// --- Main Function untuk Menjalankan Aplikasi ---
void main() {
  runApp(
    // Provider diletakkan di atas MyApp agar bisa diakses oleh semua widget di bawahnya
    ChangeNotifierProvider(
      create: (context) => NotesProvider(), // Inisialisasi NotesProvider
      child: const MyApp(),
    ),
  );
}
