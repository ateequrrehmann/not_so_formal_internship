import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  final String senderName;

  const ChatRoom(
      {super.key,
        required this.chatRoomId,
        required this.userMap,
        required this.senderName});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? time;
  int status = 0;
  final FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  File? imageFile;

  // Map to keep track of playing state for each voice message
  Map<String, bool> _isPlayingMap = {};

  Future getImage() async {
    ImagePicker _picker = ImagePicker();
    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
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

    // Add document to Firestore with type 'img' and empty message
    await _firestore
        .collection('chatroom')
        .doc(widget.chatRoomId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": widget.senderName,
      "message": '',
      "type": "img",
      "status": '0',
      "docName": fileName,
      "time": FieldValue.serverTimestamp()
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child('userImages')
        .child('$fileName.jpg');

    try {
      // Try to upload the image
      var uploadTask = await ref.putFile(imageFile!);

      // Get the image URL if upload is successful
      String imageUrl = await uploadTask.ref.getDownloadURL();

      // Update the Firestore document with the image URL
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
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
          .collection('chatroom')
          .doc(widget.chatRoomId)
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
    _isPlayingMap = {};
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

  Future<void> initializeRecorder() async {
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _recorder.closeRecorder();
    super.dispose();
  }

  //getting the permission for mic
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

  void onSendVoice() async {
    await requestPermissions();

    if (_isRecording) {
      String? filePath = await _recorder.stopRecorder();

      if (filePath != null) {
        File voiceFile = File(filePath);
        String fileName = Uuid().v1();

        await _firestore
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(fileName)
            .set({
          "sendby": widget.senderName,
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
              .collection('chatroom')
              .doc(widget.chatRoomId)
              .collection('chats')
              .doc(fileName)
              .update({'message': voiceUrl});
          print(voiceUrl);
        } catch (error) {
          print('Voice upload failed: $error');
          await _firestore
              .collection('chatroom')
              .doc(widget.chatRoomId)
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

  void onSendMessage() async {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": widget.senderName,
        "message": _messageController.text,
        "type": "text",
        "time": FieldValue.serverTimestamp()
      };
      print('fasdfasdlfjasdlf ${widget.chatRoomId}');
      await _firestore.collection('chatroom').doc(widget.chatRoomId).set({
        'name': widget.chatRoomId
      });
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
      scrollDown();
      _messageController.clear();
    } else {
      print('enter some text');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9EBEB),
        title: StreamBuilder<DocumentSnapshot>(
          stream: _firestore
              .collection('users')
              .doc(widget.userMap['phone'])
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              print(widget.userMap['phone']);
              print(snapshot.data!['isOnline']);
              return Container(
                child: Column(
                  children: [
                    Text(widget.userMap['name']),
                    snapshot.data!['isOnline'] == true
                        ? Text(
                      'Online',
                      style: TextStyle(fontSize: 14),
                    )
                        : Text(
                      'Away',
                      style: TextStyle(fontSize: 14),
                    )
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> map = snapshot.data!.docs[index]
                              .data() as Map<String, dynamic>;
                          return messagesUI(
                              size, map, widget.senderName, context);
                        });
                  } else {
                    return Container();
                  }
                },
                stream: _firestore
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy('time', descending: false)
                    .snapshots(),
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

  Widget messagesUI(Size size, Map<String, dynamic> map, String senderName,
      BuildContext context) {
    // bool _isPlaying = false;
    return map['type'] == "text"
        ? Container(
      alignment: map['sendby'] == senderName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.7,
        ),
        child: IntrinsicWidth(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: map['sendby'] == senderName
                  ? Color(0xFFE91E63)
                  : Color(0xFFE4E4E4),
            ),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      map['message'],
                      style: TextStyle(
                        color: map['sendby'] == senderName
                            ? Colors.white
                            : Color(0xFF383737),
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    getMessageTime(map['time']),
                    style: TextStyle(
                      color: map['sendby'] == senderName
                          ? Colors.white
                          : Color(0xFF383737),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        : map['type'] == "img"
        ? Container(
      alignment: map['sendby'] == senderName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: size.width * 0.7,
        ),
        child: IntrinsicWidth(
            child: map['sendby'] != senderName
                ? InkWell(
              onTap: () async {
                if (map['status'] == '0') {
                  _firestore
                      .collection('chatroom')
                      .doc(widget.chatRoomId)
                      .collection('chats')
                      .doc(map['docName'])
                      .update({'status': '1'});
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ShowImage(
                              imageUrl: map['message'])));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Once viewed image '),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: map['sendby'] == senderName
                      ? Color(0xFFE91E63)
                      : Color(0xFFE4E4E4),
                ),
                padding: EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Photo',
                          style: TextStyle(
                            color: map['sendby'] == senderName
                                ? Colors.white
                                : Color(0xFF383737),
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        Icon(Icons.image)
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        getMessageTime(map['time']),
                        style: TextStyle(
                          color: map['sendby'] == senderName
                              ? Colors.white
                              : Color(0xFF383737),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: map['sendby'] == senderName
                    ? Color(0xFFE91E63)
                    : Color(0xFFE4E4E4),
              ),
              padding: EdgeInsets.symmetric(
                  vertical: 10, horizontal: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Photo',
                        style: TextStyle(
                          color: map['sendby'] == senderName
                              ? Colors.white
                              : Color(0xFF383737),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Icon(Icons.image)
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      getMessageTime(map['time']),
                      style: TextStyle(
                        color: map['sendby'] == senderName
                            ? Colors.white
                            : Color(0xFF383737),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    )
        : voiceMessageUI(size, map, senderName, context);
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






  Widget voiceMessageUI(Size size, Map<String, dynamic> map, String senderName, BuildContext context) {
    String messageId = map['docName'];
    bool isPlaying = _isPlayingMap[messageId] ?? false;

    return Container(
      width: size.width,
      alignment: map['sendby'] == senderName ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: map['sendby'] == senderName
              ? Color(0xFFE91E63)
              : Color(0xFFE4E4E4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice message',
              style: TextStyle(
                color: map['sendby'] == senderName
                    ? Colors.white
                    : Color(0xFF383737),
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: map['sendby'] == senderName
                    ? Colors.white
                    : Color(0xFF383737),
              ),
              onPressed: () => onPlayVoice(map['message'],  messageId),
            ),
            SizedBox(height: 5),
            Text(
              getMessageTime(map['time']),
              style: TextStyle(
                fontSize: 12,
                color: map['sendby'] == senderName
                    ? Colors.white
                    : Color(0xFF383737),
              ),
            ),
          ],
        ),
      ),
    );
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



