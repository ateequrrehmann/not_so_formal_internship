import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderID;
  final String senderPhone;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  MessageModel(
      {required this.senderID,
        required this.senderPhone,
      required this.receiverID,
      required this.message,
      required this.timestamp});


  Map<String, dynamic> toMap (){
    return {
      'senderID': senderID,
      'senderName': senderPhone,
      'receiverID': receiverID,
      'message': message,
      'timeStamp': timestamp
    };
  }
}
