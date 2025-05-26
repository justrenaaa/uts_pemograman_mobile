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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
            Icon(
              Icons.checklist_rtl,
              size: 100,
              color: Colors.white,
            ),
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
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
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
        title: const Text('Daftar Tugas Saya'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang di Aplikasi To-Do List!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Di sini Anda bisa menambahkan navigasi ke halaman lain,
                // misalnya untuk menambahkan tugas baru.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anda siap menambahkan tugas!')),
                );
              },
              child: const Text('Mulai Tambah Tugas'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi ketika tombol FAB ditekan (misalnya, tambah tugas baru)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tombol Tambah Tugas Ditekan!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
