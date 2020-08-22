class Categories {
  String id;
  String title;

  Categories();

  Categories.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}
