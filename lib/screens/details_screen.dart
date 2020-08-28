import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hostess/database/db_cart.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/models/cart.dart';
import 'package:hostess/screens/cart_screen.dart';

class FoodDetail extends StatefulWidget {
  final String id, restaurant, address, categories;

  FoodDetail({this.id, this.restaurant, this.address, this.categories});

  @override
  _FoodDetailState createState() =>
      _FoodDetailState(id, restaurant, address, categories);
}

class _FoodDetailState extends State<FoodDetail> {
  final String id, restaurant, address, categories;

  _FoodDetailState(this.id, this.restaurant, this.address, this.categories);

  int _selectedIndex = 0;
  String _price, _amount;

  _addToCart(String image, String title, String price, String description,
      String amount) async {
    List<String> splitRes = amount.split('#');
    _amount = splitRes[0];
    _price = splitRes[1];
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
        content: Text("Добавлено к текущему заказу!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference detailDish = FirebaseFirestore.instance
        .collection(restaurant)
        .doc(address)
        .collection('ru')
        .doc('Menu')
        .collection(categories);

    return FutureBuilder<DocumentSnapshot>(
      future: detailDish.doc(id).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data.data();

          if (_selectedIndex == 0) {
            List<String> splitRes = data['subPrice'][0].split('#');
            _price = splitRes[1];
          }
          _buildListIngredients() {
            List<Widget> choices = List();

            data['subIngredients'].forEach((ingredient) {
              choices.add(
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Chip(
                    padding: EdgeInsets.all(10),
                    backgroundColor: c_primary.withOpacity(0.2),
                    elevation: 0,
                    label: Text(
                      '$ingredient',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: t_primary.withOpacity(0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            });
            return choices;
          }

          return Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                color: c_background,
                height: MediaQuery.of(context).size.height * 0.80,
                child: data['imageHigh'] != null
                    ? CachedNetworkImage(
                        imageUrl: data['imageHigh'],
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress,
                              strokeWidth: 10),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/placeholder_1024.png',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset('assets/placeholder_1024.png',
                        fit: BoxFit.cover),
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
                  builder: (BuildContext context,
                      ScrollController scrollController) {
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
                        padding: EdgeInsets.symmetric(vertical: 30.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        '$_price',
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
                                        padding:
                                            const EdgeInsets.only(right: 26),
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
                                                'ЗАКАЗ',
                                                style: TextStyle(
                                                  color: t_primary,
                                                  fontSize: 13.0,
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
                                            data['imageLow'],
                                            data['title'],
                                            data['subPrice'][_selectedIndex],
                                            data['description'],
                                            data['subPrice'][_selectedIndex],
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
                            ),
                            SizedBox(height: 5),
                            Container(
                              height: 80,
                              child: ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 20.0),
                                scrollDirection: Axis.horizontal,
                                itemCount: data['subPrice'].length,
                                itemBuilder: (context, index) {
                                  List<String> splitRes =
                                      data['subPrice'][index].split('#');
                                  _amount = splitRes[0];
                                  return FilterChip(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    label: Text(
                                      '$_amount',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: _selectedIndex != null &&
                                                _selectedIndex == index
                                            ? c_background
                                            : t_primary.withOpacity(0.4),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: _selectedIndex != null &&
                                            _selectedIndex == index
                                        ? Colors.deepOrange[900]
                                        : Colors.white.withOpacity(0),
                                    elevation: 0.0,
                                    pressElevation: 0.0,
                                    onSelected: (bool value) {
                                      _onSelected(
                                        index,
                                        data['subPrice'][index],
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      '${data['title']}',
                                      style: TextStyle(
                                        color: t_primary,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.0),
                                child: Text(
                                  '${data['description']}',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                            data['subIngredients'].isNotEmpty
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 25.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Ингредиенты',
                                        style: TextStyle(
                                          color: t_primary,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.0),
                                child: Wrap(children: _buildListIngredients()),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      child: RawMaterialButton(
                        onPressed: () => Navigator.pop(context),
                        fillColor: c_secondary.withOpacity(0.5),
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(13.0),
                        shape: CircleBorder(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 20.0),
                      child: RawMaterialButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CartScreen(),
                            ),
                          );
                        },
                        fillColor: c_secondary.withOpacity(0.5),
                        child: Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(13.0),
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 10)));
      },
    );
  }
}
