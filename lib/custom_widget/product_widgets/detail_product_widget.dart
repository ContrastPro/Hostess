import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hostess/database/db_cart.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/model/cart.dart';

class FoodDetail extends StatefulWidget {
  final DocumentSnapshot document;

  FoodDetail({Key key, @required this.document}) : super(key: key);

  @override
  _FoodDetailState createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  int _selectedIndex = 0;
  String _price, _amount;

  @override
  void initState() {
    _preLoadPrice();
    super.initState();
  }

  _preLoadPrice() {
    List<String> splitRes = widget.document.data()['subPrice'][0].split('#');
    setState(() => _price = splitRes[1]);
  }

  _addToCart(String image, String title, String price, String description,
      String amount) async {
    List<String> splitRes = amount.split('#');
    _amount = splitRes[0];
    _price = splitRes[1];
    await MastersDatabaseProvider.db.addItemToDatabaseCart(Cart(
      image: image,
      title: title,
      price: int.parse(_price),
      description: description,
      amount: _amount,
    ));
  }

  _onSelected(int index, subPrice) {
    List<String> splitRes = subPrice.split('#');
    setState(() {
      _selectedIndex = index;
      _price = splitRes[1];
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          widget.document.data()['imageLow'] != null &&
                  widget.document.data()['imageHigh'] != null
              ? Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      color: c_background,
                      height: MediaQuery.of(context).size.height * 0.80,
                      child: CachedNetworkImage(
                        imageUrl: widget.document.data()['imageLow'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.80,
                      child: CachedNetworkImage(
                        imageUrl: widget.document.data()['imageHigh'],
                        fit: BoxFit.cover,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                            strokeWidth: 6,
                            backgroundColor: c_background,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Image.asset('assets/placeholder_1024.png', fit: BoxFit.cover),
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
              maxChildSize: 0.80,
              minChildSize: 0.25,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: c_background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          decoration: BoxDecoration(
                            color: c_primary,
                            borderRadius: BorderRadius.all(Radius.circular(90)),
                          ),
                          width: 40,
                          height: 3,
                        ),
                        alignment: Alignment.topCenter,
                      ),
                      SingleChildScrollView(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 50.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
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
                                            padding:
                                                const EdgeInsets.only(right: 5),
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
                                            widget.document.data()['imageLow'],
                                            widget.document.data()['title'],
                                            widget.document.data()['subPrice']
                                                [_selectedIndex],
                                            widget.document
                                                .data()['description'],
                                            widget.document.data()['subPrice']
                                                [_selectedIndex],
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    widget.document.data()['subPrice'].length,
                                itemBuilder: (context, index) {
                                  List<String> splitRes = widget.document
                                      .data()['subPrice'][index]
                                      .split('#');
                                  _amount = splitRes[0];
                                  return FilterChip(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
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
                                        ? c_accent
                                        : Colors.white.withOpacity(0),
                                    elevation: 0.0,
                                    pressElevation: 0.0,
                                    onSelected: (bool value) {
                                      if (_selectedIndex != index) {
                                        _onSelected(
                                          index,
                                          widget.document.data()['subPrice']
                                              [index],
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 15),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      widget.document.data()['title'],
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0),
                                child: Text(
                                  widget.document.data()['description'],
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlatButton(
                    onPressed: () => Navigator.pop(context),
                    color: c_secondary.withOpacity(0.5),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(13.0),
                    shape: CircleBorder(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
