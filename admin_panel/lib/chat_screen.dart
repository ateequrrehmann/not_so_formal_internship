import 'package:admin_panel/chat_room.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'group_chat_room.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List groupList = [];
  String phone = '';

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // await fetchPhone();
    await getAvailableChats();
    print('hello');
  }

  // Future<void> fetchPhone() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   phone = prefs.getString('user_phone')!;
  //   print('my phone in group chat $phone');
  // }

  Future<void> getAvailableChats() async {
    print('chats');
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot chatSnapshot = await _firestore.collection('chatroom').get();

      setState(() {
        groupList = chatSnapshot.docs.map((doc) {
          print(doc['name']);
          return {
            'id': doc.id,
            'name': doc['name']
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching chats: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EBEB),
        title: Text('Chats'),
      ),
      body: isLoading
          ? Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        child: groupList.isEmpty
            ? Center(
          child: Text('No chat found'),
        )
            : CircularProgressIndicator(),
      )
          : ListView.builder(
          itemCount: groupList.length,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatRoom(chatId: groupList[index]['id'], name: 'Chat')));
              },
              leading: Icon(Icons.chat),
              title: Text('Chat ${groupList[index]['name']}'),
            );
          }),

    );
  }
}
