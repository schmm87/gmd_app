import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  var logger = Logger();

  /// Initialisiert die Firebase Messaging Anbindung und die Benachrichtigung
  Future<void> initializeFCM() async {
    // Initialisierung von Firebase Messaging
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // iOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Erforderlich, um eine Heads-Up-Benachrichtigung anzuzeigen
      badge: true,
      sound: true,
    );

    logger.i('Benutzer hat Berechtigung erteilt: ${settings.authorizationStatus}');

    // Listener für Nachrichten, wenn die App im Vordergrund läuft
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logger.i('Nachricht im Vordergrund erhalten!');
      logger.i('Nachrichtendaten: ${message.data}');

      if (message.notification != null) {
        logger.i('Nachricht enthält auch eine Benachrichtigung: ${message.notification}');
        showNotification(message);
      }
    });

    // Channel für die Benachrichtigung, wenn die App im Hintergrund läuft
    createNotificationChannel();

    final fcmToken = await FirebaseMessaging.instance.getToken();
    logger.i('FCM Token: $fcmToken');
  }

  /// Channel für die Benachrichtigung in Android wird erstellt
  AndroidNotificationChannel createNotificationChannel() {
    // Channel für die Benachrichtigung, wenn die App im Hintergrund läuft
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // ID
      'High Importance Notifications', // Titel
      importance: Importance.max,
    );

    FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    return channel;
  }

  /// Funktion, um die Benachrichtigung auch anzuzeigen, wenn die App im Vordergrund läuft
  Future showNotification(RemoteMessage message) async {
    // Wir erstellen einen Android-Benachrichtigungskanal, der den Standard-FCM-Kanal überschreibt, um Heads-Up-Benachrichtigungen zu aktivieren.
    AndroidNotificationChannel channel = createNotificationChannel();

    // Dies wird verwendet, um die Benachrichtigung im Vordergrund anzuzeigen
    if (message.notification != null) {
      RemoteNotification? notification = message.notification;

      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: Importance.max,
        playSound: true,
        channelDescription: channel.description,
        priority: Priority.high,
        ongoing: true,
        color: Colors.deepOrangeAccent,
        styleInformation: const BigTextStyleInformation(''),
      );

      var iOSChannelSpecifics = const DarwinNotificationDetails();
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);

      await FlutterLocalNotificationsPlugin().show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        platformChannelSpecifics,
        payload: jsonEncode(message.data),
      );
    }
  }

  ///Themen werden abonniert
  ///
  Future<void> subscribeToCategory(String category)  async {
    await FirebaseMessaging.instance.subscribeToTopic(category);
  }
  ///Themen werden nicht mehr abonniert
  ///
  Future<void> unsubscribeToCategory(String category)  async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(category);
  }
}
