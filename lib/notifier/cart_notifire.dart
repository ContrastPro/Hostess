import 'package:flutter/foundation.dart';
import 'package:hostess/database/db_cart.dart';
import 'package:hostess/model/cart.dart';

class CartNotifier with ChangeNotifier {
  int totalPrice;
  List<Cart> cartList = [];

  Future<List<Cart>> getAllCart() async {
    cartList = await MastersDatabaseProvider.db.getAllCart();
    await _calculateTotal();
    notifyListeners();
    print('GET ALL CART');
    return cartList;
  }

  Future<void> deleteCartItem(int indexId) async {
    cartList.removeWhere((element) => element.id == indexId);
    await _calculateTotal();
    print('DELETE CART ITEM');
    notifyListeners();
  }

  Future<void> _calculateTotal() async {
    totalPrice = await MastersDatabaseProvider.db.calculateTotal();
    notifyListeners();
  }
}
