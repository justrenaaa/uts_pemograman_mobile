import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- MODEL DATA ---
class Task {
  String title;
  bool isDone;
  DateTime createdAt;
  DateTime? reminderDate;

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

// --- PROVIDER ---
class TaskProvider extends ChangeNotifier {
  final List<TaskFolder> _folders = [];

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

// --- MAIN APP ---
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- WELCOME SCREEN ---
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.checklist_rtl,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'My Daily Tasks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Atur Hidupmu, Raih Tujuanmu',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text(
                  'Mulai Yuk!',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _addFolder() {
    TextEditingController folderNameController = TextEditingController();
    List<String> presetFolders = [
      'Sekolah',
      'Pekerjaan',
      'Umum',
      'Keluarga',
      'Kesehatan',
      'Belanja',
      'Hobi',
      'Proyek',
      'Acara',
      'Keuangan',
      'Liburan',
      'Lainnya',
    ];

    showDialog(
      context: context,
      builder: (context) {
        String? selectedPreset;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pilih atau Buat Folder Baru'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedPreset,
                      decoration: const InputDecoration(labelText: 'Pilih Folder Bawaan'),
                      items: presetFolders.map((folder) {
                        return DropdownMenuItem<String>(
                          value: folder,
                          child: Text(folder),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPreset = value;
                          folderNameController.text = value ?? '';
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: folderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Atau Tulis Nama Folder Sendiri',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final folderName = folderNameController.text.trim();
                    if (folderName.isNotEmpty) {
                      Provider.of<TaskProvider>(context, listen: false)
                          .addFolder(folderName);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Buat'),
                ),
              ],
            );
          },
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
              child: Text('Belum ada folder tugas. Buat folder baru!'),
            );
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

// --- DETAIL FOLDER SCREEN ---
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
                decoration: const InputDecoration(labelText: 'Judul Tugas'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedReminderDate == null
                        ? 'Tidak ada pengingat'
                        : 'Ingatkan pada: ${_selectedReminderDate.toString().substring(0, 16)}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.alarm),
                    onPressed: _pickReminderDate,
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
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.folder.tasks;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.name),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final createdAt = task.createdAt;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: IconButton(
                icon: Icon(
                  task.isDone
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: task.isDone ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false)
                      .toggleTaskStatus(widget.folder, task);
                },
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dibuat: ${createdAt.toLocal().toString().substring(0, 16)}'),
                  if (task.reminderDate != null)
                    Text('Pengingat: ${task.reminderDate!.toLocal().toString().substring(0, 16)}'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false)
                      .deleteTaskFromFolder(widget.folder, task);
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
