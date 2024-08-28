import 'package:admin_panel/articles_page.dart';
import 'package:admin_panel/chat_screen.dart';
import 'package:admin_panel/group_chat_screen.dart';
import 'package:admin_panel/user_list_screen.dart';
import 'package:flutter/material.dart';

import 'expert_screen.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10.0),
        children: [
          FeatureCard(
            title: 'Articles',
            icon: Icons.article,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const ArticlesPage(title: 'articles',)))
          ),
          FeatureCard(
            title: 'Exercises',
            icon: Icons.fitness_center,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const ArticlesPage(title: 'exercises',)))
          ),
          FeatureCard(
            title: 'Diet & Nutrients',
            icon: Icons.restaurant,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const ArticlesPage(title: 'diet',)))
          ),
          FeatureCard(
            title: 'Group Chat',
            icon: Icons.group,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const GroupChatHomeScreen()))
          ),
          FeatureCard(
            title: 'Users',
            icon: Icons.person,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>UserListScreen()))
          ),
          FeatureCard(
            title: 'One-to-One Chat',
            icon: Icons.chat,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const ChatHomeScreen()))
          ),
          FeatureCard(
              title: 'Expert',
              icon: Icons.add,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>const ExpertScreen()))
          ),
        ],
      ),
    );
  }
}


class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, size: 50.0),
        title: Text(title, style: const TextStyle(fontSize: 18.0)),
        onTap: onTap,
      ),
    );
  }
}
