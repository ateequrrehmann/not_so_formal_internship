import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:myapp/views/screens/registration_login/signin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/state_notifier_provider/userProvider.dart';
import 'opt_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String completePhoneNumber = '';
  final _formKey = GlobalKey<FormState>();
  bool _isPhoneValid = false;

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _dismissLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE9EBEB),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(30, 77, 30, 86),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: 100,
                  height: 100,
                  child: Image.asset('lib/assets/splashscreen.png')),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '9months',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w400),
                  ),

                ],
              ),
              SizedBox(
                height: 50,
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      obscureText: false,
                      enableSuggestions: false,
                      autocorrect: false,
                      cursorColor: Colors.black,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Name can't be empty";
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                      ),
                      decoration: InputDecoration(
                          suffixIcon: Icon(Icons.person_outline),
                          labelText: "Enter your name",
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.9),
                          ),
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          fillColor: Color(0xFFFFFFFF),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none))),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    IntlPhoneField(
                      controller: _phoneController,
                      initialCountryCode: 'PK',
                      onChanged: (phone) {
                        setState(() {
                          completePhoneNumber = phone.completeNumber;
                          _isPhoneValid = completePhoneNumber.isNotEmpty;
                        });
                      },
                      onCountryChanged: (country) {
                        print("+${country.dialCode}");
                      },
                      decoration: InputDecoration(
                          labelText: "XXXXXXXXXX",
                          labelStyle: TextStyle(
                            color: Colors.black.withOpacity(0.9),
                          ),
                          filled: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          fillColor: Color(0xFFFFFFFF),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                  width: 0, style: BorderStyle.none))),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Consumer(builder: (context, ref, child){
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate() && _isPhoneValid) {
                              ref.read(userProvider.notifier).updatePhone(completePhoneNumber);
                              ref.read(userProvider.notifier).updateName(_nameController.text);
                              print(completePhoneNumber);
                              final phoneNo = ref.watch(userProvider
                                  .select((value) => value.phone));
                              print('after fetching value $phoneNo dsfa');
                              _showLoadingDialog(context);
                              print(completePhoneNumber);
                              SharedPreferences prefs=await SharedPreferences.getInstance();
                              await prefs.setString('user_phone', completePhoneNumber);
                              await FirebaseAuth.instance.verifyPhoneNumber(
                                  phoneNumber: completePhoneNumber,
                                  verificationCompleted: (PhoneAuthCredential credential) {
                                    _dismissLoadingDialog(context);
                                  },
                                  verificationFailed: (FirebaseAuthException e) {
                                    _dismissLoadingDialog(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(e.message ?? 'Verification failed'),
                                      ),
                                    );
                                  },
                                  codeSent: (String verificationId, int? resendToken)async {
                                    _dismissLoadingDialog(context);
                                    SharedPreferences prefs=await SharedPreferences.getInstance();
                                    prefs.setString('verification_id', verificationId);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OtpForm()));
                                  },
                                  codeAutoRetrievalTimeout: (String verificationId) {
                                    _dismissLoadingDialog(context);
                                  }
                              );


                            } else {
                              if (!_isPhoneValid) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Phone number can't be empty"),
                                  ),
                                );
                              }
                            }
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFFEC407A)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)))),
                          child: Text(
                            'Next',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      );
                    }),

                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have account?",
                          style: TextStyle(color: Colors.black),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const SignInScreen()));
                            },
                            child: const Text(
                              " Login",
                              style: TextStyle(color: Color(0xFFEC407A)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
