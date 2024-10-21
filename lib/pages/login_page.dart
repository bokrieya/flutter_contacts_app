import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Make sure you import the HomePage class
import '../pages/sign_up.dart'; // Import your SignUpPage class

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Color myColor;
  late Size mediaSize;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberUser = false;
  String? errorMessage; // To store error messages for username
  String? passwordErrorMessage; // To store error messages for password
  bool _isPasswordVisible = false; // Track password visibility

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on init
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');
    bool? savedRememberUser = prefs.getBool('rememberUser');

    if (savedRememberUser == true) {
      emailController.text = savedUsername ?? '';
      passwordController.text = savedPassword ?? '';
      rememberUser = true;
    }
  }

  // Function to validate and navigate
  void _login() async {
    setState(() async {
      // Clear the error messages
      errorMessage = null;
      passwordErrorMessage = null;

      // Validate if username (emailController) is empty
      if (emailController.text.isEmpty) {
        errorMessage = "Username cannot be empty";
      }
      // Validate if password is empty
      else if (passwordController.text.isEmpty) {
        passwordErrorMessage = "Password cannot be empty";
      } else {
        // Save user data if rememberUser is checked
        if (rememberUser) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('username', emailController.text);
          prefs.setString('password', passwordController.text);
          prefs.setBool('rememberUser', true);
        } else {
          // Clear saved user data if rememberUser is unchecked
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('username');
          prefs.remove('password');
          prefs.setBool('rememberUser', false);
        }

        // Navigate to Home page if validation is successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true; // Allow back navigation
      },
      child: Container(
        decoration: BoxDecoration(
          color: myColor,
          image: DecorationImage(
            image: const AssetImage("assets/images/bg.jpeg"),
            fit: BoxFit.cover,
            colorFilter:
                ColorFilter.mode(myColor.withOpacity(0.2), BlendMode.dstATop),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(children: [
            Positioned(top: 80, child: _buildTop()),
            Positioned(bottom: 0, child: _buildBottom()),
          ]),
        ),
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Authentication",
          style: TextStyle(
              color: myColor, fontSize: 32, fontWeight: FontWeight.w500),
        ),
        _buildGreyText("Please login with your information"),
        const SizedBox(height: 60),
        _buildGreyText("Username"),
        _buildInputField(emailController),
        if (errorMessage != null)
          Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ), // Username error
        const SizedBox(height: 40),
        _buildGreyText("Password"),
        _buildInputField(passwordController, isPassword: true),
        if (passwordErrorMessage != null)
          Text(
            passwordErrorMessage!,
            style: const TextStyle(color: Colors.red),
          ), // Password error
        const SizedBox(height: 20),
        _buildRememberForget(),
        const SizedBox(height: 20),
        _buildLoginButton(), // Updated login button with validation
        const SizedBox(height: 20),
        _buildSignUpLink(), // Add sign-up link/button
      ],
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : const Icon(Icons.done),
      ),
      obscureText: isPassword ? !_isPasswordVisible : false,
    );
  }

  Widget _buildRememberForget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: rememberUser,
              onChanged: (value) {
                setState(() {
                  rememberUser = value!;
                });
              },
            ),
            _buildGreyText("Stay Connected"),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: _buildGreyText("I forgot my password"),
        ),
      ],
    );
  }

  // Updated Login Button with validation for username and password, and navigation to HomePage
  Widget _buildLoginButton() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _login, // Calls the validation and login logic
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                elevation: 20,
                shadowColor: myColor,
                minimumSize: const Size(150, 60),
              ),
              child: const Text("LOGIN"),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint("Quit button pressed");
                // Add quit logic here (e.g., exit the app, navigate to another page, etc.)
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                elevation: 20,
                shadowColor: myColor,
                minimumSize: const Size(150, 60),
              ),
              child: const Text("QUIT"),
            ),
          ],
        ),
      ],
    );
  }

  // Add Sign Up button
  Widget _buildSignUpLink() {
    return Center(
      child: TextButton(
        onPressed: () async {
          // Navigate to SignUpPage and wait for result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
          );

          // Check if registration was successful (i.e., result is true)
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Registration successful!'),
            ));
          }
        },
        child: Text(
          "Don't have an account? Sign Up",
          style: TextStyle(color: myColor),
        ),
      ),
    );
  }
}
