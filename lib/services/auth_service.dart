
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Register
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(name.trim());

        await _firestore.collection('users').doc(user.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registrasi gagal.';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  // Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login gagal.';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Mengambil pengguna yang sedang login
  User? get currentUser => _auth.currentUser;
}
