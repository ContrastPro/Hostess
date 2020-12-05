import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hostess/custom_widget/pages/cart_page.dart';
import 'package:hostess/custom_widget/pages/search_page.dart';
import 'package:hostess/custom_widget/pages/start_page.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/notifier/cart_notifire.dart';
import 'package:hostess/notifier/tab_notifire.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CupertinoTabController _controller = CupertinoTabController();

    final cartNotifier = Provider.of<CartNotifier>(context, listen: false);

    cartNotifier.getAllCart();

    return Consumer<TabNotifier>(
      builder: (context, tab, child) {
        return WillPopScope(
          onWillPop: () async {
            switch (tab.currentTab) {
              case 0:
                return true;
              case 1:
                tab.changeTab(0);
                _controller.index = 0;
                return false;
              case 2:
                tab.changeTab(1);
                _controller.index = 1;
                return false;
              default:
                return false;
            }
          },
          child: CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              onTap: (int index) => tab.changeTab(index),
              activeColor: c_secondary,
              backgroundColor: c_background,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.home)),
                BottomNavigationBarItem(icon: Icon(Icons.search)),
                BottomNavigationBarItem(
                  icon: Stack(
                    children: <Widget>[
                      Icon(Icons.shopping_cart),
                      Consumer<CartNotifier>(
                        builder: (context, cart, child) {
                          return cart.cartList.length > 0
                              ? Positioned(
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color: c_accent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    constraints: BoxConstraints(
                                      minWidth: 12,
                                      minHeight: 12,
                                    ),
                                    child: Text(
                                      '${cart.cartList.length}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : SizedBox();
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
            controller: _controller,
            tabBuilder: (context, index) {
              CupertinoTabView returnValue;
              switch (index) {
                case 0:
                  return CupertinoTabView(builder: (context) {
                    return CupertinoPageScaffold(
                      child: StartPage(),
                    );
                  });
                case 1:
                  return CupertinoTabView(builder: (context) {
                    return CupertinoPageScaffold(
                      child: SearchPage(),
                    );
                  });
                case 2:
                  return CupertinoTabView(builder: (context) {
                    return CupertinoPageScaffold(
                      child: CartPage(),
                    );
                  });
              }
              return returnValue;
            },
          ),
        );
      },
    );
  }
}
