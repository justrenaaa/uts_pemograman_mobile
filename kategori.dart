import 'package:flutter/material.dart';

void main() {
  // Fungsi utama menjalankan aplikasi
  runApp(ToDoApp());
}

class ToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Judul aplikasi
      title: 'To-Do App',
      // Tema warna aplikasi
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      // Halaman awal yang ditampilkan saat aplikasi dibuka
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna latar belakang halaman
      backgroundColor: Colors.deepPurple[50],
      body: Center(
        // Tombol untuk masuk ke halaman utama To-Do
        child: ElevatedButton(
          onPressed: () {
            // Navigasi ke halaman ToDoHomePage saat tombol ditekan
            Navigator.push(context, MaterialPageRoute(builder: (_) => ToDoHomePage()));
          },
          // Tulisan pada tombol
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

// Model data ToDoItem untuk menyimpan informasi to-do
class ToDoItem {
  String title;       // Judul atau deskripsi to-do
  String category;    // Kategori to-do (misal: Umum, Sekolah, dll.)
  DateTime? reminder; // Waktu reminder (opsional)
  bool isDone;        // Status selesai atau belum

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
  // Daftar semua to-do yang tersimpan
  List<ToDoItem> _toDoList = [];

  // String pencarian untuk filter to-do
  String _searchQuery = "";

  // Controller untuk input teks to-do baru atau edit
  final _textController = TextEditingController();
  // Controller untuk input pencarian
  final _searchController = TextEditingController();

  // Kategori yang sedang dipilih saat tambah/edit to-do
  String _selectedCategory = 'Umum';

  // Waktu reminder yang dipilih
  DateTime? _selectedReminder;

  // List kategori yang tersedia
  final List<String> _categories = ['Umum', 'Sekolah', 'Belanja', 'Pekerjaan', 'Lainnya'];

  // Fungsi menambahkan to-do baru ke dalam list
  void _addToDo(String title, String category, DateTime? reminder) {
    if (title.trim().isEmpty) return; // Jangan tambah jika kosong
    setState(() {
      _toDoList.add(ToDoItem(title: title, category: category, reminder: reminder));
    });
  }

  // Fungsi mengubah isi to-do yang sudah ada berdasarkan index
  void _editToDo(int index, String newTitle, String newCategory, DateTime? reminder) {
    setState(() {
      _toDoList[index].title = newTitle;
      _toDoList[index].category = newCategory;
      _toDoList[index].reminder = reminder;
    });
  }

  // Fungsi menghapus to-do berdasarkan index
  void _deleteToDo(int index) {
    setState(() {
      _toDoList.removeAt(index);
    });
  }

  // Fungsi menandai to-do selesai/belum selesai
  void _toggleDone(int index) {
    setState(() {
      _toDoList[index].isDone = !_toDoList[index].isDone;
    });
  }

  // Menampilkan dialog untuk tambah to-do baru
  void _showAddDialog() {
    _textController.clear();       // Bersihkan teks input
    _selectedCategory = 'Umum';    // Reset kategori default
    _selectedReminder = null;      // Reset reminder

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text('Tambah To-Do'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Input teks to-do
                TextField(
                  controller: _textController,
                  autofocus: true,
                  decoration: InputDecoration(hintText: 'Tulis to-do di sini'),
                ),
                SizedBox(height: 10),
                // Dropdown kategori
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
                // Tombol untuk memilih waktu reminder
                TextButton(
                  onPressed: () async {
                    // Memilih tanggal
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      // Memilih waktu
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          // Set waktu reminder lengkap dengan jam dan menit
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
            // Tombol batal menutup dialog
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
            // Tombol tambah menambahkan to-do baru
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

  // Menampilkan dialog untuk mengedit to-do yang dipilih
  void _showEditDialog(int index) {
    // Isi input dengan data to-do yang ingin diedit
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
                // Input teks edit to-do
                TextField(controller: _textController),
                SizedBox(height: 10),
                // Dropdown kategori edit
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
                // Tombol edit reminder
                TextButton(
                  onPressed: () async {
                    // Pilih tanggal reminder baru
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedReminder ?? DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      // Pilih waktu reminder baru
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
            // Tombol batal menutup dialog
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Batal')),
            // Tombol simpan mengupdate to-do
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
    // Filter to-do sesuai kata pencarian yang diinput
    final filteredList = _toDoList.where((item) {
      return item.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        actions: [
          // Tombol untuk membuka dialog pencarian to-do
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
                      // Update pencarian saat user mengetik
                      setState(() => _searchQuery = value);
                    },
                  ),
                  actions: [
                    // Tombol reset pencarian
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        Navigator.pop(context);
                      },
                      child: Text('Reset'),
                    ),
                    // Tombol tutup dialog pencarian
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
            child: Text(
              'Search',  // Tombol dengan tulisan "Search"
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      // Body menampilkan daftar to-do atau teks jika kosong
      body: filteredList.isEmpty
          ? Center(child: Text('Belum ada To-Do nih, yuk isi!'))  // Pesan jika belum ada to-do
          : ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final actualIndex = _toDoList.indexOf(item);
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    // Checkbox untuk menandai selesai/belum
                    leading: Checkbox(
                      value: item.isDone,
                      onChanged: (_) => _toggleDone(actualIndex),
                    ),
                    // Judul to-do, garis coret jika sudah selesai
                    title: Text(
                      item.title,
                      style: TextStyle(
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    // Subtitle menampilkan kategori dan reminder jika ada
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori: ${item.category}'),
                        if (item.reminder != null)
                          Text('Reminder: ${item.reminder.toString()}'),
                      ],
                    ),
                    // Tombol edit dan hapus di sisi kanan
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
      // Tombol tambah to-do baru mengambang di pojok kanan bawah
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
        tooltip: 'Tambah To-Do',
      ),
    );
  }
}
