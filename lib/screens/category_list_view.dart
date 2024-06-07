import 'package:flutter/material.dart';
import 'package:gmd_app/models/category.dart';
import 'package:gmd_app/providers/category_provider.dart';
import 'package:provider/provider.dart';

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key, required this.title});

  static const routeName = '/categories';

  final String title;

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
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
        body: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            // If the loading it true then it will show the circular progressbar

            if (categoryProvider.loading ||
                categoryProvider.categories.isEmpty) {
              categoryProvider.getData(context);
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            // If loading is false then this code will show the list of todo item
            final categories = categoryProvider.categories;
            return buildPosts(categories, categoryProvider);
          },
        ));
  }

  ListView buildPosts(
      List<Category> categories, CategoryProvider categoryProvider) {
    return ListView.builder(
      // Providing a restorationId allows the ListView to restore the
      // scroll position when a user leaves and returns to the app after it
      // has been killed while running in the background.
      restorationId: 'postListView',
      itemCount: categories.length,
      itemBuilder: (BuildContext context, int index) {
        final item = categories[index];

        return Card(
          color: Theme.of(context).colorScheme.surface,
          child: Column(children: [
            ListTile(
              title: Text(item.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: categoryProvider.isSubscribed(item),
                    onChanged: (bool value) {
                      categoryProvider.toggleSubscription(item);
                    },
                    activeColor: Colors.green,
                  ),
                  IconButton(
                    icon: Icon(
                        categoryProvider.isNotify(item)
                            ? Icons.notifications
                            : Icons.notification_add_outlined,
                        color: categoryProvider.isNotify(item)
                            ? Colors.green
                            : Colors.grey),
                    onPressed: () {
                      categoryProvider.toggleNotify(item);
                    },
                  ),
                ],
              ),
            ),
          ]),
        );
      },
    );
  }
}
