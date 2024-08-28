import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String name;
  final String uid;
  final String imageUrl;
  final bool isOnline;
  final String phone;
  final String password;
  final String bio;
  final List<String> groupId;

//<editor-fold desc="Data Methods">
  const UserData({
    required this.name,
    required this.uid,
    required this.imageUrl,
    required this.isOnline,
    required this.phone,
    required this.password,
    required this.bio,
    required this.groupId,
  });



  UserData copyWith({
    String? name,
    String? uid,
    String? imageUrl,
    bool? isOnline,
    String? phone,
    String? password,
    String? bio,
    List<String>? groupId,
  }) {
    return UserData(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      imageUrl: imageUrl ?? this.imageUrl,
      isOnline: isOnline ?? this.isOnline,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      bio: bio ?? this.bio,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'imageUrl': imageUrl,
      'isOnline': isOnline,
      'phone': phone,
      'password': password,
      'bio': bio,
      'groupId': groupId,
    };
  }

  factory UserData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserData(name: data['name']??'',
      uid: data['uid']??'',
      imageUrl: data['imageUrl']??'',
      isOnline: data['isOnline']??false,
      phone: data['phone']??'',
      password: data['password']??'',
      bio: data['bio']??'',
      groupId: List<String>.from(data['groupId']),
    );
  }

//</editor-fold>
}
