import 'package:flutter/material.dart';

void main() {
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => ToDoHomePage()));
          },
          child: Text('Selamat Datang di To-Do App\nMulai Yuk!', textAlign: TextAlign.center),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class ToDoItem {
  String title;
  String category;
  DateTime? reminder;
  bool isDone;

  ToDoItem({
    required this.title,
    required this.category,
    this.reminder,
    this.isDone = false,
  });
}

class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  List<ToDoItem> _toDoList = [];
  String _searchQuery = "";

  final _textController = TextEditingController();
  final _searchController = TextEditingController();
  String _selectedCategory = 'Umum';
  DateTime? _selectedReminder;

  final List<String> _categories = ['Umum', 'Sekolah', 'Belanja', 'Pekerjaan', 'Lainnya'];

  void _addToDo(String title, String category, DateTime? reminder) {
    if (title.trim().isEmpty) return;
    setState(() {
      _toDoList.add(ToDoItem(title: title, category: category, reminder: reminder));
    });
  }

  void _editToDo(int index, String newTitle, String newCategory, DateTime? reminder) {
    setState(() {
      _toDoList[index].title = newTitle;
      _toDoList[index].category = newCategory;
      _toDoList[index].reminder = reminder;
    });
  }

  void _deleteToDo(int index) {
    setState(() {
      _toDoList.removeAt(index);
    });
  }

  void _toggleDone(int index) {
    setState(() {
      _toDoList[index].isDone = !_toDoList[index].isDone;
    });
  }

  void _showAddDialog() {
    _textController.clear();
    _selectedCategory = 'Umum';
    _selectedReminder = null;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Tambah To-Do'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  autofocus: true,
                  decoration: InputDecoration(hintText: 'Tulis to-do di sini'),
                ),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((cat) => DropdownMenuItem(
                    child: Text(cat),
                    value: cat,
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedReminder = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Text(_selectedReminder == null
                      ? 'Atur Reminder (opsional)'
                      : 'Reminder: ${_selectedReminder.toString()}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
            ElevatedButton(
              onPressed: () {
                _addToDo(_textController.text, _selectedCategory, _selectedReminder);
                Navigator.pop(context);
              },
              child: Text('Tambah'),
            ),
          ],
        );
      }),
    );
  }

  void _showEditDialog(int index) {
    _textController.text = _toDoList[index].title;
    _selectedCategory = _toDoList[index].category;
    _selectedReminder = _toDoList[index].reminder;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Edit To-Do'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _textController),
                SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((cat) => DropdownMenuItem(
                    child: Text(cat),
                    value: cat,
                  )).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedReminder ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedReminder = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: Text(_selectedReminder == null
                      ? 'Atur Reminder'
                      : 'Reminder: ${_selectedReminder.toString()}'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
            ElevatedButton(
              onPressed: () {
                _editToDo(index, _textController.text, _selectedCategory, _selectedReminder);
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _toDoList.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Cari To-Do'),
                  content: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(hintText: 'Cari...'),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        Navigator.pop(context);
                      },
                      child: Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              'Search',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: filteredList.isEmpty
          ? Center(child: Text('Belum ada To-Do nih, yuk isi!'))
          : ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final actualIndex = _toDoList.indexOf(item);
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.isDone,
                      onChanged: (_) => _toggleDone(actualIndex),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${item.category}'),
                        if (item.reminder != null)
                          Text('Reminder: ${item.reminder.toString()}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditDialog(actualIndex),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteToDo(actualIndex),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        tooltip: 'Tambah To-Do',
      ),
    );
  }
}
