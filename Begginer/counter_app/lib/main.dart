import 'package:counter_app/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      debugShowCheckedModeBanner: false,
      //By defining ThemeData at the root (MaterialApp),
      //any widget below it in the tree can inherit these
      //styles automatically, eliminating the need to hardcode
      //colors or styles on every single widget
      theme: ThemeData(
        // This is a convenience constructor that creates a full ColorScheme 
        //(primary, secondary, surface, error, etc.) 
        //based on a single "seed" color (Colors.indigo).
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
