import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/splash_screen.dart'; // Import the splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: SplashScreen(), // Start with the splash screen
      debugShowCheckedModeBanner: false,
    );
  }
}
