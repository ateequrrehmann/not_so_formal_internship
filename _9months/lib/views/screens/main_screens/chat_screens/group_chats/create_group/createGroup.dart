import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/views/screens/main_screens/bottom_navigation_bar/bottom_nav_bar.dart';
import 'package:myapp/views/screens/main_screens/chat_screens/chat_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class CreateGroup extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const CreateGroup({super.key, required this.membersList});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void createGroup() async {
    setState(() {
      isLoading = true;
    });

    String groupId = Uuid().v1();
    await _firestore.collection('groups').doc(groupId).set({
      'members': widget.membersList,
      'id': groupId,
      'name': _groupNameController.text,
      'totalMembers': widget.membersList.length
    });

    for (int i = 0; i < widget.membersList.length; i++) {
      String phone = widget.membersList[i]['phone'];
      await _firestore
          .collection('users')
          .doc(phone)
          .collection('groups')
          .doc(groupId)
          .set({'name': _groupNameController.text, 'id': groupId});
    }

    SharedPreferences prefs=await SharedPreferences.getInstance();
    final adminPhone=prefs.getString('user_phone');
    print('admin phone $adminPhone');
    DocumentSnapshot documentSnapshot=await _firestore.collection('users').doc(adminPhone).get();
    final adminName=documentSnapshot.get('name');
    print(adminName);


    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      'message': '$adminName Created this Group.',
      'type': 'notify',
      'time': FieldValue.serverTimestamp(),
    });


    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Group created successfully'),
      ),
    );
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CustomBottomNavigationBar()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBEB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EBEB),

        title: Text('Group Name'),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              child: CircularProgressIndicator(),
              alignment: Alignment.center,
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 10,
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _groupNameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white30,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              hintText: "Name",
                              prefixIcon: const Icon(
                                Icons.search,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Group Name can\'t be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height / 50,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      createGroup();
                    }
                  },
                  child: Text('Create Group'),
                )
              ],
            ),
    );
  }
}
