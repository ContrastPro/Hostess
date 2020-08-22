import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostess/models/food.dart';
import 'package:hostess/notifier/food_notifier.dart';

getFoods(FoodNotifier foodNotifier, String restaurant, String address,
    String category) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(restaurant)
      .doc(address)
      .collection('ru')
      .doc('Menu')
      .collection(category != null ? category : 'Рекомендуем')
      .get();

  List<Food> _foodList = [];

  snapshot.docs.forEach((element) {
    Food food = Food.fromMap(element.data());
    _foodList.add(food);
  });

  foodNotifier.foodList = _foodList;
}
