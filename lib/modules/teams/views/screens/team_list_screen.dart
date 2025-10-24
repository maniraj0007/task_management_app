import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Team List Screen
/// Displays list of teams user is part of
class TeamListScreen extends StatelessWidget {
  const TeamListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed('/teams/invitations'),
            icon: const Icon(Icons.mail),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/search'),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Teams Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Collaborate with your teams',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
