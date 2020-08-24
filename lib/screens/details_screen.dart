import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hostess/database/db_cart.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/models/cart.dart';
import 'package:hostess/notifier/food_notifier.dart';
import 'package:hostess/widgets/appbar_item.dart';
import 'package:hostess/widgets/chip_ingredients_item.dart';
import 'package:provider/provider.dart';

class FoodDetail extends StatefulWidget {
  @override
  _FoodDetailState createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  int _selectedIndex = 0;
  String _price, _amount;

  @override
  void initState() {
    FoodNotifier foodNotifier =
        Provider.of<FoodNotifier>(context, listen: false);
    List<String> splitRes = foodNotifier.currentFood.subPrice[0].split('#');
    _price = splitRes[1];
    super.initState();
  }

  _addToCart(String image, String title, String price, String description,
      String amount) async {
    List<String> splitRes = amount.split('#');
    _amount = splitRes[0];
    await MastersDatabaseProvider.db.addItemToDatabaseCart(
      Cart(
        image: image,
        title: title,
        price: int.parse(_price),
        description: description,
        amount: _amount,
      ),
    );
  }

  _onSelected(int index, subPrice) {
    List<String> splitRes = subPrice.split('#');
    setState(() => {
          _selectedIndex = index,
          _price = splitRes[1],
        });
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

    Widget _chip(int index) {
      return FilterChip(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        label: Text(
          _amount,
          style: TextStyle(
            fontSize: 16.0,
            color: _selectedIndex != null && _selectedIndex == index
                ? c_background
                : t_primary.withOpacity(0.4),
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _selectedIndex != null && _selectedIndex == index
            ? c_primary
            : Colors.white.withOpacity(0),
        elevation: 0.0,
        pressElevation: 0.0,
        onSelected: (bool value) {
          _onSelected(
            index,
            foodNotifier.currentFood.subPrice[index],
          );
        },
      );
    }

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
                                _price,
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
                                    _price,
                                    foodNotifier.currentFood.description,
                                    foodNotifier
                                        .currentFood.subPrice[_selectedIndex],
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
                      SizedBox(height: 5),
                      Container(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: foodNotifier.currentFood.subPrice.length,
                          itemBuilder: (context, index) {
                            List<String> splitRes = foodNotifier
                                .currentFood.subPrice[index]
                                .split('#');
                            _amount = splitRes[0];
                            return _chip(index);
                          },
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              foodNotifier.currentFood.title,
                              style: TextStyle(
                                color: t_primary,
                                fontSize: 25.0,
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
                      SizedBox(height: 30),
                      foodNotifier.currentFood.subIngredients.isNotEmpty
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Ингредиенты',
                                style: TextStyle(
                                  color: t_primary,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Container(),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ChipItem(),
                      ),
                      SizedBox(height: 20),
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
