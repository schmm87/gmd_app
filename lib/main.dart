import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gmd_app/firebase_options.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'providers/post_provider.dart';
import 'screens/post_list_view.dart';

void main() async {
  var logger = Logger();

  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      logger.i("is WEB!");
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyDZM3DlTENDVan-VBQYnZZZsSHK7ruxe18",
              authDomain: "gmdapp-2fc8a.firebaseapp.com",
              databaseURL: "https://gmdapp-2fc8a-default-rtdb.europe-west1.firebasedatabase.app",
              projectId: "gmdapp-2fc8a",
              storageBucket: "gmdapp-2fc8a.appspot.com",
              messagingSenderId: "781400144376",
              appId: "1:781400144376:web:09b455d04c8fa1a1ef7e0d",
              measurementId: "G-NBM2HBW699"));
    } else {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    logger.i(Firebase.app().toString());
    logger.i(DefaultFirebaseOptions.currentPlatform.toString());
  } catch (e) {
    logger.e(e);
  }

  try {
    await FirebaseAuth.instance.signInAnonymously();
    logger.i("logged in");
  } catch (e) {
    logger.e(e);
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<PostProvider>(create: (_) => PostProvider())
    ],
    child: const MyApp(),
  ));
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
