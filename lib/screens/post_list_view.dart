import 'package:flutter/material.dart';
import 'package:gmd_app/screens/category_list_view.dart';
import 'package:provider/provider.dart';

import '../models/post.dart';
import '../providers/post_provider.dart';

class PostListView extends StatefulWidget {
  const PostListView({super.key, required this.title});

  static const routeName = '/';

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
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to the settings page. If the user leaves and returns
                // to the app after it has been killed while running in the
                // background, the navigation stack is restored.
                Navigator.restorablePushNamed(
                    context, CategoryListView.routeName);
              },
            ),
          ],
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
        final text = item.body.replaceAll('\\n', '\n');
        return Card(
          color: Theme.of(context).colorScheme.surface,
          child: Column(children: [
            ListTile(
              title: Text(item.title),
              subtitle: Text(text),
            ),
          ]),
        );
      },
    );
  }
}
