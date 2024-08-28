import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:myapp/views/screens/registration_login/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_screens/bottom_navigation_bar/bottom_nav_bar.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  String completePhoneNumber = '';
  bool _isPhoneValid = false;
  String user_id='';






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
                              _isPasswordVisible = !_isPasswordVisible;  // Toggle visibility
                            });
                          },
                          child: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,  // Change icon based on visibility
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
                            borderSide: const BorderSide(width: 0, style: BorderStyle.none)
                        ),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      child: ElevatedButton(
                        onPressed: () async{
                          if (_formKey.currentState!.validate() &&
                              _isPhoneValid) {
                            print(completePhoneNumber);
                            // Check credentials in Firestore
                            final userDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(completePhoneNumber)
                                .get();
                              print(userDoc.exists);
                            if (userDoc.exists &&
                                userDoc.data()!['password'] ==
                                    _passwordController.text) {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              await prefs.setString('user_phone', completePhoneNumber);
                              print('hello');
                              //--->>>>must have to change it for later user
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CustomBottomNavigationBar()));

                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Invalid credentials"),
                                ),
                              );
                            }
                          } else {
                            if (!_isPhoneValid) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Phone number can't be empty"),
                                ),
                              );
                            }
                          }
                          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>OtpForm(phone: _phoneController.text)));
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFEC407A)),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)))),
                        child: Text(
                          'Login',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have account?",
                          style: TextStyle(color: Colors.black),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RegisterScreen()));
                            },
                            child: const Text(
                              " Sign Up",
                              style: TextStyle(
                                  color: Color(0xFFEC407A)),
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
