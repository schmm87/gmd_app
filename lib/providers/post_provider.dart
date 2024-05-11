import 'package:flutter/material.dart';
import 'package:gmd_app/main.dart';

import '../models/post.dart';
import '../services/api_service.dart';

class PostProvider with ChangeNotifier {
  late List<Post> posts = [];

  bool loading = false;
  ApiService apiService = ApiService();
  getData(context) async {
    loading = true;
    posts = await apiService.getPosts(context);
    loading = false;

    notifyListeners();
  }
}
