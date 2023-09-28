import 'package:flutter/material.dart';
import './presentation/home/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelTracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.orange,
          brightness: Brightness.light,
        ),
      ),
      home: const HomePage(),
    );
  }
}
