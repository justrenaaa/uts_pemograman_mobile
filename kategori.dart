import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// Widget utama aplikasi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(), // Halaman awal saat aplikasi dibuka
      debugShowCheckedModeBanner: false, // Hilangkan banner debug di pojok kanan atas
    );
  }
}

// Halaman splash screen / welcome screen
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Delay 3 detik lalu pindah ke halaman utama aplikasi (MainTodoListScreen)
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainTodoListScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Warna background halaman welcome
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon aplikasi
            Icon(
              Icons.checklist_rtl,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            // Judul aplikasi
            Text(
              'My Daily Tasks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Slogan aplikasi
            Text(
              'Atur Hidupmu, Raih Tujuanmu',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 50),
            // Loading indikator yang berputar
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Halaman utama aplikasi setelah welcome screen
class MainTodoListScreen extends StatelessWidget {
  const MainTodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // appBar tanpa title
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pesan sambutan
            const Text(
              'Selamat Datang di To-Do !',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Penjelasan singkat fungsi aplikasi
            const Text(
              'Kelola Daftar Tugasmu dengan Mudah dan Cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
              ),
              onPressed: () {
                // Navigasi ke halaman utama to-do list
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ToDoHomePage()),
                );
                // Tampilkan pesan snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anda siap menambahkan tugas!')),
                );
              },
              child: const Text(
                'Mulai',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model data tugas dengan kategori dan reminder
class Task {
  String title;       // Judul atau nama tugas
  bool isDone;        // Status selesai/tidak
  String category;    // Kategori tugas
  DateTime? reminder; // Waktu reminder opsional

  Task(this.title, {this.isDone = false, this.category = 'Umum', this.reminder});
}

// Widget dummy (tidak terpakai di aplikasi utama)
class ToDoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ToDoHomePage(),
    );
  }
}

// Halaman utama To-Do List (daftar tugas)
class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key});

  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  // Fungsi ketika tombol search ditekan
  void _onSearchPressed() {
    print('Search button pressed');
    // Bisa ditambahkan fitur pencarian disini
  }

  // Fungsi ketika tombol tambah ditekan
  void _onAddPressed() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TodoApp()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Tugas Anda', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          // Tombol search di app bar
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(38)),
            ),
            onPressed: _onSearchPressed,
            child: Text(
              'Search',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      // Tampilan ketika belum ada daftar tugas
      body: Center(
        child: Text(
          'Saat ini belum ada daftar tugas. '
          'Silakan menambahkan untuk memulai.',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
      // Tombol mengambang untuk tambah tugas baru
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onAddPressed(); // navigasi ke halaman tambah tugas (TodoApp)
        },
        tooltip: 'Tambah To-Do',
        child: Icon(Icons.add),
      ),
    );
  }
}

// Halaman untuk menambah dan melihat daftar tugas dengan kategori dan reminder
class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<Task> tasks = [];                 // List menyimpan tugas-tugas
  final TextEditingController controller = TextEditingController(); // Controller input teks tugas
  final List<String> categories = ['Umum', 'Sekolah', 'Belanja', 'Pekerjaan', 'Lainnya'];

  String selectedCategory = 'Umum';
  DateTime? selectedReminder;

  // Fungsi tambah tugas baru
  void addTask() {
    final text = controller.text.trim();       // Ambil dan bersihkan teks input
    if (text.isEmpty) return;                   // Jika kosong, tidak melakukan apa-apa
    setState(() {
      tasks.add(Task(text, category: selectedCategory, reminder: selectedReminder)); // Tambah tugas baru ke list dengan kategori & reminder
      controller.clear();                       // Kosongkan input teks
      selectedCategory = 'Umum';
      selectedReminder = null;
    });
  }

  // Fungsi toggle status selesai/tidak pada tugas
  void toggleTask(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
  }

  // Fungsi hapus tugas berdasarkan index
  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  Future<void> pickReminder() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedReminder ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedReminder = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🟣 Tambah Tugas Hehehhehehehe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input nama tugas dan tombol tambah
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Masukkan tugas anda',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addTask,
                  child: const Text('Tambah'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Dropdown kategori tugas
            Row(
              children: [
                const Text(
                  'Kategori: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedCategory,
                  items: categories
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tombol pilih reminder dan tampilkan tanggal jika sudah dipilih
            Row(
              children: [
                const Text(
                  'Reminder: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: pickReminder,
                  child: Text(selectedReminder == null
                      ? 'Atur Reminder (opsional)'
                      : '${selectedReminder.toString()}'),
                ),
                if (selectedReminder != null)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        selectedReminder = null;
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ListView menampilkan daftar tugas
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('Belum ada tugas.'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
                          elevation: 2,
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isDone,
                              onChanged: (_) => toggleTask(index),
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
                                Text('Kategori: ${task.category}'),
                                if (task.reminder != null)
                                  Text('Reminder: ${task.reminder.toString()}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteTask(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
