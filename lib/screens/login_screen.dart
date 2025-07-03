import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/matrix_rain_background.dart';
import '../widgets/google_sign_in_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.user != null) {
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed('/tasks');
      });
    }

    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: Colors.black,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // Matrix rain animation background
            const MatrixRainBackground(
              color: Colors.greenAccent,
              columnCount: 30,
            ),

            // Glassmorphism login panel
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CYBER DEV TODO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Courier New',
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            blurRadius: 12,
                            color: Colors.greenAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    authProvider.isLoading
                        ? const CircularProgressIndicator(
                        color: Colors.greenAccent)
                        : GoogleSignInButton(
                      onPressed: () async {
                        try {
                          await authProvider.signIn();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Login failed: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}