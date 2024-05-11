import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<PostProvider>(create: (_) => PostProvider())
    ],
    child: const MyApp(),
  ));
}

//MODELS
class Post {
  int id = 0;
  int userId = 0;
  String title = "";
  String body = "";

  Post({this.id = 0, this.userId = 0, this.title = "", this.body = ""});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}

//SERVICE
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

//PROVIDER
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PostListView(title: 'Flutter Demo Home Page'),
    );
  }
}

class PostListView extends StatefulWidget {
  const PostListView({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Consumer<PostProvider>(
          builder: (context, value, child) {
            // If the loading it true then it will show the circular progressbar

            if (value.loading || value.posts.isEmpty) {
              value.getData(context);
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // If loading is false then this code will show the list of todo item
            final articles = value.posts;
            return buildPosts(articles, 1);
          },
        ));
  }

  ListView buildPosts(List<Post> posts, int categoryId) {
    return ListView.builder(
      // Providing a restorationId allows the ListView to restore the
      // scroll position when a user leaves and returns to the app after it
      // has been killed while running in the background.
      restorationId: 'postListView_$categoryId',
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        final item = posts[index];

        return Card(
          child: Column(children: [
            ListTile(
              title: Text(item.title),
              subtitle: Text(item.body),
            ),
          ]),
        );
      },
    );
  }
}
