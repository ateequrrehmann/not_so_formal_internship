import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/providers/future_provider/user_data_provider.dart';
import 'package:myapp/views/screens/main_screens/bottom_navigation_bar/bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_screens/home_screen.dart';
import '../registration_login/register_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final usersCollection = FirebaseFirestore.instance.collection('users');
  Uint8List? _image;
  String? imageUrl;
  String selectedTile = 'PROFILE';


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final data = ref.watch(userFirebaseProvider);
      return data.when(data: (user) {
        if(user.imageUrl != '' && user.imageUrl.isNotEmpty){
          print('image    ${user.imageUrl}');
        }
        print('fetched user data $user');
        return Scaffold(
          backgroundColor: const Color(0xFFE9EBEB),
          appBar: AppBar(
            title: const Text('Profile'),
          ),
          drawer: Drawer(
            elevation: 20.0,
            backgroundColor: const Color(0xFFE9EBEB),
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC407A),
                  ),
                  child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEC407A),
                    ),
                    accountName: Text(
                      user.name ,
                      style: const TextStyle(fontSize: 16),
                    ),
                    accountEmail: Text(
                      user.phone,
                    ),
                    currentAccountPictureSize: const Size.square(40),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: user.imageUrl != '' && user.imageUrl.isNotEmpty
                          ? NetworkImage('${user.imageUrl}')
                          : null,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: selectedTile=="HOME"?
                        Colors.grey:Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ListTile(
                      title: const Text("H O M E"),
                      leading: const Icon(Icons.home),
                      onTap: () {
                        setState(() {
                          selectedTile="HOME";
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomBottomNavigationBar(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: selectedTile=="PROFILE"?
                    Colors.grey:Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ListTile(
                      title: const Text("P R O F I L E"),
                      leading: const Icon(Icons.person),
                      onTap: () {
                        setState(() {
                          selectedTile="PROFILE";
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Container(
                //   decoration: BoxDecoration(
                //     color: selectedTile=="ORDERS"?
                //     Colors.grey:Colors.transparent,
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 10.0),
                //     child: ListTile(
                //       title: const Text("O R D E R S"),
                //       leading: const Icon(Icons.list),
                //       onTap: () {
                //         setState(() {
                //           selectedTile="ORDERS";
                //         });
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => OrderScreen(),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
                // Container(
                //   decoration: BoxDecoration(
                //     color: selectedTile=="HISTORY"?
                //     Colors.grey:Colors.transparent,
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 10.0),
                //     child: ListTile(
                //       title: const Text("O R D E R  H I S T O R Y"),
                //       leading: const Icon(Icons.history_outlined),
                //       onTap: () {
                //         setState(() {
                //           selectedTile="HISTORY";
                //         });
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => HistoryScreen(),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
                // Container(
                //   decoration: BoxDecoration(
                //     color: selectedTile=="USERLOCATION"?
                //     Colors.grey:Colors.transparent,
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 10.0),
                //     child: ListTile(
                //       title: const Text("U S E R  L O C A T I O N"),
                //       leading: const Icon(Icons.location_pin),
                //       onTap: () {
                //         setState(() {
                //           selectedTile="USERLOCATION";
                //         });
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => UserLocation(),
                //           ),
                //         );
                //       },
                //     ),
                //   ),
                // ),
                const SizedBox(height: 200),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: ListTile(
                    title: const Text("L O G O U T"),
                    leading: const Icon(Icons.logout),
                    onTap: () async {
                      SharedPreferences prefs=await SharedPreferences.getInstance();
                      prefs.setString('verification_id', 'null');
                      prefs.setString('user_phone', 'null');
                      FirebaseAuth.instance.signOut();
                      setState(()  {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()));
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          body: ListView(
            children: [
              const SizedBox(height: 50),
              Center(
                child: Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : user.imageUrl !=''  && user.imageUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 64,
                                backgroundImage:
                                    NetworkImage('${user.imageUrl}'),
                              )
                            : CircleAvatar(
                                radius: 64,
                                backgroundImage: NetworkImage('${user.imageUrl}'),
                              ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: () async {
                          Uint8List img = await pickImage(ImageSource.gallery);
                          setState(() {
                            _image = img;
                          });
                          await saveData(_image!, user.phone);
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.phone)
                              .update({'imageUrl': imageUrl});
                          ref.invalidate(userFirebaseProvider);
                        },
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: Text(
                  'My Details',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              buildDetailField('UserName', user.name, () async {
                String newValue = "";
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFFE9EBEB),
                    title: Text("Edit Name"),
                    content: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Enter new Name",
                      ),
                      onChanged: (value) {
                        newValue = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(newValue);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );

                if (newValue.trim().isNotEmpty) {
                  usersCollection
                      .doc(user.phone)
                      .update({'userName': newValue});
                  ref.invalidate(userFirebaseProvider);
                }
              }),
              buildDetailField('Phone', user.phone, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("can't change the phone number"),
                  ),
                );
              }),
              buildDetailField('Bio', user.bio, () async {
                String newValue = "";
                await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFFE9EBEB),
                  title: Text("Edit bio"),
                  content: TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Enter new bio",
                    ),
                    onChanged: (value) {
                      newValue = value;
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(newValue);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ));
                if (newValue.trim().isNotEmpty) {
                  usersCollection
                      .doc(user.phone)
                      .update({'bio': newValue});
                  ref.invalidate(userFirebaseProvider);
                }
              }),
              // buildDetailField('Email', user.phone, () async {
              //   String newValue = "";
              //   await showDialog(
              //       context: context,
              //       builder: (context) => AlertDialog(
              //         backgroundColor: const Color(0xFFE9EBEB),
              //         title: Text("Edit Email"),
              //         content: TextField(
              //           autofocus: true,
              //           decoration: InputDecoration(
              //             hintText: "Enter new Email",
              //           ),
              //           onChanged: (value) {
              //             newValue = value;
              //           },
              //         ),
              //         actions: [
              //           TextButton(
              //             onPressed: () => Navigator.pop(context),
              //             child: const Text('Cancel'),
              //           ),
              //           TextButton(
              //             onPressed: () {
              //               Navigator.of(context).pop(newValue);
              //             },
              //             child: const Text('Save'),
              //           ),
              //         ],
              //       ));
              //   if (newValue.trim().isNotEmpty) {
              //     usersCollection
              //         .doc(user.number)
              //         .update({'email': newValue});
              //     ref.invalidate(userFirebaseProvider);
              //
              //   }
              //
              // }),
            ],
          ),
        );
      }, error: (error, track) {
        return Center(child: Text('checking+$error'));
      }, loading: () {
        return Center(
          child: CircularProgressIndicator(),
        );
      });
    });
  }

  Widget buildDetailField(String label, String? value, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              IconButton(
                onPressed: onPressed,
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          Text(
            value ?? '',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }


  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    var file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No image selected"),
      ),
    );
  }

  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    Reference ref =
        FirebaseStorage.instance.ref().child(childName).child('ProfilePhoto');
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> saveData(Uint8List file, String phone) async {
    imageUrl = await uploadImageToStorage(phone, file);
  }
}
