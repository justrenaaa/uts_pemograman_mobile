import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi To-Do List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WelcomeScreen(), // Mengatur WelcomeScreen sebagai halaman awal
      debugShowCheckedModeBanner: false, // Menyembunyikan banner "DEBUG"
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Setelah beberapa detik, navigasi ke halaman utama aplikasi (simulasi)
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
      backgroundColor: Colors.blueAccent, // Warna latar belakang halaman awal
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon atau Logo Aplikasi
            Icon(Icons.checklist_rtl, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            // Judul Aplikasi
            Text(
              'My Daily Tasks',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Slogan atau Deskripsi Singkat
            Text(
              'Atur Hidupmu, Raih Tujuanmu',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 50),
            // Indikator Loading (opsional)
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ---
// Simulasi Halaman Utama To-Do List
class MainTodoListScreen extends StatelessWidget {
  const MainTodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang di To-Do !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            const Text(
              'Kelola Daftar Tugasmu dengan Mudah dan Cepat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ToDoHomePage()),
                );
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

class Task {
  String title;
  bool isDone;

  Task(this.title, {this.isDone = false});
}

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

// ==========================
// Halaman Pertama (Home)
// ==========================
class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  void _onSearchPressed() {
    print('Search button pressed');
    // Tambahkan logika pencarian jika diperlukan
  }

  void _onAddPressed() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => TodoApp()));
  }

  Future<bool> _onWillPop() async {
    // Menampilkan dialog konfirmasi keluar aplikasi
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Keluar Aplikasi'),
            content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // batal keluar
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true), // setuju keluar
                child: Text('Keluar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Daftar Tugas Anda', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38),
                ),
              ),
              onPressed: _onSearchPressed,
              child: Text(
                'Search',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _onAddPressed(); // navigasi ke halaman TodoApp
          },
          tooltip: 'Tambah To-Do',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

// ==========================
// Halaman Kedua (Tambah Tugas)
// ==========================
class TodoApp extends StatefulWidget {
  @override
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  final List<Task> tasks = [];
  final TextEditingController controller = TextEditingController();

  void addTask() {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      tasks.add(Task(text));
      controller.clear();
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('🟣 Tambah Tugas Hehehhehehehe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Label "Nama Tugas"
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama Tugas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 6),
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
                    SizedBox(width: 8),
                    ElevatedButton(onPressed: addTask, child: Text('Tambah')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // List tugas
            Expanded(
              child: tasks.isEmpty
                  ? Center(child: Text('Belum ada tugas.'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Card(
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
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
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
