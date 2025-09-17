import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Import your new file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GX Blitz',
      theme: ThemeData(
        // Global theme for eye comfort: Dark with vibrant accents
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF1A0033), // Purple
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00D4FF), // Blue
          secondary: const Color(0xFFFFFF00), // Yellow
          error: Colors.red, // Red for errors
          tertiary: Colors.orange, // Orange accents
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}
