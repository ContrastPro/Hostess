import 'package:flutter/foundation.dart';

class TabNotifier with ChangeNotifier {
  int currentTab = 0;

  void changeTab(int newTab) {
    currentTab = newTab;
    notifyListeners();
  }
}
