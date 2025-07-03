import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  GoogleSignInAccount? _user;
  bool _isLoading = false;

  GoogleSignInAccount? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> signIn() async {
    try {
      _isLoading = true;
      notifyListeners();

      final account = await _googleSignIn.signIn();
      if (account != null) {
        _user = account;
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }
}
