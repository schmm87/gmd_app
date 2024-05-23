/// Die "Category"-Klasse repräsentiert einen Category mit einer ID und Name
class Category {
  /// Die eindeutige ID der Category
  int id = 0;

  /// Der Name der Category
  String name = "";

  /// Konstruktor der "Category"-Klasse.
  ///
  /// Erlaubt die Initialisierung einer Category mit optionalen Parametern für ID und Name.
  /// Wenn keine Parameter übergeben werden, werden Standardwerte verwendet.
  Category({this.id = 0, this.name = "",});

  /// Fabrikmethode zum Erstellen eines "Category"-Objekts aus einem JSON-Objekt.
  ///
  /// [json]: Ein Map-Objekt, dass die Daten des Categorys enthält.
  /// Gibt eine neue Instanz von "Category" zurück, die mit den Werten aus dem JSON-Objekt initialisiert wurde.
  /// Wirft die Exception weiter, z.B. bei einem Parsing Fehler. 
  factory Category.fromJson(Map<String, dynamic> json) {
    try {
      return Category(
        id: json['id'],
        name: json['name'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
