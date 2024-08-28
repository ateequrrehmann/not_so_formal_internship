import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/message_models.dart';

class ChatService {
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  //send message

  Future<void> sendMessage(String receiverID, message) async {
    //get current user info
    String? userPhone;
    String? user_id;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone')!;
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(phone)
          .get();
      if (documentSnapshot.exists) {
        userPhone = documentSnapshot.get('phone');
        user_id = documentSnapshot.get('user_id');
      } else {
        print('No such document!');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }

    final Timestamp timestamp = Timestamp.now();

    //create a new message
    MessageModel newMessage = MessageModel(
        senderID: user_id!,
        senderPhone: userPhone!,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp);


    //construct chat room ID for the two users(sorted to ensure uniqueness)

    List<String> ids=[user_id, receiverID];
    ids.sort();

    String chatRoomID=ids.join('_');

    print('set $chatRoomID');

    //add message to database

    await _firestore.collection('chat_rooms').doc(chatRoomID).collection('messages').add(newMessage.toMap());



  }

//get message

  Stream<QuerySnapshot> getMessages(String userId, otherUserId){
    List<String> ids=[userId, otherUserId];
    ids.sort();
    String chatRoomID=ids.join('_');
    print('get $chatRoomID');

    return _firestore.collection('chat_rooms').doc(chatRoomID).collection('messages').orderBy('timeStamp', descending: false).snapshots();
  }
}