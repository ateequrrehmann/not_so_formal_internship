import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class NewArticle extends StatefulWidget {
  final String title;
  const NewArticle({super.key, required this.title});

  @override
  State<NewArticle> createState() => _NewArticleState();
}

class _NewArticleState extends State<NewArticle> {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _imageBytes;
  List<Map<String, dynamic>> _subheadings = [];

  Future<String> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '-' + imageFile.uri.pathSegments.last;
      Reference storageRef = _storage.ref().child('default_images/$fileName');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _pickImage(int index) async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _subheadings[index]['imageFile'] = File(pickedFile.path);
        _subheadings[index]['imageBytes'] = _subheadings[index]['imageFile']!.readAsBytesSync();
      });
    }
  }

  Future<void> _addArticle() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    try {
      String imageUrl = await _uploadImage(_imageFile!);

      List<Map<String, dynamic>> subheadingData = await Future.wait(
        _subheadings.map((subheading) async {
          if (subheading['imageFile'] != null) {
            String subheadingImageUrl = await _uploadImage(subheading['imageFile']!);
            subheading['imageUrl'] = subheadingImageUrl;
          }
          return {
            'title': subheading['title'],
            'details': subheading['details'],
            'imageUrl': subheading['imageUrl'],
          };
        }).toList(),
      );

      await _firestore.collection(widget.title).add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl,
        'subheadings': subheadingData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Article added successfully')),
      );

      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null;
        _imageBytes = null;
        _subheadings.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add article: $e')),
      );
    }
  }

  void _addSubheading() {
    setState(() {
      _subheadings.add({
        'title': '',
        'details': '',
        'imageFile': null,
        'imageBytes': null,
        'titleController': TextEditingController(),
        'detailsController': TextEditingController(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Article'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                    _imageBytes = _imageFile!.readAsBytesSync();
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!)
                    : Center(child: Text('Tap to select an image')),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 5,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _addSubheading,
              child: Text('Add Subheading'),
            ),
            SizedBox(height: 16.0),
            ListView.builder(
              itemCount: _subheadings.length,
              shrinkWrap: true, // Allows the ListView to take up only as much space as needed
              physics: NeverScrollableScrollPhysics(), // Disables scrolling in the ListView to allow for SingleChildScrollView to handle scrolling
              itemBuilder: (context, index) {
                final subheading = _subheadings[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: subheading['titleController'] as TextEditingController,
                          onChanged: (value) {
                            setState(() {
                              subheading['title'] = value;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Subheading Title'),
                        ),
                        SizedBox(height: 8.0),
                        TextField(
                          controller: subheading['detailsController'] as TextEditingController,
                          onChanged: (value) {
                            setState(() {
                              subheading['details'] = value;
                            });
                          },
                          decoration: InputDecoration(labelText: 'Subheading Details'),
                          maxLines: 3,
                        ),
                        SizedBox(height: 8.0),
                        GestureDetector(
                          onTap: () => _pickImage(index),
                          child: Container(
                            width: double.infinity,
                            height: 100,
                            color: Colors.grey[200],
                            child: subheading['imageBytes'] != null
                                ? Image.memory(subheading['imageBytes']!)
                                : Center(child: Text('Tap to select an image')),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _addArticle,
              child: Text('Add Article'),
            ),
          ],
        ),
      ),
    );
  }
}
