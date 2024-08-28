  import 'dart:io';

  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_storage/firebase_storage.dart';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:intl/intl.dart';
  import 'package:myapp/views/screens/main_screens/chat_screens/group_chats/group_info.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:uuid/uuid.dart';
  import 'package:flutter_sound/public/flutter_sound_player.dart';
  import 'package:flutter_sound/public/flutter_sound_recorder.dart';
  import 'package:permission_handler/permission_handler.dart';




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

    final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
    bool _isRecording = false;
    Map<String, bool> _isPlayingMap = {};


    String? adminName;
    String? adminPhone;


    String? time;
    int status = 0;
    File? imageFile;


    Future<void> requestPermissions() async {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
      }
      status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }

    Future getImage() async {
      ImagePicker _picker = ImagePicker();
      await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
        if (xFile != null) {
          imageFile = File(xFile.path);
          uploadImage();
        }
      });
    }


    Future<void> initializeRecorder() async {
      await _recorder.openRecorder();
    }

    String getMessageDate(Timestamp dateTime) {
      DateTime date = dateTime.toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      return formattedDate;
    }


    void onSendVoice() async {
      await requestPermissions();

      if (_isRecording) {
        String? filePath = await _recorder.stopRecorder();

        if (filePath != null) {
          File voiceFile = File(filePath);
          String fileName = Uuid().v1();

          await _firestore
              .collection('groups')
              .doc(widget.groupChatId)
              .collection('chats')
              .doc(fileName)
              .set({
            "sendby": adminName,
            "message": '',
            "type": "voice",
            "docName": fileName,
            "time": FieldValue.serverTimestamp()
          });

          print('$fileName.aac');
          var ref = FirebaseStorage.instance
              .ref()
              .child('userVoices')
              .child('$fileName.aac');

          try {
            var uploadTask = await ref.putFile(voiceFile);

            String voiceUrl = await uploadTask.ref.getDownloadURL();
            print(voiceUrl);
            await _firestore
                .collection('groups')
                .doc(widget.groupChatId)
                .collection('chats')
                .doc(fileName)
                .update({'message': voiceUrl});
            print(voiceUrl);
          } catch (error) {
            print('Voice upload failed: $error');
            await _firestore
                .collection('groups')
                .doc(widget.groupChatId)
                .collection('chats')
                .doc(fileName)
                .delete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to send voice message'),
              ),
            );
          }

          setState(() {
            _isRecording = false;
          });

          scrollDown();
        } else {
          print('Failed to stop recorder or save the file');
        }
      } else {
        await _recorder.startRecorder(toFile: 'voice_${Uuid().v1()}.aac');
        setState(() {
          _isRecording = true;
        });
      }
    }


    String getMessageTime(Timestamp? dateTime) {
      if (dateTime == null) {
        return ''; // Return an empty string or a default value
      }
      DateTime date = dateTime.toDate();
      String formattedTime = DateFormat('hh:mm a').format(date);
      return formattedTime;
    }


    Future uploadImage() async {
      String fileName = Uuid().v1();


      // Create the viewStatus map with all members initialized to false
      Map<String, bool> viewStatus = {};

      // Fetch all members of the group
      await _firestore.collection('groups').doc(widget.groupChatId).collection('members').get().then((value) {
        value.docs.forEach((doc) {
          viewStatus[doc.id] = false; // Set each member's view status to false
        });
      });

      // Add the initial document to Firestore with the viewStatus map
      await _firestore.collection('groups').doc(widget.groupChatId).collection('chats').doc(fileName).set({
        "sendby": adminName,
        "message": '',
        "type": "img",
        "status": '0',
        "docName": fileName,
        "time": FieldValue.serverTimestamp(),
        "viewStatus": viewStatus, // Add the viewStatus map to the document
      });

      var ref = FirebaseStorage.instance
          .ref()
          .child('groupUserImages')
          .child('$fileName.jpg');

      try {
        // Try to upload the image
        var uploadTask = await ref.putFile(imageFile!);

        // Get the image URL if upload is successful
        String imageUrl = await uploadTask.ref.getDownloadURL();

        // Update the Firestore document with the image URL
        await _firestore
            .collection('groups')
            .doc(widget.groupChatId)
            .collection('chats')
            .doc(fileName)
            .update({'message': imageUrl});
        print(imageUrl);
      } catch (error) {
        // Handle error without deleting the document
        print('Image upload failed: $error');
        status = 0;

        // Optionally, update the document to indicate the failure
        await _firestore
            .collection('groups')
            .doc(widget.groupChatId)
            .collection('chats')
            .doc(fileName)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message'),
          ),
        );
      }

      // Scroll down to show the new message
      scrollDown();
    }



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
      fetchData();
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

      initializeRecorder();

    }

    @override
    void dispose() {
      myFocusNode.dispose();
      _messageController.dispose();
      _scrollController.dispose();
      _recorder.closeRecorder();
      super.dispose();
    }


    void fetchData() async{
      SharedPreferences prefs=await SharedPreferences.getInstance();
      adminName=prefs.getString('user_name');
      adminPhone=prefs.getString('user_phone');
      print(adminPhone);
      print(adminName);
    }


    void onSendMessage() async{
      if(_messageController.text.isNotEmpty){
        Map<String, dynamic> chatData={
          'sendby': adminName,
          'message': _messageController.text,
          'type':'text',
          'time': FieldValue.serverTimestamp(),
        };
        _messageController.clear();
        await _firestore.collection('groups').doc(widget.groupChatId).collection('chats').add(chatData);
      }
    }

    @override
    Widget build(BuildContext context) {
      final Size size=MediaQuery.of(context).size;
      return Scaffold(
        backgroundColor: const Color(0xFFE9EBEB),

        appBar: AppBar(
          backgroundColor: const Color(0xFFE9EBEB),

          title: Text(widget.groupName),
          actions: [
            IconButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>GroupInfo(groupName: widget.groupName, groupId: widget.groupChatId,)));}, icon: const Icon(Icons.more_vert)),
          ],
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
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextField(
                        controller: _messageController,
                        obscureText: false,
                        enableSuggestions: false,
                        focusNode: myFocusNode,
                        autocorrect: false,
                        cursorColor: Colors.black,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.9),
                        ),
                        decoration: InputDecoration(
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(left: 5, right: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                    onTap: getImage,
                                    child: Icon(Icons.photo_sharp)),
                                SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: onSendMessage,
                                  child: Icon(Icons.send),
                                ),
                              ],
                            ),
                          ),
                          hintText: "Send message",
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.9),
                          ),
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          fillColor: Color(0xFFFFFFFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28.0),
                            borderSide: const BorderSide(
                              width: 0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFE91E63),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: onSendVoice,
                        icon: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )

          ],
        ),
      );
    }

    Widget messageTile(Size size, Map<String, dynamic> chatMap){

      return Builder(builder: (_){
        if(chatMap['type']=='text'){
          return Container(
            alignment: chatMap['sendby'] == adminName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.7,
              ),
              child: IntrinsicWidth(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: chatMap['sendby'] == adminName
                        ? const Color(0xFFE91E63)
                        : const Color(0xFFE4E4E4),
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
                          color: chatMap['sendby'] == adminName
                              ? Colors.white
                              : Color(0xFF383737),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          getMessageTime(chatMap['time']),
                          style: TextStyle(
                            color: chatMap['sendby'] == adminName
                                ? Colors.white
                                : Color(0xFF383737),
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


          String currentUserId = adminPhone!; // Replace with the actual user ID from your auth system
          bool isViewed = chatMap['viewStatus'][currentUserId] == true;

          return Container(
            alignment: chatMap['sendby'] == adminName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            child: isViewed
                ? InkWell(
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Once viewed image '),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: chatMap['sendby'] == adminName
                      ? Color(0xFFE91E63)
                      : Color(0xFFE4E4E4),
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
                            color: chatMap['sendby'] == adminName
                                ? Colors.white
                                : Color(0xFF383737),
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
                        color: chatMap['sendby'] == adminName
                            ? Colors.white
                            : Color(0xFF383737),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : InkWell(
              onTap: () async {
                // Open the image in a new screen
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => ShowImage(imageUrl: chatMap['message']),
                ));

                // Update Firestore to mark the image as viewed for this user
                await _firestore.collection('groups')
                    .doc(widget.groupChatId)
                    .collection('chats')
                    .doc(chatMap['docName'])
                    .update({
                  'viewStatus.$currentUserId': true // Mark this user's view status as true
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: chatMap['sendby'] == adminName
                      ? Color(0xFFE91E63)
                      : Color(0xFFE4E4E4),
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
                            color: chatMap['sendby'] == adminName
                                ? Colors.white
                                : Color(0xFF383737),
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
                        color: chatMap['sendby'] == adminName
                            ? Colors.white
                            : Color(0xFF383737),
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
        else if(chatMap['type']=='voice'){
          String messageId = chatMap['docName'];
          bool isPlaying = _isPlayingMap[messageId] ?? false;
          return Container(
            width: size.width,
            alignment: chatMap['sendby'] == adminName ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: chatMap['sendby'] == adminName
                    ? Color(0xFFE91E63)
                    : Color(0xFFE4E4E4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice message',
                    style: TextStyle(
                      color: chatMap['sendby'] == adminName
                          ? Colors.white
                          : Color(0xFF383737),
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: chatMap['sendby'] == adminName
                          ? Colors.white
                          : Color(0xFF383737),
                    ),
                    onPressed: () => onPlayVoice(chatMap['message'],  adminName!),
                  ),
                  SizedBox(height: 5),
                  Text(
                    getMessageTime(chatMap['time']),
                    style: TextStyle(
                      fontSize: 12,
                      color: chatMap['sendby'] == adminName
                          ? Colors.white
                          : Color(0xFF383737),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        else{
          return const SizedBox();
        }
      });
    }
    Future<void> onPlayVoice(String url, String messageId) async {
      FlutterSoundPlayer player = FlutterSoundPlayer();
      await player.openPlayer();

      if (_isPlayingMap[messageId] == true) {
        print('helllllllllllllllllllllllss');
        await player.stopPlayer();
        setState(() {
          _isPlayingMap[messageId] = false;
        });
      } else {
        print('hellllllllllllllllladfasdfasdfadsfadsfaddfadllllllss');

        await player.startPlayer(fromURI: url);

        setState(() {
          _isPlayingMap[messageId] = true;
        });

        // Monitor the progress to detect when the playback finishes
        player.onProgress!.listen((event) {
          print('evenennnnnnnnnnnnnnnt');
          if (event.position >= event.duration) {
            setState(() {
              _isPlayingMap[messageId] = false;
            });
            player.stopPlayer(); // Stop the player when finished
          }
        });
      }
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
