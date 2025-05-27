import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- MODEL DATA ---
class Task {
  String title;
  bool isDone;
  DateTime createdAt;
  DateTime? reminderDate; // Reminder nullable

  Task({
    required this.title,
    this.isDone = false,
    required this.createdAt,
    this.reminderDate,
  });
}

class TaskFolder {
  String name;
  List<Task> tasks;

  TaskFolder({required this.name, List<Task>? initialTasks})
      : tasks = initialTasks ?? [];
}

// --- PROVIDER (STATE MANAGEMENT) ---
class TaskProvider extends ChangeNotifier {
  final List<TaskFolder> _folders = [
    TaskFolder(name: 'Pekerjaan', initialTasks: [
      Task(
          title: 'Rapat dengan Klien',
          isDone: false,
          createdAt: DateTime.now().subtract(const Duration(days: 2))),
      Task(
          title: 'Kirim Laporan Bulanan',
          isDone: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    ]),
    TaskFolder(name: 'Pribadi', initialTasks: [
      Task(
          title: 'Belanja Kebutuhan Dapur',
          isDone: false,
          createdAt: DateTime.now().subtract(const Duration(days: 1))),
      Task(
          title: 'Olahraga Pagi',
          isDone: false,
          createdAt: DateTime.now().subtract(const Duration(hours: 3))),
    ]),
  ];

  List<TaskFolder> get folders => _folders;

  void addFolder(String name) {
    if (name.trim().isNotEmpty) {
      _folders.add(TaskFolder(name: name));
      notifyListeners();
    }
  }

  void deleteFolder(TaskFolder folder) {
    _folders.remove(folder);
    notifyListeners();
  }

  void addTaskToFolder(TaskFolder folder, String taskTitle, [DateTime? reminderDate]) {
    if (taskTitle.trim().isNotEmpty) {
      folder.tasks.add(Task(
        title: taskTitle,
        createdAt: DateTime.now(),
        reminderDate: reminderDate,
      ));
      notifyListeners();
    }
  }

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
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- HALAMAN SELAMAT DATANG ---
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
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.checklist_rtl,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'My Daily Tasks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Atur Hidupmu, Raih Tujuanmu',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 50),
            CircularProgressIndicator(
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
                  leading: const Icon(Icons.folder, color: Colors.blue),
                  title: Text(
                    folder.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                      '${folder.tasks.where((t) => !t.isDone).length} tugas belum selesai dari ${folder.tasks.length}'),
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
        onPressed: _addFolder,
        tooltip: 'Tambah Folder Tugas Baru',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- HALAMAN DETAIL FOLDER ---
class FolderDetailScreen extends StatefulWidget {
  final TaskFolder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final TextEditingController _taskTitleController = TextEditingController();
  DateTime? _selectedReminderDate;

  void _pickReminderDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final reminderDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      _selectedReminderDate = reminderDate;
    });
  }

  void _addTask() {
    final taskTitle = _taskTitleController.text.trim();
    if (taskTitle.isNotEmpty) {
      Provider.of<TaskProvider>(context, listen: false)
          .addTaskToFolder(widget.folder, taskTitle, _selectedReminderDate);
      _taskTitleController.clear();
      _selectedReminderDate = null;
      Navigator.pop(context);
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Tugas Baru'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskTitleController,
                decoration: const InputDecoration(hintText: 'Nama Tugas'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedReminderDate == null
                          ? 'Belum ada reminder'
                          : 'Reminder: ${_selectedReminderDate!.day}/${_selectedReminderDate!.month}/${_selectedReminderDate!.year} ${_selectedReminderDate!.hour}:${_selectedReminderDate!.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickReminderDate,
                    child: const Text('Pilih Reminder'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _taskTitleController.clear();
                _selectedReminderDate = null;
                Navigator.pop(context);
              },
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
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
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
                          onChanged: (_) =>
                              taskProvider.toggleTaskStatus(currentFolder, task),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dibuat: ${task.createdAt.day}/${task.createdAt.month}/${task.createdAt.year} ${task.createdAt.hour}:${task.createdAt.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            if (task.reminderDate != null)
                              Text(
                                'Reminder: ${task.reminderDate!.day}/${task.reminderDate!.month}/${task.reminderDate!.year} ${task.reminderDate!.hour}:${task.reminderDate!.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.red),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              taskProvider.deleteTaskFromFolder(currentFolder, task),
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddTaskDialog,
            tooltip: 'Tambah Tugas Baru',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// --- MAIN ---
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}
