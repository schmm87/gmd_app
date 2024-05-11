import 'package:flutter/material.dart';
import 'package:gmd_app/main.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/post_provider.dart';

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