import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ArticleDetail extends StatefulWidget {
  final String title;
  final Map<String, dynamic> details;
  const ArticleDetail({super.key, required this.title, required this.details});

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late Map<String, dynamic> _articleDetails;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _articleDetails = widget.details;
  }

  Future<String> _uploadImage(File image, String fileName) async {
    try {
      final storageRef = _storage.ref().child('default_images/$fileName');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _editImage(String field, int? subheadingIndex) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final fileName = pickedFile.name; // Get the file name
      try {
        String newImageUrl = await _uploadImage(File(pickedFile.path), fileName);
        setState(() {
          if (subheadingIndex == null) {
            _articleDetails[field] = newImageUrl;
          } else {
            _articleDetails['subheadings'][subheadingIndex][field] = newImageUrl;
          }
          _updateArticle(_articleDetails);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
      }
    }
  }

  Future<void> _updateArticle(Map<String, dynamic> updatedDetails) async {
    try {
      // Ensure the Firestore document path is correct
      await _firestore.collection(widget.title).doc(updatedDetails['id']).update(updatedDetails);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Article updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update article: $e')));
    }
  }

  Future<void> _editSection(String section, String initialValue) async {
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: initialValue);
        return AlertDialog(
          title: Text('Edit $section'),
          content: TextField(
            controller: controller,
            maxLines: section == 'description' ? 5 : 1,
            decoration: InputDecoration(
              hintText: 'Enter new $section',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (newValue != null) {
      setState(() {
        _articleDetails[section] = newValue;
        _updateArticle(_articleDetails);
      });
    }
  }

  Future<void> _editSubheading(String field, Map<String, dynamic> subheading) async {
    final newValue = await showDialog<String>(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController(text: subheading[field]);
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            maxLines: field == 'details' ? 5 : 1,
            decoration: InputDecoration(
              hintText: 'Enter new $field',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
    if (newValue != null) {
      setState(() {
        int index = _articleDetails['subheadings'].indexOf(subheading);
        _articleDetails['subheadings'][index][field] = newValue;
        _updateArticle(_articleDetails);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_articleDetails['title']),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Stack(
              children: [
                Center(child: Image.network(_articleDetails['imageUrl'])),
                Positioned(
                  right: 8.0,
                  bottom: 8.0,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: () => _editImage('imageUrl', null),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _articleDetails['title'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editSection('title', _articleDetails['title']),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _articleDetails['description'],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editSection('description', _articleDetails['description']),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Display and edit subheadings
            ..._articleDetails['subheadings'].map<Widget>((subheading) {
              int index = _articleDetails['subheadings'].indexOf(subheading);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subheading['title'],
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editSubheading('title', subheading),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: Text(subheading['details']),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editSubheading('details', subheading),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  if (subheading['imageUrl'] != null)
                    Stack(
                      children: [
                        Center(child: Image.network(subheading['imageUrl'])),
                        Positioned(
                          right: 8.0,
                          bottom: 8.0,
                          child: IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _editImage('imageUrl', index),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16.0),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
