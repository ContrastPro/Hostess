import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hostess/database/db_cart.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/models/cart.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _total;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  _calculateTotal() async {
    int total = await MastersDatabaseProvider.db.calculateTotal();
    setState(() => _total = total);
  }

  _showAlertDialog(String title, String description, String amount) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );
    AlertDialog alert = AlertDialog(
      scrollable: true,
      title: Text(title),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
      ),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _orderList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FutureBuilder<List<Cart>>(
          future: MastersDatabaseProvider.db.getAllCart(),
          builder: (BuildContext context, AsyncSnapshot<List<Cart>> snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                reverse: true,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Cart item = snapshot.data[index];

                  return InkWell(
                    onTap: () {
                      _showAlertDialog(
                        item.title,
                        item.description,
                        item.amount,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      height: 120,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: item.image != null
                                  ? CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: item.image,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              'assets/placeholder_200.png',
                                              fit: BoxFit.cover),
                                    )
                                  : Image.asset('assets/placeholder_200.png',
                                      fit: BoxFit.cover),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 5.0, 10.0, 5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${item.title}",
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
                                        "${item.price}",
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
                          RawMaterialButton(
                            onPressed: () {
                              MastersDatabaseProvider.db
                                  .deleteItemWithId(item.id);
                              _calculateTotal();
                            },
                            fillColor: Colors.white,
                            child: Icon(Icons.delete_outline),
                            padding: EdgeInsets.all(10.0),
                            shape: CircleBorder(),
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c_primary,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: _total != null ? c_background : Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 120),
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        _total != null
                            ? _orderList()
                            : Column(
                                children: [
                                  SizedBox(height: 40.0),
                                  Image.asset(
                                    'assets/empty_search.png',
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(height: 40.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Text(
                                      'Ваша корзина пуста',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: t_primary,
                                        fontSize: 25.0,
                                        letterSpacing: 1.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20.0, 10.0, 20.0, 0.0),
                                    child: Text(
                                      'Похоже вы еще ничего не добавили. Давайте это исправим!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: t_primary.withOpacity(0.5),
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RawMaterialButton(
                    onPressed: () => Navigator.pop(context),
                    fillColor: c_secondary.withOpacity(0.5),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(13.0),
                    shape: CircleBorder(),
                  ),
                  Row(
                    children: [
                      Text(
                        'Мой',
                        style: TextStyle(
                          color: t_primary,
                          fontSize: 30.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Заказ',
                        style: TextStyle(
                          color: t_primary,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.15,
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 10.0),
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
                              color: Colors.white,
                              fontSize: 30.0,
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
                                      color: Colors.white,
                                      fontSize: 30.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(width: 3),
                                Expanded(
                                  child: AutoSizeText(
                                    _total != null ? '$_total' : '0',
                                    maxLines: 1,
                                    minFontSize: 20,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30.0,
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
                    _total != null
                        ? RawMaterialButton(
                            onPressed: () {
                              MastersDatabaseProvider.db.deleteAllCart();
                              _calculateTotal();
                            },
                            fillColor: Colors.red[700],
                            child: Icon(
                              Icons.delete_forever,
                              color: c_background,
                            ),
                            padding: EdgeInsets.all(12.0),
                            shape: CircleBorder(),
                          )
                        : Container()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
