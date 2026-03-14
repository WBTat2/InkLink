import 'package:flutter/material.dart';

class IdeaBoardScreen extends StatelessWidget {
  const IdeaBoardScreen({super.key});

  @override
  Widget build(BuildContext pathCtx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tattoo Ideas')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Idea Board coming soon.'),
      ),
    );
  }
}
