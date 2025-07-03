import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/login_screen.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const CyberDevTodoApp());
}

class CyberDevTodoApp extends StatelessWidget {
  const CyberDevTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Cyber Dev Todo',
            theme: _lightTheme,
            darkTheme: _darkTheme,
            themeMode: themeProvider.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.user == null) {
                  return const LoginScreen();
                } else {
                  return const TaskHubScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

// Themes
final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.cyan,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.cyan.shade700,
    titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.cyan.shade700,
    titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
);
