
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PersonalFinanceApp());
}

class PersonalFinanceApp extends StatelessWidget {
  const PersonalFinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7655C8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
