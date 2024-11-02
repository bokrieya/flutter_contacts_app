import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdayController = TextEditingController();
 final _dbHelper = DatabaseHelper.instance;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  // Validate email format
  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Register user
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();
      String address = _addressController.text.trim();
      String birthday = _birthdayController.text.trim();

      try {
        // Check if user already exists
        final existingUsers = await _dbHelper.getUsers();
        if (existingUsers.any((user) => user.email == email)) {
          setState(() {
            _errorMessage = 'Email already exists!';
          });
          return;
        }

        // Insert new user
        User newUser = User(
          email: email,
          password: password,
          address: address,
          birthday: birthday,
        );
        await _dbHelper.insertUser(newUser);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );

        Navigator.pop(context, true); // Close the page on success
      } catch (e) {
        setState(() {
          _errorMessage = 'Error during registration: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  } else if (!_isEmailValid(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              
              // Confirm Password Field
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              
              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),
              
              // Birthday Field
              TextFormField(
                controller: _birthdayController,
                decoration: InputDecoration(labelText: 'Birthday (YYYY-MM-DD)'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your birthday';
                  }
                  return null;
                },
              ),
              
              SizedBox(height: 20),

              // Sign-Up Button
              ElevatedButton(
                onPressed: _register,
                child: Text('Sign Up'),
              ),

              // Error Message
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
      ),
    );
  }
}
