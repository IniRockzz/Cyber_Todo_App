import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: Text(themeProvider.isDark ? 'Dark' : 'Light'),
            trailing: Switch(
              value: themeProvider.isDark,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Cyber Dev Todo v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Cyber Dev Todo',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.check_circle),
                children: [
                  const Text('A simple, beautiful, and productive task manager built with Flutter.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
