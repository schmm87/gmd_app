import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gmd_app/main.dart';
import 'package:logger/logger.dart';

import '../models/post.dart';
import '../services/api_service.dart';

class PostProvider with ChangeNotifier {
  late List<Post> posts = [];

  bool loading = false;
  ApiService apiService = ApiService();
  getData(context) async {
    loading = true;
    var logger = Logger();

    try {
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref("posts");

      databaseReference.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        refreshData(context, dataSnapshot);
      });
    } catch (e) {
      logger.e('API Zugriff fehlerhaft: $e');
    }
  }

  refreshData(context, DataSnapshot data) async {
    if (data.value != null) {
      final jsonList = jsonDecode(jsonEncode(data.value));
      posts = [];
      for(var json in jsonList)
      {
        if(json != null)
        {
          posts.add(Post.fromJson(json));
        }
      }

     // posts = jsonList.map<Post>((e) => Post.fromJson(e)).toList();
    } else {
      // logger.e('API Zugriff fehlerhaft: keine Daten vorhanden.');
    }

    if (posts.isEmpty) {
      posts.add(Post(
          title: "Herzlich Willkommen",
          body:
              "In dieser App werden die News der Gemeinde Musterstadt angezeigt. Sie können verschiedene Kategorien abonnieren."));
    }

    loading = false;
    notifyListeners();
  }
}
