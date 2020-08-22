import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:hostess/database/db_cart.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/models/cart.dart';
import 'package:hostess/notifier/food_notifier.dart';

import 'package:hostess/screens/cart_screen.dart';
import 'package:hostess/widgets/appbar_item.dart';
import 'package:hostess/widgets/chip_item.dart';
import 'package:provider/provider.dart';

class FoodDetail extends StatelessWidget {
  _addToCart(
      String image, String title, String price, String description) async {
    await MastersDatabaseProvider.db.addItemToDatabaseCart(
      Cart(
        image: image,
        title: title,
        price: int.parse(price),
        description: description,
      ),
    );
  }

  void _show(BuildContext context) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
        content: Text("Добавлено в корзину!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    FoodNotifier foodNotifier = Provider.of<FoodNotifier>(context);

    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          color: c_background,
          height: MediaQuery.of(context).size.height * 0.80,
          child: foodNotifier.currentFood.imageHigh != null
              ? CachedNetworkImage(
                  imageUrl: foodNotifier.currentFood.imageHigh,
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress, strokeWidth: 10),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/placeholder_1024.png',
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset('assets/placeholder_1024.png', fit: BoxFit.cover),
        ),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.80,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black.withAlpha(0),
                Colors.black12,
                Colors.black87,
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: DraggableScrollableSheet(
            initialChildSize: 0.55,
            maxChildSize: 0.70,
            minChildSize: 0.25,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: c_background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      EdgeInsets.symmetric(horizontal: 25.0, vertical: 30.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '₴',
                                style: TextStyle(
                                  color: t_primary,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                foodNotifier.currentFood.price,
                                style: TextStyle(
                                  color: t_primary,
                                  fontSize: 35.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Stack(
                            alignment: Alignment.centerRight,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 26),
                                child: Container(
                                  width: 100,
                                  height: 37,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: Center(
                                      child: Text(
                                        'КОРЗИНА',
                                        style: TextStyle(
                                          color: t_primary,
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              FloatingActionButton(
                                elevation: 0,
                                highlightElevation: 0,
                                onPressed: () {
                                  _addToCart(
                                    foodNotifier.currentFood.imageHigh,
                                    foodNotifier.currentFood.title,
                                    foodNotifier.currentFood.price,
                                    foodNotifier.currentFood.description,
                                  );
                                  _show(context);
                                },
                                child: Icon(Icons.add),
                                backgroundColor: c_primary,
                                mini: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              foodNotifier.currentFood.title,
                              style: TextStyle(
                                color: t_primary,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          foodNotifier.currentFood.description,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ChipItem(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        CustomAppBar(),
      ],
    );
  }
}
