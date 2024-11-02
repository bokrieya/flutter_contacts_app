import 'package:flutter/material.dart';
import 'package:your_project_name/pages/login_page.dart';
import './home.dart'; // Import your home page or main screen here

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Animation controller for a loading indicator or splash icon animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // Navigate to home after delay
    _navigateToHome();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Splash image
            Image.asset(
              'assets/images/splash_icon.png', // Replace with your splash image
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            // App name or welcome message
            const Text(
              'Welcome to Contacts App',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White color for better visibility
              ),
            ),
            const SizedBox(height: 30),
            // Circular progress indicator (animated)
            CircularProgressIndicator(
              valueColor: _controller.drive(
                ColorTween(
                  begin: Colors.white,
                  end: Colors.deepPurple[100],
                ),
              ),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            // Sub-text (optional)
            const Text(
              'Loading your contacts...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
