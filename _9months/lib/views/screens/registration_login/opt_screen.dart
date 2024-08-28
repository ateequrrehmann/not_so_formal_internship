import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/views/screens/registration_login/password_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/user_model.dart';
import '../../../providers/state_notifier_provider/userProvider.dart';

class OtpForm extends StatefulWidget {
  const OtpForm({super.key});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var code;
  String phone='';
  bool isLoading = false; // Track the loading state
  final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.white),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.transparent),
      ));

  final focusedPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.white),
      decoration: BoxDecoration(
        color: Color(0xFFEC407A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.transparent),
      ));

  final submittedPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.white),
      decoration: BoxDecoration(
        color: Color(0xFFEC407A),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.transparent),
      ));

  Future<void> fetchData() async{
    SharedPreferences prefs=await SharedPreferences.getInstance();
    phone= prefs.getString('user_phone')!;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9EBEB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
        child: Container(
          margin: const EdgeInsets.only(top: 40),
          width: double.infinity,
          child: Column(
            children: [
              Text(
                'OTP Verification',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'Enter the code sent to your number',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: Text(
                  '$phone',
                  style: TextStyle(color: Color(0xFF7985F0), fontSize: 20),
                ),
              ),
              Pinput(
                length: 6,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                onCompleted: (pin) {
                  code = pin;
                },
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Text(
                  'I Didn\'t Receive a Code!',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Resend Code',
                  style: TextStyle(color: Color(0xFF7985F0), fontSize: 20),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Consumer(builder: (context, ref, child){
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      SharedPreferences prefs=await SharedPreferences.getInstance();
                      final verification_id=prefs.getString('verification_id');
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        PhoneAuthCredential credential = PhoneAuthProvider.credential(
                            verificationId: verification_id!, smsCode: code);
                        UserCredential usercredential=await auth.signInWithCredential(credential);
                        ref.read(userProvider.notifier).updateUid(usercredential.user!.uid);
                        // Save user details to Firestore
                        // var user=UserData(name: widget.name, uid: usercredential.user!.uid, imageUrl: 'lib/assets/avatar.png', isOnline: true, phone:widget.phone, bio: 'Empty Bio', groupId: [], password: '');
                        // await FirebaseFirestore.instance
                        //     .collection('users')
                        //     .doc(widget.phone)
                        //     .set({
                        //   'userName': widget.name,
                        //   'phone': widget.phone,
                        //   'Bio': 'Empty Bio',
                        //   'user_id': usercredential.user?.uid,
                        //   'imageUrl': 'lib/assets/avatar.png'
                        // });


                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PasswordScreen()));
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Invalid OTP"),
                          ),
                        );
                        print("wrong otp");
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFEC407A)),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)))),
                    child: isLoading
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      'Verify',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                );
              }),

            ],
          ),
        ),
      ),
    );
  }
}
