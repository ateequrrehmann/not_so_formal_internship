import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bottom_navigation_bar/bottom_nav_bar.dart';
import 'add_members.dart';

class GroupInfo extends StatefulWidget {
  final String groupName;
  final String groupId;

  const GroupInfo({super.key, required this.groupName, required this.groupId});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List membersList = [];
  bool isLoading = true;

  bool checkAdmin(String adminPhone) {
    print(membersList);
    bool isAdmin = false;
    for (var element in membersList) {
      if (element['phone'] == adminPhone) {
        print(adminPhone);
        print('element phone ${element['phone']}');
        print('admin phone ${element['isAdmin']}');
        isAdmin = element['isAdmin'];
      }
    }
    return isAdmin;
  }

  void getGroupMember() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((value) {
      setState(() {
        membersList = value['members'];
        isLoading = false;
      });
    });
  }

  void removeUser(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final checkPhone = prefs.getString('user_phone');

    if (checkAdmin(checkPhone!)) {
      if (membersList[index]['isAdmin'] == false) {
        setState(() {
          isLoading = true;
        });
        String phone = membersList[index]['phone'];
        membersList.removeAt(index);

        await _firestore.collection('groups').doc(widget.groupId).update({
          'members': membersList,
        });

        await _firestore
            .collection('users')
            .doc(phone)
            .collection('groups')
            .doc(widget.groupId)
            .delete();

        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User removed successfully'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You don\'t have enough rights to remove members'),
        ),
      );
    }
  }

  void onLeaveGroup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone');
    if (!checkAdmin(phone!)) {
      setState(() {
        isLoading = true;
      });

      membersList.removeWhere((member) => member['phone'] == phone);

      await _firestore.collection('groups').doc(widget.groupId).update({
        'members': membersList,
      });

      await _firestore
          .collection('users')
          .doc(phone)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      setState(() {
        isLoading = false;
      });

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CustomBottomNavigationBar()),
              (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Can\'t leave the group'),
        ),
      );
    }
  }

  void showRemoveDialog(int index) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: ListTile(
              onTap: () => removeUser(index),
              title: Text('Remove this member'),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    getGroupMember();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EBEB),
        title: Text('Group Info'),
      ),
      body: isLoading
          ? Container(
        height: size.height,
        width: size.width,
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: size.height / 8,
              width: size.width / 1.1,
              child: Row(
                children: [
                  Container(
                    child: Icon(Icons.group, size: size.width / 10),
                    height: size.height / 7,
                    width: size.width / 7,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey),
                  ),
                  SizedBox(
                    width: size.width / 20,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        '${widget.groupName}',
                        style: TextStyle(
                            fontSize: size.width / 16,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: size.height / 20,
            ),
            Container(
              width: size.width / 1.1,
              child: Text(
                '${membersList.length} Members',
                style: TextStyle(
                    fontSize: size.width / 20,
                    fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              height: size.height / 100,
            ),
            ListTile(
              onTap: () async {
                SharedPreferences prefs =
                await SharedPreferences.getInstance();
                final checkPhone = prefs.getString('user_phone');
                print('mera number $checkPhone');
                if (checkAdmin(checkPhone!)) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddMembersInGroupAfterCreation(
                            groupName: widget.groupName,
                            groupId: widget.groupId,
                            membersList: membersList,
                          )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                      Text('You don\'t have rights to add members'),
                    ),
                  );
                }
              },
              leading: Icon(
                Icons.add,
              ),
              title: Text(
                'Add member',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: size.width / 22,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      removeUser(index);
                    },
                    leading: CircleAvatar(
                      backgroundImage:
                      NetworkImage(membersList[index]['imageUrl']),
                    ),
                    title: Text(
                      membersList[index]['name'],
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: size.width / 22),
                    ),
                    subtitle: Text(membersList[index]['bio']),
                    trailing: Text(
                        membersList[index]['isAdmin'] ? 'Admin' : ''),
                  );
                },
                itemCount: membersList.length,
                shrinkWrap: true,
              ),
            ),
            ListTile(
              onTap: onLeaveGroup,
              leading: Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: Text(
                'Leave Group',
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: size.width / 22,
                    color: Colors.redAccent),
              ),
            )
          ],
        ),
      ),
    );
  }
}
