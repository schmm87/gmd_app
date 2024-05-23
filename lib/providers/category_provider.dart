import 'dart:convert'; // Zum Dekodieren von JSON-Daten

import 'package:firebase_database/firebase_database.dart'; // Firebase Realtime Database
import 'package:flutter/material.dart'; // Flutter Material Design Komponenten
import 'package:logger/logger.dart'; // Logging-Bibliothek

import '../models/category.dart'; // Datenmodell für Category

/// Ein Provider für Category, der mit der ChangeNotifier-Klasse von Flutter arbeitet.
/// Er verwaltet eine Liste von Categorys, die aus der Firebase Realtime Database abgerufen werden.
class CategoryProvider with ChangeNotifier {
  /// Liste der Categorys, die angezeigt werden sollen
  late List<Category> categories = [];

  /// Gibt an, ob Daten gerade geladen werden
  bool loading = false;

  /// Logger-Instanz zum Protokollieren von Ereignissen und Fehlern
  var logger = Logger();

  /// Methode zum Abrufen der Daten aus der Firebase Realtime Database
  /// und zum Aktualisieren des Zustands bei Datenänderungen
  getData(context) async {
    loading = true; // Setze den Ladezustand auf true

    try {
      // Referenz zur "categories"-Datenbank
      // -> Die Kategorien des Users müssen in die Abfrage eingefügt werden oder nachträglich gefiltert werden
      // Optionen:
      //   Cloud-Functions - Komplex
      //   Filtern in der App
      //   Mehrere Calls und dann mergen
      DatabaseReference databaseReference =
          FirebaseDatabase.instance.ref("categories");

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

  /// Methode zur Aktualisierung der Daten durch notifyListeners.
  /// Wird aufgerufen, wenn die Realtime Database eine Änderung erhalten hat.
  ///
  /// [context]: Der Kontext, in dem die Methode aufgerufen wird
  /// [data]: Die Daten, die von der Realtime Database abgerufen wurden
  refreshData(context, DataSnapshot data) async {
    if (data.value != null) {
      final jsonList = jsonDecode(jsonEncode(data.value)) as List<dynamic>;
      // Aktuell wird bei jeder Änderung die gesamte Liste neu geladen -> Optimierungspotential
      categories = [];
      for (var json in jsonList) {
        if (json != null) {
          try {
            categories
                .add(Category.fromJson(json)); // Füge Category zur Liste hinzu
          } catch (e) {
            logger.e('fromJson von Category fehlerhaft: $e');
          }
        }
      }
    } else {
      // Logge Fehler bei fehlenden Daten
      logger.e('API Zugriff fehlerhaft: keine Daten vorhanden.');
    }

    // Füge einen Begrüssungscategory hinzu, wenn keine Categorys vorhanden sind
    if (categories.isEmpty) {
      categories.add(Category(
        name: "Default",
      ));
    }

    loading = false; // Setze den Ladezustand auf false
    notifyListeners(); // Benachrichtige alle Listener über Änderungen
  }
}
