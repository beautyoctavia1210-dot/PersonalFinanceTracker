
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user != null
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7655C8),
              Color(0xFF9B7BE8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                size: 65,
                color: Color(0xFF7655C8),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'MyFinance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Manage your money wisely',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 50),

            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
