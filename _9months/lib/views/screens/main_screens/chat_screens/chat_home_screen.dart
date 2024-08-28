import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/providers/future_provider/user_data_provider.dart';
import 'package:myapp/views/screens/main_screens/chat_screens/group_chats/group_chat_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../providers/state_notifier_provider/userProvider.dart';
import '../../../../services/chat_service.dart';
import 'chat_page.dart';
import 'new_chat_screen.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  String phone = '';
  bool isLoading = false;
  List<Map<String, dynamic>> allUsers = [];

  Future<void> fetchPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('user_phone')!;
    print(phone);
  }

  String chatRoomId(String user1, String user2) {
    List<String> users = [user1, user2];
    users.sort();
    return "${users[0]}${users[1]}";
  }

  Future<void> fetchAllUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      await _firestore.collection('users').get().then((value) async {
        List<Map<String, dynamic>> users = value.docs
            .map((doc) => doc.data())
            .where((user) => user['phone'] != phone)
            .toList();

        List<Map<String, dynamic>> filteredUsers = [];
        for (var user in users) {
          String roomId = chatRoomId(phone, user['phone']);
          print(roomId);
          QuerySnapshot chatSnapshot = await _firestore
              .collection('chatroom')
              .doc(roomId)
              .collection('chats')
              .get();

          if (chatSnapshot.docs.isNotEmpty) {
            print('Active chatroom found for user: ${user['phone']}');
            filteredUsers.add(user);
          } else {
            print('No active chatroom found for user: ${user['phone']}');
          }
        }

        setState(() {
          allUsers = filteredUsers;
        });
      });
    } catch (e) {
      print("Error occurred while fetching users: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPhone().then((_) => fetchAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBEB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110.0),
        child: AppBar(
          backgroundColor: const Color(0xFFE9EBEB),
          title: Text('Chat'),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : allUsers.isNotEmpty
          ? ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          final user = allUsers[index];
          return ListTile(
            onTap: () {
              String roomId = chatRoomId(phone, user['phone']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoom(
                    chatRoomId: roomId,
                    userMap: user,
                    senderName: phone,
                  ),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user['imageUrl']),
            ),
            title: Text(
              user['name'],
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500),
            ),
            subtitle: Text(user['bio']),
            trailing: Icon(
              Icons.chat,
              color: Colors.black,
            ),
          );
        },
      )
          : Center(child: Text("No users found")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("New Chat"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewChatScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.group),
                    title: Text("Group Chat"),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GroupChatHomeScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
