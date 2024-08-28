import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/views/screens/main_screens/chat_screens/group_chats/create_group/createGroup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddMemberInGroup extends StatefulWidget {
  const AddMemberInGroup({super.key});

  @override
  State<AddMemberInGroup> createState() => _AddMemberInGroupState();
}

class _AddMemberInGroupState extends State<AddMemberInGroup> {
  TextEditingController _searchController = TextEditingController();
  String phone = '';

  bool isLoading = false;
  List<Map<String, dynamic>> membersList = [];
  Map<String, dynamic>? userMap;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('user_phone')!;
    print(phone);
    print('my phone in group chat $phone');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchPhone();
    await getCurrentUserDetails();
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

  Future<void> getCurrentUserDetails() async {
    await _firestore.collection('users').doc(phone).get().then((map) {
      setState(() {
        membersList.add({
          "name": map['name'],
          'phone': map['phone'],
          'isOnline': map['isOnline'],
          'imageUrl': map['imageUrl'],
          'bio': map['bio'],
          'uid': map['uid'],
          'isAdmin': true
        });
      });
    });
  }

  void onResultTap(){

    bool isAlreadyExist=false;

    for(int i=0; i<membersList.length; i++){
      if(membersList[i]['phone']==userMap!['phone']){
        isAlreadyExist=true;
      }
    }
    if(!isAlreadyExist){
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          'phone': userMap!['phone'],
          'isOnline': userMap!['isOnline'],
          'imageUrl': userMap!['imageUrl'],
          'bio': userMap!['bio'],
          'uid': userMap!['uid'],
          'isAdmin': false
        });
        userMap=null;
        _searchController.clear();

      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User added Successfully'),
        ),
      );
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

  void onRemoveMembers(int index){
    if(membersList[index]['phone']!=phone){
      setState(() {
        membersList.remove(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ${membersList[index]['name']} removed Successfully'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: const Color(0xFFE9EBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EBEB),
        title: Text('Add Members'),
      ),
      body: Column(
        children: [
          Flexible(
              child: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Container(
                    width: 20,
                    height: 20,
                  ),
                  backgroundImage: NetworkImage(membersList[index]['imageUrl']),
                ),
                title: Text(
                  membersList[index]['name'],
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
                subtitle: Text(membersList[index]['bio']),
                trailing: GestureDetector(
                  onTap: ()=>onRemoveMembers(index),
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              );
            },
            itemCount: membersList.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          )),

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
                      hintText: "Name",
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
                    onTap: onResultTap,
                    child: Icon(
                      Icons.add,
                      color: Colors.black,
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
      floatingActionButton: membersList.length>=2? FloatingActionButton(
        child: Icon(Icons.forward),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreateGroup(membersList: membersList,)));
        },
      ):FloatingActionButton(onPressed: (){ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough members'),
        ),
      );}, child: Icon(Icons.forward),)
    );
  }
}
