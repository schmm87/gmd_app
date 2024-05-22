import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/post.dart';

class FirebaseService {
  Future<List<Post>> getPosts(context) async {
    late List<Post> posts = [];
    var logger = Logger();

    try {
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref("posts");

      databaseReference.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        if (dataSnapshot.value != null) {
          final jsonList = jsonDecode(jsonEncode(dataSnapshot.value));
          posts = jsonList.map<Post>((e) => Post.fromJson(e)).toList();
        } else{        
          logger.e('API Zugriff fehlerhaft: keine Daten vorhanden.');
        }
      });
    } catch (e) {
      logger.e('API Zugriff fehlerhaft: $e');
    }

    if(posts.isEmpty)
    {
      posts.add(Post(
              title: "Herzlich Willkommen",
              body:
                  "In dieser App werden die News der Gemeinde Musterstadt angezeigt. Sie können verschiedene Kategorien abonnieren."));
    }

    return posts;
  }
}
