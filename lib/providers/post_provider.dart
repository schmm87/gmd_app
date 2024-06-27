import 'dart:convert'; // Zum Dekodieren von JSON-Daten

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:flutter/material.dart'; // Flutter Material Design Komponenten
import 'package:gmd_app/models/user.dart';
import 'package:logger/logger.dart'; // Logging-Bibliothek

import '../models/post.dart'; // Datenmodell für Post

/// Ein Provider für Posts, der mit der ChangeNotifier-Klasse von Flutter arbeitet.
/// Er verwaltet eine Liste von Posts, die aus der Firebase Realtime Database abgerufen werden.
class PostProvider with ChangeNotifier {
  /// Liste der Posts, die angezeigt werden sollen
  late List<Post> posts = [];
  late List<Post> allPosts = [];

  /// Gibt an, ob Daten gerade geladen werden
  bool loading = false;

  /// Logger-Instanz zum Protokollieren von Ereignissen und Fehlern
  var logger = Logger();
  final userUid = FirebaseAuth.instance.currentUser?.uid ?? 'default';
  List<int> subscribedCategories = [];

  /// Methode zum Abrufen der Daten aus der Firebase Realtime Database
  /// und zum Aktualisieren des Zustands bei Datenänderungen
  getData(context) async {
    loading = true; // Setze den Ladezustand auf true

    try {
      final databaseUserData = FirebaseDatabase.instance.ref("users/$userUid");

      // Listener für Änderungen in der Realtime Database
      databaseUserData.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        refreshUserData(
            context, dataSnapshot); // Aktualisiere die Daten bei Änderungen
      });

      // Referenz zur "posts"-Datenbank
      // -> Die Kategorien des Users müssen in die Abfrage eingefügt werden oder nachträglich gefiltert werden
      // Optionen:
      //   Cloud-Functions - Komplex
      //   Filtern in der App
      //   Mehrere Calls und dann mergen
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref("posts");

      // Listener für Änderungen in der Realtime Database
      databaseReference.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        refreshData(
            context, dataSnapshot); // Aktualisiere die Daten bei Änderungen
      });
    } catch (e) {
      // Logge Fehler bei Zugriff auf die API
      logger.e('API Zugriff fehlerhaft: $e');
    }
  }

  filterData() {
    
    posts = [];
    for (var post in allPosts) {
      if (subscribedCategories.contains((post.categoryId)) || post.categoryId == 0) {
        posts.add(post); // Füge Post zur Liste hinzu
      }
    }
    // Füge einen Begrüssungspost hinzu, wenn keine Posts vorhanden sind
    if (posts.isEmpty) {
      posts.add(Post(
          title: "Herzlich Willkommen",
          body:
              "In dieser App werden die News der Gemeinde Musterstadt angezeigt. Leider können aktuell keine Beiträge geladen werden. Wir bitten um Geduld."));
    }

    loading = false; // Setze den Ladezustand auf false
    notifyListeners(); // Benachrichtige alle Listener über Änderungen
  }

  refreshUserData(context, DataSnapshot data) async {
    loading = true; // Setze den Ladezustand auf true

    if (data.value != null) {
      final jsonUser =
          jsonDecode(jsonEncode(data.value)) as Map<String, dynamic>;

      MyUser user = MyUser.fromJson(jsonUser);
      subscribedCategories = user.subscribedCategories;
    }

    filterData();
  }

  /// Methode zur Aktualisierung der Daten durch notifyListeners.
  /// Wird aufgerufen, wenn die Realtime Database eine Änderung erhalten hat.
  ///
  /// [context]: Der Kontext, in dem die Methode aufgerufen wird
  /// [data]: Die Daten, die von der Realtime Database abgerufen wurden
  refreshData(context, DataSnapshot data) async {
    loading = true; // Setze den Ladezustand auf true

    if (data.value != null) {
      final jsonList = jsonDecode(jsonEncode(data.value)) as List<dynamic>;
      // Aktuell wird bei jeder Änderung die gesamte Liste neu geladen -> Optimierungspotential
      allPosts = [];
      for (var json in jsonList) {
        if (json != null) {
          try {
            allPosts.add(Post.fromJson(json)); // Füge Post zur Liste hinzu
          } catch (e) {
            logger.e('fromJson von Post fehlerhaft: $e');
          }
        }
      }
    } else {
      // Logge Fehler bei fehlenden Daten
      logger.e('API Zugriff fehlerhaft: keine Daten vorhanden.');
    }

    filterData();
  }
}
