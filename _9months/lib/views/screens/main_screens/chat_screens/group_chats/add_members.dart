import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/views/screens/main_screens/chat_screens/chat_home_screen.dart';
import 'package:myapp/views/screens/main_screens/chat_screens/group_chats/group_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMembersInGroupAfterCreation extends StatefulWidget {
  final String groupName;
  final String groupId;
  final List membersList;
  const AddMembersInGroupAfterCreation({super.key, required this.groupName, required this.groupId, required this.membersList});

  @override
  State<AddMembersInGroupAfterCreation> createState() => _AddMembersInGroupAfterCreation();
}

class _AddMembersInGroupAfterCreation extends State<AddMembersInGroupAfterCreation> {
  Map<String, dynamic>? userMap;
  bool isLoading=false;
  final TextEditingController _searchController=TextEditingController();
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;
  List membersList=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    membersList=widget.membersList;
  }

  void onSearch() async {
    String inputPhone = _searchController.text;
    if (inputPhone.startsWith('0')) {
      inputPhone = inputPhone.substring(1);
    }
    String completePhone = '+92$inputPhone';

    print('Searching for user with phone: $completePhone');
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
  
  void onAddMembers() async{

    bool isAlreadyExist=false;

    for(int i=0; i<membersList.length; i++){
      if(membersList[i]['phone']==userMap!['phone']){
        isAlreadyExist=true;
      }
    }

    if(!isAlreadyExist){
      membersList.add({
        "name": userMap!['name'],
        'phone': userMap!['phone'],
        'isOnline': userMap!['isOnline'],
        'imageUrl': userMap!['imageUrl'],
        'bio': userMap!['bio'],
        'uid': userMap!['uid'],
        'isAdmin': false
      });
      print(membersList);


      await _firestore.collection('groups').doc(widget.groupId).update({
        'members': membersList,
        'totalMembers': membersList.length
      });



      await _firestore.collection('users').doc(userMap!['phone']).collection('groups').doc(widget.groupId).set({
        'name': widget.groupName ,
        'id': widget.groupId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User added Successfully'),
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>GroupInfo(groupName: widget.groupName, groupId: widget.groupId)));
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User already exists'),
        ),
      );
      _searchController.clear();
    }

  }

  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color(0xFFE9EBEB),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE9EBEB),
          title: Text('Add Members'),
        ),
        body: Column(
          children: [
            SizedBox(
              height: size.height / 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white30,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        hintText: "Search",
                        prefixIcon: const Icon(
                          Icons.search,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height / 50,
            ),
            isLoading
                ? Container(
              height: size.height / 12,
              width: size.width / 12,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            )
                : ElevatedButton(onPressed: onSearch, child: Text('Search')),

            userMap != null
                ? ListTile(
              leading: CircleAvatar(
                child: Container(
                  width: 20,
                  height: 20,
                ),
                backgroundImage: NetworkImage(userMap!['imageUrl']),
              ),
              title: Text(
                userMap!['name'],
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
              subtitle: Text(userMap!['bio']),
              trailing: GestureDetector(
                onTap: onAddMembers,
                child: Icon(
                  Icons.add,
                  color: Colors.black,
                ),
              ),
            )
                : SizedBox(),
            // ListTile(
            //   onTap: () {
            //     // String roomId = chatRoomId(name, userMap!['name']);
            //     // Navigator.push(
            //     //     context,
            //     //     MaterialPageRoute(
            //     //         builder: (context) => ChatRoom(
            //     //             chatRoomId: roomId,
            //     //             userMap: userMap!,
            //     //             senderName: name)));
            //   },
            //   leading: CircleAvatar(
            //     child: Container(
            //       width: 20,
            //       height: 20,
            //     ),
            //     backgroundImage: NetworkImage(userMap!['imageUrl']),
            //   ),
            //   title: Text(
            //     userMap!['name'],
            //     style: TextStyle(
            //         color: Colors.black,
            //         fontSize: 17,
            //         fontWeight: FontWeight.w500),
            //   ),
            //   subtitle: Text(userMap!['bio']),
            //   trailing: Icon(
            //     Icons.chat,
            //     color: Colors.black,
            //   ),
            // ),
          ],
        )
    );
  }
}
