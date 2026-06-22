import 'package:flutter/material.dart';

// ponytail: stub — real dynamic inspection capture built in P6.
class InspectionScreen extends StatelessWidget {
  const InspectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection')),
      body: const Center(child: Text('Dynamic inspection — coming in P6')),
    );
  }
}
