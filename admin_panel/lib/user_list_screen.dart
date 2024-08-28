import 'package:admin_panel/user_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      setState(() {
        users = snapshot.docs.map((doc) => {
          'id': doc.id,
          'data': doc.data()
        }).toList();
      });
    } catch (e) {
      print("Error occurred while fetching users: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      setState(() {
        users.removeWhere((user) => user['id'] == userId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      print("Error occurred while deleting user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index]['data'];
          final userId = users[index]['id'];
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsScreen(user: user),
                ),
              );
            },
            title: Text(user['name'] ?? 'No Name'),
            subtitle: Text(user['phone'] ?? 'No Phone'),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'delete') {
                  deleteUser(userId);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
