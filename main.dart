import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'UTMACH App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFF003B73),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF003B73),
          secondary: Colors.amber,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF002244),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF002244),
          secondary: Colors.amber,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
