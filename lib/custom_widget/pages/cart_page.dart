import 'package:cached_network_image/cached_network_image.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:hostess/custom_widget/custom_container.dart';
import 'package:hostess/database/db_cart.dart';
import 'package:hostess/global/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hostess/notifier/cart_notifire.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartNotifier = Provider.of<CartNotifier>(context);

    _showDetailDialog(String title, String description, String amount) {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(title),
            titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
            contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
            children: <Widget>[
              Divider(),
              SizedBox(height: 10),
              Text(description),
              SizedBox(height: 15),
              Text(
                amount,
                style: TextStyle(
                  color: t_primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      );
    }

    Widget _orderList() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            reverse: true,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cartNotifier.cartList.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () {
                  _showDetailDialog(
                    cartNotifier.cartList[index].title,
                    cartNotifier.cartList[index].description,
                    cartNotifier.cartList[index].amount,
                  );
                  print(cartNotifier.cartList[index].id);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 22),
                  height: 120,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 85,
                        height: 85,
                        child: Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: cartNotifier.cartList[index].image != null
                              ? CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: cartNotifier.cartList[index].image,
                                  errorWidget: (context, url, error) =>
                                      Image.asset('assets/placeholder_200.png',
                                          fit: BoxFit.cover),
                                )
                              : Image.asset('assets/placeholder_200.png',
                                  fit: BoxFit.cover),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${cartNotifier.cartList[index].title}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: t_primary,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '₴',
                                    style: TextStyle(
                                      color: t_primary,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    "${cartNotifier.cartList[index].price}",
                                    style: TextStyle(
                                        color: t_primary,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      ButtonBar(
                        children: [
                          FlatButton(
                            onPressed: () {
                              MastersDatabaseProvider.db.deleteItemWithId(
                                  cartNotifier.cartList[index].id);
                              cartNotifier.deleteCartItem(
                                  cartNotifier.cartList[index].id);
                            },
                            child: Icon(Icons.remove_circle_outline),
                            padding: EdgeInsets.all(10.0),
                            shape: CircleBorder(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      );
    }

    return Scaffold(
      backgroundColor: c_primary,
      body: CustomContainer(
        title: 'Мой заказ',
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 110),
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        cartNotifier.totalPrice == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 235,
                                    height: 235,
                                    child: FlareActor(
                                      "assets/rive/empty.flr",
                                      alignment: Alignment.center,
                                      fit: BoxFit.contain,
                                      animation: "show",
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: const Text(
                                      'Ваш заказ пуст',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: t_primary,
                                        fontSize: 20.0,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      'Похоже вы еще ничего не добавили. Давайте это исправим!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: t_primary.withOpacity(0.5),
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : _orderList()
                      ],
                    ),
                  )
                ],
              ),
            ),
            cartNotifier.cartList.length > 0
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 25.0),
                    height: 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                "Итого:",
                                style: TextStyle(
                                  color: t_primary,
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 20.0),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      '₴',
                                      style: TextStyle(
                                          color: t_primary,
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(width: 3),
                                    Expanded(
                                      child: AutoSizeText(
                                        cartNotifier.totalPrice != null
                                            ? '${cartNotifier.totalPrice}'
                                            : '0',
                                        maxLines: 1,
                                        minFontSize: 20,
                                        style: TextStyle(
                                          color: t_primary,
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ButtonBar(
                          children: [
                            FlatButton(
                              onPressed: () {
                                MastersDatabaseProvider.db.deleteAllCart();
                                cartNotifier.getAllCart();
                              },
                              color: c_accent,
                              child: Icon(Icons.delete_forever),
                              padding: EdgeInsets.all(10.0),
                              shape: CircleBorder(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
