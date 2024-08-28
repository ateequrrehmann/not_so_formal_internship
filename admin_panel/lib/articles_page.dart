import 'package:admin_panel/add_new_article.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'article_detail.dart';
class ArticlesPage extends StatefulWidget {
  final String title;
  const ArticlesPage({super.key, required this.title});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  final _firestore=FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final Size size=MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data != null) {
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        String docId = snapshot.data!.docs[index].id;
                        print(map);
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ArticleDetail(title: widget.title,details: map)));
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0), // Add spacing between cards
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image
                                Container(
                                  width: double.infinity,
                                  height: size.width * 0.4, // Set height to 40% of screen width
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                                    image: DecorationImage(
                                      image: NetworkImage(map['imageUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                // Title and Description
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        map['title'],
                                        style: Theme.of(context).textTheme.titleLarge,
                                        overflow: TextOverflow.visible, // Ensure title is fully visible
                                      ),
                                      SizedBox(height: 4.0),
                                      // Description
                                      Text(
                                        map['description'],
                                        style: Theme.of(context).textTheme.titleMedium,
                                        maxLines: 3, // Limit number of lines for description
                                        overflow: TextOverflow.ellipsis, // Handle overflow gracefully
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () async {
                                              try {
                                                await _firestore.collection(widget.title).doc(docId).delete();
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Article deleted successfully")));
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete article: $e")));
                                              }
                                            },
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                } else {
                  return Container();
                }
              },
              stream: _firestore
                  .collection(widget.title).snapshots()
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>NewArticle(title: widget.title)));
      }, child: Icon(Icons.add),),
    );
  }
}




