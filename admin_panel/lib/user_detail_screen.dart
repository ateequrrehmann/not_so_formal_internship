import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  UserDetailsScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user['name']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Phone: ${user['phone']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Bio: ${user['bio']}', style: TextStyle(fontSize: 18)),

            SizedBox(height: 10),
            Text('Online: ${user['isOnline']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('User ID: ${user['uid']}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
