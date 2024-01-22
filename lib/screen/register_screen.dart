import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:testes/screen/login_screen.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isChecked = false;
  bool _isObscure = true;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  String? validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email cannot be empty.';
    } else if (value.length < 6) {
      return 'Email must be at least 6 characters long.';
    }
    return null;
  }

  Future<void> _registerWithFirebase() async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', _emailController.text.trim());
      prefs.setBool('isChecked', _isChecked);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text(e.message ?? "Registration failed."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  TextEditingController _contactController = TextEditingController();
  List<Contact> _contacts = [];

  Future<void> contactPermission() async {
    if (await Permission.contacts.status.isGranted) {
      // Permission already granted
    } else {
      var status = await Permission.contacts.request();
      if (status == PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
    }
  }

  void getContacts() async {
    await contactPermission();
    List<Contact> contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  void pickContact() async {
    Contact? contact = await ContactsService.openDeviceContactPicker();
    if (contact != null) {
      setState(() {
        _contactController.text = contact.phones?.first.value ?? '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getContacts();
  }

  Future<void> _openLoginPage() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _openContacts() async {
    _pickPhoneNumber();
  }

  Future<void> _pickPhoneNumber() async {
    Iterable<Contact> contacts = await ContactsService.getContacts(
      withThumbnails: false,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Phone Number"),
          content: SingleChildScrollView(
            child: ListBody(
              children: contacts.map((contact) {
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  subtitle: Text(contact.phones?.isNotEmpty == true
                      ? contact.phones!.first.value!
                      : 'No phone number available'),
                  onTap: () {
                    _phoneNumberController.text =
                        contact.phones?.isNotEmpty == true
                            ? contact.phones!.first.value!
                            : '';
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[300],
      appBar: AppBar(
        title: const Text(
          "Me Apps - Register",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Welcome to Me Apps",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Your Email",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    border: const OutlineInputBorder(),
                    hintText: 'Enter your email!',
                    errorText: validateEmail(_emailController.text),
                  ),
                ),
              ),
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    border: const OutlineInputBorder(),
                    hintText: 'Enter password (min. 8 characters)',
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      child: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                "Confirm Password",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    border: const OutlineInputBorder(),
                    hintText: 'Re-enter password',
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      child: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
              ),
              const Text(
                "Phone Number",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _contactController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    border: const OutlineInputBorder(),
                    hintText: 'Enter phone number',
                    suffixIcon: GestureDetector(
                      onTap: () {
                        pickContact();
                      },
                      child: Icon(
                        Icons.contacts,
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  String? usernameError = validateEmail(_emailController.text);

                  if (usernameError != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Error"),
                          content: Text(usernameError),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    _registerWithFirebase();
                  }
                },
                child: const Text("Register"),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _openLoginPage();
                },
                child: const Text(
                  "Already have an account? Login here",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
