  import 'dart:io';

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:intl/intl.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:uuid/uuid.dart';

  class GroupChatRoom extends StatefulWidget {
    final String groupChatId;
    final String groupName;
    const GroupChatRoom({super.key, required this.groupChatId, required this.groupName});

    @override
    State<GroupChatRoom> createState() => _GroupChatRoomState();
  }

  class _GroupChatRoomState extends State<GroupChatRoom> {
    final TextEditingController _messageController=TextEditingController();
    final FocusNode myFocusNode = FocusNode();
    final ScrollController _scrollController = ScrollController();
    final FirebaseFirestore _firestore=FirebaseFirestore.instance;

    // String? adminName;
    // String? adminPhone;
    //

    String? time;
    int status = 0;
    File? imageFile;

    // Future getImage() async {
    //   ImagePicker _picker = ImagePicker();
    //   await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
    //     if (xFile != null) {
    //       imageFile = File(xFile.path);
    //       // uploadImage();
    //     }
    //   });
    // }

    String getMessageDate(Timestamp dateTime) {
      DateTime date = dateTime.toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      return formattedDate;
    }

    String getMessageTime(Timestamp? dateTime) {
      if (dateTime == null) {
        return ''; // Return an empty string or a default value
      }
      DateTime date = dateTime.toDate();
      String formattedTime = DateFormat('hh:mm a').format(date);
      return formattedTime;
    }


    // Future uploadImage() async {
    //   String fileName = Uuid().v1();
    //
    //
    //   // Create the viewStatus map with all members initialized to false
    //   Map<String, bool> viewStatus = {};
    //
    //   // Fetch all members of the group
    //   await _firestore.collection('groups').doc(widget.groupChatId).collection('members').get().then((value) {
    //     value.docs.forEach((doc) {
    //       viewStatus[doc.id] = false; // Set each member's view status to false
    //     });
    //   });
    //
    //   // Add the initial document to Firestore with the viewStatus map
    //   await _firestore.collection('groups').doc(widget.groupChatId).collection('chats').doc(fileName).set({
    //     "sendby": adminName,
    //     "message": '',
    //     "type": "img",
    //     "status": '0',
    //     "docName": fileName,
    //     "time": FieldValue.serverTimestamp(),
    //     "viewStatus": viewStatus, // Add the viewStatus map to the document
    //   });
    //
    //   var ref = FirebaseStorage.instance
    //       .ref()
    //       .child('groupUserImages')
    //       .child('$fileName.jpg');
    //
    //   try {
    //     // Try to upload the image
    //     var uploadTask = await ref.putFile(imageFile!);
    //
    //     // Get the image URL if upload is successful
    //     String imageUrl = await uploadTask.ref.getDownloadURL();
    //
    //     // Update the Firestore document with the image URL
    //     await _firestore
    //         .collection('groups')
    //         .doc(widget.groupChatId)
    //         .collection('chats')
    //         .doc(fileName)
    //         .update({'message': imageUrl});
    //     print(imageUrl);
    //   } catch (error) {
    //     // Handle error without deleting the document
    //     print('Image upload failed: $error');
    //     status = 0;
    //
    //     // Optionally, update the document to indicate the failure
    //     await _firestore
    //         .collection('groups')
    //         .doc(widget.groupChatId)
    //         .collection('chats')
    //         .doc(fileName)
    //         .delete();
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Failed to send message'),
    //       ),
    //     );
    //   }
    //
    //   // Scroll down to show the new message
    //   scrollDown();
    // }



    void scrollDown() {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
        );
      }
    }

    @override
    void initState() {
      super.initState();
      // fetchData();
      print('group id,${widget.groupChatId}');
      myFocusNode.addListener(() {
        if (myFocusNode.hasFocus) {
          Future.delayed(
            Duration(milliseconds: 500),
                () => scrollDown(),
          );
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(milliseconds: 500), () => scrollDown());
      });
    }

    @override
    void dispose() {
      myFocusNode.dispose();
      _messageController.dispose();
      _scrollController.dispose();
      super.dispose();
    }


    // void fetchData() async{
    //   SharedPreferences prefs=await SharedPreferences.getInstance();
    //   adminName=prefs.getString('user_name');
    //   adminPhone=prefs.getString('user_phone');
    //   print(adminPhone);
    //   print(adminName);
    // }


    // void onSendMessage() async{
    //   if(_messageController.text.isNotEmpty){
    //     Map<String, dynamic> chatData={
    //       'sendby': adminName,
    //       'message': _messageController.text,
    //       'type':'text',
    //       'time': FieldValue.serverTimestamp(),
    //     };
    //     _messageController.clear();
    //     await _firestore.collection('groups').doc(widget.groupChatId).collection('chats').add(chatData);
    //   }
    // }

    @override
    Widget build(BuildContext context) {
      final Size size=MediaQuery.of(context).size;
      return Scaffold(
        backgroundColor: const Color(0xFFE9EBEB),

        appBar: AppBar(
          backgroundColor: const Color(0xFFE9EBEB),

          title: Text(widget.groupName),

        ),
        body: Column(
          children: [

            Expanded(
              child: SizedBox(
                height: size.height/1.27,
                width: size.width,
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('groups')
                      .doc(widget.groupChatId)
                      .collection('chats')
                      .orderBy('time')
                      .snapshots(),
                  builder: (context, snapshot) {


                    if (snapshot.hasData) {
                      var docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Center(child: Text('No messages yet.'));
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> chatMap = docs[index].data() as Map<String, dynamic>;

                          // Debugging output
                          print("Chat data at index $index: $chatMap");

                          return messageTile(size, chatMap);
                        },
                      );
                    }

                    return Container();
                  },
                ),


              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 50),
            //   child: Row(
            //     children: [
            //       Expanded(
            //         child: Padding(
            //           padding: const EdgeInsets.only(left: 8, right: 8),
            //           child: TextField(
            //             controller: _messageController,
            //             obscureText: false,
            //             enableSuggestions: false,
            //             focusNode: myFocusNode,
            //             autocorrect: false,
            //             cursorColor: Colors.black,
            //             style: TextStyle(
            //               color: Colors.black.withOpacity(0.9),
            //             ),
            //             decoration: InputDecoration(
            //               suffixIcon: Padding(
            //                 padding: const EdgeInsets.only(left: 5, right: 10),
            //                 child: Row(
            //                   mainAxisSize: MainAxisSize.min,
            //                   mainAxisAlignment: MainAxisAlignment.end,
            //                   children: [
            //                     GestureDetector(
            //                         onTap: getImage,
            //                         child: const Icon(Icons.photo_sharp)),
            //                     const SizedBox(
            //                       width: 5,
            //                     ),
            //                     GestureDetector(
            //                       onTap: onSendMessage,
            //                       child: const Icon(Icons.send),
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               hintText: "Send message",
            //               labelStyle: TextStyle(
            //                 color: Colors.black.withOpacity(0.9),
            //               ),
            //               filled: true,
            //               floatingLabelBehavior: FloatingLabelBehavior.never,
            //               fillColor: const Color(0xFFFFFFFF),
            //               border: OutlineInputBorder(
            //                 borderRadius: BorderRadius.circular(28.0),
            //                 borderSide: const BorderSide(
            //                   width: 0,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //       ),
            //       const SizedBox(
            //         width: 5,
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.only(right: 5),
            //         child: Container(
            //           decoration: BoxDecoration(
            //             color: const Color(0xFFE91E63),
            //             borderRadius: BorderRadius.circular(50),
            //           ),
            //           child: const IconButton(
            //             onPressed: null,
            //             icon: Icon(
            //               Icons.keyboard_voice,
            //               color: Colors.white,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // )

          ],
        ),
      );
    }

    Widget messageTile(Size size, Map<String, dynamic> chatMap){

      return Builder(builder: (_){
        if(chatMap['type']=='text'){
          return Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.7,
              ),
              child: IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFFE91E63)
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${chatMap['sendby']}',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      Text(
                        chatMap['message'],
                        style: TextStyle(
                          color:Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          getMessageTime(chatMap['time']),
                          style: TextStyle(
                            color:Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        else if (chatMap['type'] == 'img') {


          // String currentUserId = adminPhone!; // Replace with the actual user ID from your auth system
          // bool isViewed = chatMap['viewStatus'][currentUserId] == true;

          return Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: InkWell(
              onTap: () async {
                // Open the image in a new screen
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ShowImage(imageUrl: chatMap['message']),
                ));

                // Update Firestore to mark the image as viewed for this user
                // await _firestore.collection('groups')
                //     .doc(widget.groupChatId)
                //     .collection('chats')
                //     .doc(chatMap['docName'])
                //     .update({
                //   'viewStatus.$currentUserId': true // Mark this user's view status as true
                // });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color:Color(0xFFE91E63)
                ),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${chatMap['sendby']}',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Photo',
                          style: TextStyle(
                            color:Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.image)
                      ],
                    ),
                    Text(
                      getMessageTime(chatMap['time']),
                      style: TextStyle(
                        color:Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        else if(chatMap['type']=='notify'){
          return Container(
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.black38
              ),
              child: Text(
                chatMap['message'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ),
          );
        }
        else{
          return const SizedBox();
        }
      });
    }
  }


  class ShowImage extends StatelessWidget {
    final String imageUrl;

    const ShowImage({super.key, required this.imageUrl});

    @override
    Widget build(BuildContext context) {
      final Size size = MediaQuery.of(context).size;
      return Scaffold(
        body: Container(
          height: size.height,
          width: size.width,
          color: Colors.black,
          child: Image.network(imageUrl),
        ),
      );
    }
  }
