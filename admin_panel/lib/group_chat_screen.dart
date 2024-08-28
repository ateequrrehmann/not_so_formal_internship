import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'group_chat_room.dart';

class GroupChatHomeScreen extends StatefulWidget {
  const GroupChatHomeScreen({super.key});

  @override
  State<GroupChatHomeScreen> createState() => _GroupChatHomeScreenState();
}

class _GroupChatHomeScreenState extends State<GroupChatHomeScreen> {
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
    await getAvailableGroups();
  }

  // Future<void> fetchPhone() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   phone = prefs.getString('user_phone')!;
  //   print('my phone in group chat $phone');
  // }

  Future<void> getAvailableGroups() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot groupSnapshot = await _firestore.collection('groups').get();

      setState(() {
        groupList = groupSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'] ?? 'No Name'
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching groups: $e');
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
        title: Text('Groups'),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: groupList.isEmpty
                  ? Center(
                      child: Text('no group found'),
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
                            builder: (context) => GroupChatRoom(
                                  groupChatId: groupList[index]['id'],
                                  groupName: groupList[index]['name'],
                                )));
                  },
                  leading: Icon(Icons.group),
                  title: Text(groupList[index]['name']),
                );
              }),
    );
  }
}
