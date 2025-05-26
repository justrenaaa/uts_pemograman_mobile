import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Task {
  String title;
  bool isDone;

  Task(this.title, {this.isDone = false});
}

class MyApp extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        actions: [
          TextButton(
            onPressed: _onSearchPressed,
            child: Text(
              'Search',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Selamat datang di To-Do App!',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        child: Icon(Icons.add),
        tooltip: 'Tambah To-Do',
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
      appBar: AppBar(title: Text('🟣 Tambah Tugas')),
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
