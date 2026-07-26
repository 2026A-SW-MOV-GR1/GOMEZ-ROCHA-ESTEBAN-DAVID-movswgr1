import 'package:flutter/material.dart';
import 'intents_screen.dart';
import 'recepcion_screen.dart';

class IntentsTabScreen extends StatelessWidget {
  const IntentsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Intents del Sistema'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.upload), text: 'Salientes'),
              Tab(icon: Icon(Icons.download), text: 'Entrantes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            IntentsScreen(),
            RecepcionScreen(),
          ],
        ),
      ),
    );
  }
}