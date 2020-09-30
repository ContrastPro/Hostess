import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hostess/models/categories.dart';
import 'package:hostess/notifier/categories_notifier.dart';

getCategories(CategoriesNotifier categoriesNotifier, String uid, String address,
    String language) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection(uid)
      .doc(address)
      .collection(language)
      .doc('Categories')
      .collection('Menu')
      .orderBy('createdAt', descending: false)
      .get();

  List<Categories> _categoriesList = [];

  snapshot.docs.forEach((element) {
    Categories food = Categories.fromMap(element.data());
    _categoriesList.add(food);
  });

  categoriesNotifier.categoriesList = _categoriesList;
}
