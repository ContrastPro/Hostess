class Food {
  String id;
  String title;
  String price;
  String description;
  String imageHigh;
  String imageLow;
  List subIngredients = [];

  Food();

  Food.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    title = data['title'];
    price = data['price'];
    description = data['description'];
    imageHigh = data['imageHigh'];
    imageLow = data['imageLow'];
    subIngredients = data['subIngredients'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'imageHigh': imageHigh,
      'imageLow': imageLow,
      'subIngredients': subIngredients,
    };
  }
}