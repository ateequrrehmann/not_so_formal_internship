import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_page.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({Key? key}) : super(key: key);

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  String phone = '';

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

  void onSearch() async {
    String inputPhone = _searchController.text;
    if (inputPhone.startsWith('0')) {
      inputPhone = inputPhone.substring(1);
    }
    String completePhone = '+92$inputPhone';

    print('Searching for user with phone: $completePhone');
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    setState(() {
      isLoading = true;
    });
    try {
      await _firestore
          .collection('users')
          .where("phone", isEqualTo: completePhone)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          setState(() {
            userMap = value.docs[0].data();
          });
          print(userMap);
        } else {
          print("No user found with this phone number.");
        }
      });
    } catch (e) {
      print("Error occurred while searching: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  fetchData() async {
    await fetchPhone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Chat"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by phone number",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              onSubmitted: (value) => onSearch(),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : userMap != null
                    ? ListTile(
                        onTap: () {
                          // Handle chat initiation here
                          String roomId = chatRoomId(phone, userMap!['phone']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoom(
                                chatRoomId: roomId,
                                userMap: userMap!,
                                senderName: phone,
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(userMap!['imageUrl']),
                        ),
                        title: Text(userMap!['name']),
                        subtitle: Text(userMap!['bio']),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}
