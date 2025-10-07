import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class AppTheme {
  // Monotone color scheme - using shades of grey and blue-grey
  static const Color _primaryColor = Color(0xFF546E7A);
  static const Color _primaryVariant = Color(0xFF37474F);
  static const Color _surfaceColor = Color(0xFFF5F5F5);
  static const Color _onSurfaceColor = Color(0xFF212121);

  // Dark theme colors
  static const Color _darkPrimaryColor = Color(0xFF78909C);
  static const Color _darkPrimaryVariant = Color(0xFF455A64);
  static const Color _darkSurfaceColor = Color(0xFF303030);
  static const Color _darkOnSurfaceColor = Color(0xFFE0E0E0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _primaryColor,
        primaryContainer: _primaryVariant,
        surface: _surfaceColor,
        surfaceContainerHighest: const Color(0xFFE0E0E0),
        onSurface: _onSurfaceColor,
        onPrimary: Colors.white,
        secondary: const Color(0xFF607D8B),
        onSecondary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFFB0BEC5),
        indicatorColor: Colors.white,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: _surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _onSurfaceColor),
        bodyMedium: TextStyle(color: _onSurfaceColor),
        bodySmall: TextStyle(color: _onSurfaceColor),
        titleLarge: TextStyle(color: _onSurfaceColor, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _onSurfaceColor, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: _onSurfaceColor, fontWeight: FontWeight.w500),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: _surfaceColor,
        titleTextStyle: TextStyle(color: _onSurfaceColor, fontSize: 20, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: _onSurfaceColor, fontSize: 16),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _darkPrimaryColor,
        primaryContainer: _darkPrimaryVariant,
        surface: _darkSurfaceColor,
        surfaceContainerHighest: const Color(0xFF424242),
        onSurface: _darkOnSurfaceColor,
        onPrimary: Colors.black,
        secondary: const Color(0xFF90A4AE),
        onSecondary: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Color(0xFF90A4AE),
        indicatorColor: Colors.white,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: _darkSurfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: _darkOnSurfaceColor),
        bodyMedium: TextStyle(color: _darkOnSurfaceColor),
        bodySmall: TextStyle(color: _darkOnSurfaceColor),
        titleLarge: TextStyle(color: _darkOnSurfaceColor, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: _darkOnSurfaceColor, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: _darkOnSurfaceColor, fontWeight: FontWeight.w500),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: _darkSurfaceColor,
        titleTextStyle: TextStyle(color: _darkOnSurfaceColor, fontSize: 20, fontWeight: FontWeight.w600),
        contentTextStyle: TextStyle(color: _darkOnSurfaceColor, fontSize: 16),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimaryColor,
        ),
      ),
    );
  }

  // State-specific colors
  static Color getTodoStateColor(TodoState state, bool isDark) {
    switch (state) {
      case TodoState.todo:
        return isDark ? const Color(0xFF90A4AE) : const Color(0xFF607D8B);
      case TodoState.doing:
        return isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50);
      case TodoState.pending:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800);
      case TodoState.done:
        return isDark ? const Color(0xFF78909C) : const Color(0xFF546E7A);
    }
  }
}

