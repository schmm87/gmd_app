class Post {
  int id = 0;
  int userId = 0;
  String title = "";
  String body = "";

  Post({this.id = 0, this.userId = 0, this.title = "", this.body = ""});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}
