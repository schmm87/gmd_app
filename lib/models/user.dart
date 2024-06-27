class MyUser {
  List<int> subscribedCategories = [];
  List<int> notifyCategories = [];
  String id;

  MyUser({required this.notifyCategories, required this.subscribedCategories, required this.id});

  factory MyUser.fromJson(Map<String, dynamic> json) {
    return MyUser(
      subscribedCategories: List<int>.from(json['subscribedCategories']??[]),
      notifyCategories: List<int>.from(json['notifyCategories']??[]),
      id: json['id'],
    );
  }
}