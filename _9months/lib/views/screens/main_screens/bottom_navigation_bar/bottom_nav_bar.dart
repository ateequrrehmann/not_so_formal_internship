import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../chat_screens/chat_home_screen.dart';
import '../home_screen.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  Future<String> fetchPhoneData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_phone')!;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: fetchPhoneData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error fetching phone data')),
          );
        } else {
          _screens = [
            HomePage(),
            ChatScreen(),
          ];

          return Scaffold(
            body: _screens[_currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              items: [
                BottomNavigationBarItem(
                  icon: _currentIndex == 0
                      ? Icon(Icons.home)
                      : Icon(Icons.home_outlined),
                  label: 'Home',
                  tooltip: 'Go to Home',
                ),
                BottomNavigationBarItem(
                  icon: _currentIndex == 1
                      ? Icon(Icons.chat)
                      : Icon(Icons.chat_outlined),
                  label: 'Chats',
                  tooltip: 'View Chats',
                ),
                // BottomNavigationBarItem(
                //   icon: _currentIndex == 2
                //       ? Icon(Icons.person)
                //       : Icon(Icons.person_outlined),
                //   label: 'Profile',
                //   tooltip: 'See Profile',
                // ),
              ],
            ),
          );
        }
      },
    );
  }
}
