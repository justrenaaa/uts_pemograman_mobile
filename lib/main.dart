import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- MODEL DATA ---
// Menggunakan nama Task agar lebih sesuai dengan aplikasi To-Do List
class Task {
  String title;
  bool isDone;
  DateTime createdAt; // Menambahkan waktu pembuatan untuk informasi

  Task({
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });
}

// Menggunakan nama TaskFolder agar lebih spesifik
class TaskFolder {
  String name;
  List<Task> tasks;

  TaskFolder({required this.name, List<Task>? initialTasks})
      : tasks = initialTasks ?? [];
}

// --- PROVIDER (STATE MANAGEMENT) ---
// Menggunakan nama TaskProvider
class TaskProvider extends ChangeNotifier {
  final List<TaskFolder> _folders = [
    // Contoh folder dan tugas awal
    TaskFolder(name: 'Pekerjaan', initialTasks: [
      Task(title: 'Rapat dengan Klien', isDone: false, createdAt: DateTime.now().subtract(const Duration(days: 2))),
      Task(title: 'Kirim Laporan Bulanan', isDone: true, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    ]),
    TaskFolder(name: 'Pribadi', initialTasks: [
      Task(title: 'Belanja Kebutuhan Dapur', isDone: false, createdAt: DateTime.now().subtract(const Duration(days: 1))),
      Task(title: 'Olahraga Pagi', isDone: false, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
    ]),
  ];

  List<TaskFolder> get folders => _folders;

  // Menambah folder baru
  void addFolder(String name) {
    if (name.trim().isNotEmpty) {
      _folders.add(TaskFolder(name: name));
      notifyListeners(); // Memberi tahu UI bahwa data telah berubah
    }
  }

  // Menghapus folder
  void deleteFolder(TaskFolder folder) {
    _folders.remove(folder);
    notifyListeners();
  }

  // Menambah tugas ke dalam folder tertentu
  void addTaskToFolder(TaskFolder folder, String taskTitle) {
    if (taskTitle.trim().isNotEmpty) {
      folder.tasks.add(Task(title: taskTitle, createdAt: DateTime.now()));
      notifyListeners();
    }
  }

  // Mengubah status selesai/belum selesai tugas
  void toggleTaskStatus(TaskFolder folder, Task task) {
    final folderIndex = _folders.indexOf(folder);
    if (folderIndex != -1) {
      final taskIndex = _folders[folderIndex].tasks.indexOf(task);
      if (taskIndex != -1) {
        _folders[folderIndex].tasks[taskIndex].isDone =
            !_folders[folderIndex].tasks[taskIndex].isDone;
        notifyListeners();
      }
    }
  }

  // Menghapus tugas dari folder
  void deleteTaskFromFolder(TaskFolder folder, Task task) {
    folder.tasks.remove(task);
    notifyListeners();
  }
}

// --- APLIKASI UTAMA ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Menggunakan warna biru seperti aplikasi awal
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const WelcomeScreen(), // Mengatur WelcomeScreen sebagai halaman awal
      debugShowCheckedModeBanner: false, // Menyembunyikan banner "DEBUG"
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
    // Setelah beberapa detik, navigasi ke halaman utama aplikasi (HomeScreen)
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
      backgroundColor: Colors.blueAccent, // Warna latar belakang halaman awal
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon atau Logo Aplikasi
            const Icon(
              Icons.checklist_rtl, // Icon to-do list
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // Judul Aplikasi
            const Text(
              'My Daily Tasks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Slogan atau Deskripsi Singkat
            const Text(
              'Atur Hidupmu, Raih Tujuanmu',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 50),
            // Indikator Loading (opsional)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// --- BERANDA (HOME SCREEN) - MENAMPILKAN FOLDER TUGAS ---
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
          title: const Text('Buat Folder Tugas Baru'),
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
                // Tambahkan folder menggunakan TaskProvider
                Provider.of<TaskProvider>(context, listen: false)
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
        title: const Text('Folder Tugas Anda'),
        centerTitle: true,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.folders.isEmpty) {
            return const Center(
                child: Text('Belum ada folder tugas. Buat folder baru!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: taskProvider.folders.length,
            itemBuilder: (context, index) {
              final folder = taskProvider.folders[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: const Icon(Icons.folder, color: Colors.blue), // Icon folder
                  title: Text(
                    folder.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      '${folder.tasks.where((t) => !t.isDone).length} tugas belum selesai dari ${folder.tasks.length}'), // Menampilkan status tugas
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => taskProvider.deleteFolder(folder),
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
        onPressed: _addFolder, // FAB sekarang untuk menambah folder
        tooltip: 'Tambah Folder Tugas Baru',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- HALAMAN DETAIL FOLDER (MENAMPILKAN DAFTAR TUGAS) ---
class FolderDetailScreen extends StatefulWidget {
  final TaskFolder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final TextEditingController _taskTitleController = TextEditingController();

  void _addTask() {
    final taskTitle = _taskTitleController.text.trim();
    if (taskTitle.isNotEmpty) {
      // Tambahkan tugas ke folder menggunakan TaskProvider
      Provider.of<TaskProvider>(context, listen: false)
          .addTaskToFolder(widget.folder, taskTitle);
      _taskTitleController.clear();
      Navigator.pop(context); // Kembali ke halaman folder setelah menambah tugas
    }
  }

  // Dialog untuk menambah tugas
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Tugas Baru'),
          content: TextField(
            controller: _taskTitleController,
            decoration: const InputDecoration(hintText: 'Nama Tugas'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _addTask,
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer di sini agar daftar tugas otomatis diperbarui
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        // Temukan kembali folder dari provider untuk memastikan data terbaru
        final currentFolder = taskProvider.folders.firstWhere(
            (f) => f.name == widget.folder.name,
            orElse: () => TaskFolder(name: 'Folder Tidak Ditemukan'));

        return Scaffold(
          appBar: AppBar(
            title: Text('Tugas di ${currentFolder.name}'),
          ),
          body: currentFolder.tasks.isEmpty
              ? const Center(child: Text('Belum ada tugas di folder ini.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: currentFolder.tasks.length,
                  itemBuilder: (context, index) {
                    final task = currentFolder.tasks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) => taskProvider.toggleTaskStatus(currentFolder, task),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Text(
                          'Dibuat: ${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year} ${task.createdAt.hour}:${task.createdAt.minute}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => taskProvider.deleteTaskFromFolder(currentFolder, task),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddTaskDialog, // FAB untuk menambah tugas ke folder
            tooltip: 'Tambah Tugas Baru',
            child: const Icon(Icons.add),
          ),
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
      create: (context) => TaskProvider(), // Inisialisasi TaskProvider
      child: const MyApp(),
    ),
  );
}
