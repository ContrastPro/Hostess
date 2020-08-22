import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostess/models/categories.dart';
import 'package:hostess/notifier/categories_notifier.dart';

getCategories(CategoriesNotifier categoriesNotifier, String restaurant,
    String address) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(restaurant)
      .doc(address)
      .collection('ru')
      .doc('Categories')
      .collection('Menu')
      .get();

  List<Categories> _categoriesList = [];

  snapshot.docs.forEach((element) {
    Categories food = Categories.fromMap(element.data());
    _categoriesList.add(food);
  });

  categoriesNotifier.categoriesList = _categoriesList;
}
