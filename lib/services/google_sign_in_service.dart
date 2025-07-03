import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final _googleSignIn = GoogleSignIn();

  static Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  static Future<void> signOut() => _googleSignIn.signOut();
}
