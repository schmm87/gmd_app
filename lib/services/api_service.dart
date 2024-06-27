import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../models/post.dart';

class ApiService {
  Future<List<Post>> getPosts(context) async {


    late List<Post> posts = [];
    var logger = Logger();
    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        posts = body.map<Post>((e)=> Post.fromJson(e)).toList();
        logger.i('API Daten erhalten. Count: ${posts.length}');
      } else {
        logger.e('API Zugriff fehlerhaft ${response.statusCode}');
      }
    } catch (e) {
      logger.e('API Zugriff fehlerhaft: $e');
    }
    return posts;
  }
}
