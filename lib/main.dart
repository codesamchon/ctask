import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light 
          ? ThemeMode.dark 
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = TodoProvider();
        // Initialize the provider asynchronously
        provider.init();
        return provider;
      },
      child: MaterialApp(
        title: 'CTask - Todo List',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _themeMode,
        home: HomeScreen(onThemeToggle: _toggleTheme),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
