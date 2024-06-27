import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gmd_app/firebase_options.dart';
import 'package:gmd_app/providers/category_provider.dart';
import 'package:gmd_app/screens/category_list_view.dart';
import 'package:gmd_app/services/fcm_service.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import 'providers/post_provider.dart';
import 'screens/post_list_view.dart';

void main() async {
  var logger = Logger();
  var fcmService = FCMService();

  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      logger.i("is WEB!");
      await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: "AIzaSyDZM3DlTENDVan-VBQYnZZZsSHK7ruxe18",
              authDomain: "gmdapp-2fc8a.firebaseapp.com",
              databaseURL:
                  "https://gmdapp-2fc8a-default-rtdb.europe-west1.firebasedatabase.app",
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

  //Initialisierung der Notification
  await fcmService.initializeFCM();

  //Entry Point für den Backgroundhandler installieren
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<PostProvider>(create: (_) => PostProvider()),
      ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider())
    ],
    child: const MyApp(),
  ));
}

///Entry Point für Messages von Firebase, während die App nicht im Vordergrund läuft.
///Dient aktuell eher dem Debugging, eventuell soll dies noch abgegriffen werden.
///Soll nach Anleitung nicht in einer Klasse platziert werden
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger logger = Logger();
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  logger.i("Handling a background message: ${message.messageId}");
  logger.i('Message data: ${message.data}');

  if (message.notification != null) {
    logger.i('Message also contained a notification: ${message.notification}');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final Color appBarColor = Color(0xFF0c5082);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: appBarColor),
        useMaterial3: true,
      ),
      //home: const PostListView(title: 'Flutter Demo Home Page'),
      onGenerateRoute: (RouteSettings routeSettings) {
        return MaterialPageRoute(builder: (BuildContext context) {
          switch (routeSettings.name) {
            case PostListView.routeName:
              return const PostListView(
                title: "News aus Ufhusen",
              );
            case CategoryListView.routeName:
              return const CategoryListView(
                title: "Kategorien",
              );
            default:
              return const PostListView(
                title: "News aus Ufhusen",
              );
          }
        });
      },
    );
  }
}
