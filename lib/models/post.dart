/// Die "Post"-Klasse repräsentiert einen Post mit einer ID, Kategorie-ID, Titel und Inhalt.
class Post {
  /// Die eindeutige ID des Posts
  int id = 0;

  /// Die ID der Kategorie, zu der der Post gehört
  int categoryId = 0;

  /// Der Titel des Posts
  String title = "";

  /// Der Inhalt des Posts
  String body = "";

  /// Konstruktor der "Post"-Klasse.
  ///
  /// Erlaubt die Initialisierung eines Posts mit optionalen Parametern für ID, Kategorie-ID, Titel und Inhalt.
  /// Wenn keine Parameter übergeben werden, werden Standardwerte verwendet.
  Post({this.id = 0, this.categoryId = 0, this.title = "", this.body = ""});

  /// Fabrikmethode zum Erstellen eines "Post"-Objekts aus einem JSON-Objekt.
  ///
  /// [json]: Ein Map-Objekt, dass die Daten des Posts enthält.
  /// Gibt eine neue Instanz von "Post" zurück, die mit den Werten aus dem JSON-Objekt initialisiert wurde.
  /// Wirft die Exception weiter, z.B. bei einem Parsing Fehler. 
  factory Post.fromJson(Map<String, dynamic> json) {
    try {
      return Post(
        id: json['id'],
        categoryId: json['categoryId'],
        title: json['title'],
        body: json['body'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
