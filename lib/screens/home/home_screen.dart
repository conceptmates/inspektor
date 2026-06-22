import 'package:flutter/material.dart';

// ponytail: P0 placeholder. Replaced by the real dashboard in P5.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Certifide Inspektor')),
      body: const Center(child: Text('Inspektor')),
    );
  }
}
