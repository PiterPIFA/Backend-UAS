import 'package:flutter/material.dart';
import 'package:testes/screen/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testes/screen/news_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedValues();
  }

  _loadSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('email') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _isChecked = prefs.getBool('isChecked') ?? false;
    });
  }

  _saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', _emailController.text);
    prefs.setString('password', _passwordController.text);
    prefs.setBool('isChecked', _isChecked);
  }

  bool _isPasswordValid() {
    return _passwordController.text.length > 8;
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      // Lakukan aksi ketika izin diberikan
      // Contoh: Akses kamera
    } else if (status.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Permission Required"),
            content: const Text(
                "This app needs access to the camera. Please enable it in the app settings."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text("Open Settings"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      appBar: AppBar(
        title: const Text(
          "Me Apps",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _requestCameraPermission();
              },
              child: const CircleAvatar(
                radius: 75,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                    'https://media.istockphoto.com/id/860586342/id/vektor/ilustrasi-vektor-kartun-konsep-breaking-news-koresponden-dengan-mikrofon-reporter-berita.jpg?s=1024x1024&w=is&k=20&c=vdyx76y7UWBxp-mHwkvqqofMkuYr1MQFtvt9bfCMW4U='),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Email anda",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _emailController,
                onChanged: (value) => _saveValues(),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan email anda !',
                ),
              ),
            ),
            const Text(
              "Password anda",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _passwordController,
                onChanged: (value) => _saveValues(),
                obscureText: true,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  border: const OutlineInputBorder(),
                  hintText: 'Masukkan password (min. 8 karakter)',
                  errorText: _isPasswordValid()
                      ? null
                      : 'Password harus lebih dari 8 karakter',
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value!;
                      _saveValues();
                    });
                  },
                ),
                const Text(
                  "Saya Menyetujui Persyaratan yang ada",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // ignore: unused_local_variable
                  UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewsScreen()),
                  );
                } on FirebaseAuthException catch (e) {
                  String errorMessage = '';

                  if (e.code == 'user-not-found') {
                    errorMessage = 'Email belum terdaftar.';
                  } else if (e.code == 'wrong-password') {
                    errorMessage = 'Password salah.';
                  } else {
                    errorMessage = 'Terjadi kesalahan saat login.';
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text("Belum punya akun? Register di sini"),
            ),
          ],
        ),
      ),
    );
  }
}
