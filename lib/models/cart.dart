class Cart {
  int id, price;
  String image, title, description;

  Cart({
    this.id,
    this.image,
    this.price,
    this.title,
    this.description,
  });

  Cart.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        image = map['image'],
        price = map['price'],
        title = map['title'],
        description = map['description'];

  Map<String, dynamic> toMap() => {
        'id': id,
        'image': image,
        'price': price,
        'title': title,
        'description': description,
      };
}
