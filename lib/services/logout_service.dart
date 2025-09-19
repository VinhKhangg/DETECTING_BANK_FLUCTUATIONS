import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/login_screen.dart';

class LogoutService {
  static Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}
