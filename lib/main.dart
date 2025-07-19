import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test1_app/screens/item_list_screen.dart'; // Assuming this path

void main() {
  runApp(
    const ProviderScope( // Required for Riverpod
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        // Or your custom M3 colors
        // Optional: Customize input decoration for TextFields globally
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          // fillColor: Colors.grey.shade100, // Example fill color
        ),
        // Optional: Card theme
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      home: const ItemListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}