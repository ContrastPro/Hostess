import 'package:flutter/material.dart';

class Cart {
  int id, price;
  String image, title, description, amount;

  Cart({
    @required this.id,
    @required this.image,
    @required this.price,
    @required this.title,
    @required this.description,
    @required this.amount,
  });

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
