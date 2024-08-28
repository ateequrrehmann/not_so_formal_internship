import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/future_provider/user_data_provider.dart';
import '../profile_screen/profile_screen.dart';
import '../registration_login/signin_screen.dart';
import 'bottom_navigation_bar/bottom_nav_bar.dart';
import 'home_page_navigation/articles_screen.dart';
import 'home_page_navigation/calendar_screen.dart';
import 'home_page_navigation/diet_screen.dart';
import 'home_page_navigation/exercises_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  String? userName;
  String? userPhone;
  String? userBio;
  String? imageUrl;
  var phone;
  String selectedTile = 'HOME';
  final FirebaseFirestore _firestore=FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeData();

  }
  Future<void> initializeData() async{
    await fetchData();
    await fetchUserInfo();
    await setStatus(true);
  }

  Future<void> setStatus(bool status)async{
    print('my phone $phone');
    await _firestore.collection('users').doc(phone).update({
      'isOnline': status
    });
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.resumed:
        setStatus(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        setStatus(false);
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('user_phone');
  }

  Future<void> fetchUserInfo() async {
    try {
      print(phone);
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(phone)
          .get();
      if (documentSnapshot.exists) {
        setState(() {
          userName = documentSnapshot.get('name');
          userPhone = documentSnapshot.get('phone');
          userBio = documentSnapshot.get('bio');
          imageUrl = documentSnapshot.get('imageUrl');
          print(imageUrl);
        });

        SharedPreferences prefs=await SharedPreferences.getInstance();
        prefs.setString('user_name', userName!);

      } else {
        print('No such document!');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EBEB),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFFE9EBEB),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {

              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  child: Container(
                    width: 320.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFFFFFFFF),
                    ),
                    child: Column(
                      children: const [
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_person, size: 40, color: Color(0xFFEC407A)),
                          ],
                        ),
                        SizedBox(height: 12.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Talk to Expert', style: TextStyle(fontSize: 14, color: Color(0xE5000000))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExerciseArticlesPage()),
                    );

                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Card(
                        child: Container(
                          width: 152.0,
                          height: 110.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: const Color(0xFFFFFFFF),
                          ),
                          child: Column(
                            children: const [
                              SizedBox(height: 25),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pregnant_woman, size: 30, color: Color(0xFFEC407A)),
                                ],
                              ),
                              SizedBox(height: 12.5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Exercise', style: TextStyle(fontSize: 14, color: Color(0xE5000000))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DietArticlesPage()),
                    );

                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Card(
                      child: Container(
                        width: 152.0,
                        height: 110.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: const Color(0xFFFFFFFF),
                        ),
                        child: Column(
                          children: const [
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.food_bank, size: 30, color: Color(0xFFEC407A)),
                              ],
                            ),
                            SizedBox(height: 12.5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Diet and Nutrition', style: TextStyle(fontSize: 14, color: Color(0xE5000000))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarScreen(phone: phone)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  child: Container(
                    width: 320.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFFFFFFFF),
                    ),
                    child: Column(
                      children: const [
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 50, color: Color(0xFFEC407A)),
                          ],
                        ),
                        SizedBox(height: 12.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Calendar', style: TextStyle(fontSize: 14, color: Color(0xE5000000))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArticlesPage()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Card(
                  child: Container(
                    width: 320.0,
                    height: 110.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: const Color(0xFFFFFFFF),
                    ),
                    child: Column(
                      children: const [
                        SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.article, size: 50, color: Color(0xFFEC407A)),
                          ],
                        ),
                        SizedBox(height: 12.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Articles', style: TextStyle(fontSize: 14, color: Color(0xE5000000))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Consumer(builder: (context, ref, child) {
        final data = ref.watch(userFirebaseProvider);
        return data.when(
          data: (userData) {
            return Drawer(
              elevation: 20.0,
              backgroundColor: const Color(0xFFE9EBEB),
              child: ListView(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color(0xFFEC407A),
                    ),
                    child: UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color(0xFFEC407A),
                      ),
                      accountName: Text(
                        userData.name,
                        style: const TextStyle(fontSize: 16),
                      ),
                      accountEmail: Text(
                        userData.phone,
                      ),
                      currentAccountPictureSize: const Size.square(40),
                      currentAccountPicture: CircleAvatar(
                        backgroundImage: userData.imageUrl != ''
                            ? NetworkImage(userData.imageUrl)
                            : const AssetImage('lib/assets/avatar.png') as ImageProvider,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: selectedTile=="HOME"?
                      Colors.grey:Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        title: const Text("H O M E"),
                        leading: const Icon(Icons.home),
                        onTap: () {
                          setState(() {
                            selectedTile="HOME";
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustomBottomNavigationBar(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: selectedTile=="PROFILE"?
                      Colors.grey:Colors.transparent,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: ListTile(
                        title: const Text("P R O F I L E"),
                        leading: const Icon(Icons.person),
                        onTap: () {
                          setState(() {
                            selectedTile="PROFILE";
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 350),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: ListTile(
                      title: const Text("L O G O U T"),
                      leading: const Icon(Icons.logout),
                      onTap: () {
                        setState(() {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>  Center(child: Text('Error loading user data $err')),
        );
      }),
    );
  }
}