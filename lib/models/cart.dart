class Cart {
  int id, price;
  String image, title, description, amount;

  Cart(
      {this.id,
      this.image,
      this.price,
      this.title,
      this.description,
      this.amount});

  Cart.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        image = map['image'],
        price = map['price'],
        title = map['title'],
        description = map['description'],
        amount = map['amount'];

  Map<String, dynamic> toMap() => {
        'id': id,
        'image': image,
        'price': price,
        'title': title,
        'description': description,
        'amount': amount,
      };
}
