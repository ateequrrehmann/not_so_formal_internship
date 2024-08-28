import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class UserNotifier extends StateNotifier<UserData> {
  UserNotifier()
      : super(const UserData(
            name: '',
            uid: '',
            imageUrl: '',
            isOnline: true,
            phone: '',
            password: '',
            bio: '',
            groupId: []));

  void updateName(String n) {
    state = state.copyWith(name: n);
  }

  void updateUid(String u){
    state=state.copyWith(uid: u);
  }

  void updateImageUrl(String url){
    state=state.copyWith(imageUrl: url);
  }

  void updateIsOnline(bool i){
    state=state.copyWith(isOnline: i);
  }

  void updatePhone(String ph){
    print(ph);
    state=state.copyWith(phone: ph);
    print('Updated phone: ${state.phone}');
  }

  void updatePassword(String p){
    state=state.copyWith(password: p);
  }

  void updateBio(String b){
    state=state.copyWith(bio: b);
  }

  void updateGroupId(List<String> l){
    state=state.copyWith(groupId: l);
  }

}
