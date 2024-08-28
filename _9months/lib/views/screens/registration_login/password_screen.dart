import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/user_model.dart';
import '../../../providers/state_notifier_provider/userProvider.dart';
import '../profile_screen/profile_screen.dart';

class PasswordScreen extends StatefulWidget {

  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isRePasswordVisible = false;

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
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      cursorColor: Colors.black,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.black,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPasswordVisible =
                                  !_isPasswordVisible; // Toggle visibility
                            });
                          },
                          child: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            // Change icon based on visibility
                            color: Colors.black,
                          ),
                        ),
                        labelText: "Enter Password",
                        labelStyle: TextStyle(
                          color: Colors.black.withOpacity(0.9),
                        ),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Color(0xFFFFFFFF),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    TextFormField(
                      controller: _rePasswordController,
                      obscureText: !_isRePasswordVisible,
                      enableSuggestions: false,
                      autocorrect: false,
                      cursorColor: Colors.black,
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.9),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.black,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isRePasswordVisible =
                                  !_isRePasswordVisible; // Toggle visibility
                            });
                          },
                          child: Icon(
                            _isRePasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            // Change icon based on visibility
                            color: Colors.black,
                          ),
                        ),
                        labelText: "Enter Password",
                        labelStyle: TextStyle(
                          color: Colors.black.withOpacity(0.9),
                        ),
                        filled: true,
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        fillColor: Color(0xFFFFFFFF),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                width: 0, style: BorderStyle.none)),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Consumer(builder: (context, ref, child) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Save the password to Firestore
                              if (_passwordController.text ==
                                  _rePasswordController.text) {
                                final username = ref.watch(
                                    userProvider.select((value) => value.name));
                                print(username);
                                final uid = ref.watch(
                                    userProvider.select((value) => value.uid));
                                print(uid);
                                final phone = ref.watch(userProvider
                                    .select((value) => value.phone));
                                print('after fetching value $phone');
                                var user = UserData(
                                    name: username,
                                    uid: uid,
                                    imageUrl:
                                        'https://firebasestorage.googleapis.com/v0/b/socioconnect-3a099.appspot.com/o/default_image%2Favatar.png?alt=media&token=e2db36dd-dce2-4866-9430-df320b1d66b4',
                                    isOnline: true,
                                    phone: phone,
                                    bio: 'Empty Bio',
                                    groupId: [],
                                    password: _passwordController.text);

                                print(phone);
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(phone)
                                    .set({
                                  'name': username,
                                  'uid': uid,
                                  'imageUrl':
                                  'https://firebasestorage.googleapis.com/v0/b/socioconnect-3a099.appspot.com/o/default_image%2Favatar.png?alt=media&token=e2db36dd-dce2-4866-9430-df320b1d66b4',
                                  'isOnline': true,
                                  'phone': phone,
                                  'bio': 'Empty Bio',
                                  'groupId': [],
                                  'password': _passwordController.text
                                });

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfilePage()));
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Both password must match"),
                                ));
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("These password must be empty"),
                                ),
                              );
                            }
                            // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OtpForm(phone: _phoneController.text)));
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFFEC407A)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          child: Text(
                            'Register',
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
            ],
          ),
        ),
      ),
    );
  }
}
