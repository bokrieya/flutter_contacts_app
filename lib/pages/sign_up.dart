import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  String? _errorMessage;

  Future<void> _register() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();
    String address = _addressController.text.trim();
    String birthday = _birthdayController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty && address.isNotEmpty && birthday.isNotEmpty) {
      final existingUsers = await _dbHelper.getUsers();
      if (existingUsers.any((user) => user.username == username)) {
        setState(() {
          _errorMessage = 'Username already exists!';
        });
      } else {
        try {
          User newUser = User(
            username: username,
            password: password,
            address: address,
            birthday: birthday, 
          );
          await _dbHelper.insertUser(newUser);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Registration successful!'),
          ));
          await Future.delayed(Duration(seconds: 1));
          Navigator.pop(context, true);
        } catch (e) {
          setState(() {
            _errorMessage = 'Error during registration: $e';
          });
        }
      }
    } else {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView( // Wrap the content in a scrollable view
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: 'Birthday (YYYY-MM-DD)'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _register,
                child: Text('Sign Up'),
              ),
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
