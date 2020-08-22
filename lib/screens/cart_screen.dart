import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hostess/database/db_cart.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/models/cart.dart';

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

  Widget _cartItem(int id, String image, String title, int price) {
    return Container(
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
              child: image != null
                  ? CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: image,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    )
                  : Image.asset('assets/placeholder_200.png',
                      fit: BoxFit.cover),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 10.0, 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "$title",
                    maxLines: 4,
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
                        "$price",
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
              MastersDatabaseProvider.db.deleteItemWithId(id);
              _calculateTotal();
            },
            fillColor: Colors.white,
            child: Icon(Icons.delete_outline),
            padding: EdgeInsets.all(10.0),
            shape: CircleBorder(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _total != null ? c_background : Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          FutureBuilder<List<Cart>>(
                            future: MastersDatabaseProvider.db.getAllCart(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Cart>> snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 20.0, horizontal: 20),
                                  reverse: true,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: snapshot.data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    Cart item = snapshot.data[index];
                                    return _cartItem(
                                      item.id,
                                      item.image,
                                      item.title,
                                      item.price,
                                    );
                                  },
                                );
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          ),
                        ],
                      ),
                      _total != null
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  25.0, 0.0, 25.0, 100.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      "Итого к оплате",
                                      style: TextStyle(
                                        color: t_primary,
                                        fontSize: 30.0,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '₴',
                                        style: TextStyle(
                                            color: t_primary,
                                            fontSize: 30.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(width: 3),
                                      Text(
                                        _total != null
                                            ? _total.toString()
                                            : '0',
                                        style: TextStyle(
                                            color: t_primary,
                                            fontSize: 30.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                Image.asset(
                                  'assets/empty_search.png',
                                  fit: BoxFit.cover,
                                ),
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
                                      20.0, 20.0, 20.0, 0.0),
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
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: RawMaterialButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                  padding: EdgeInsets.all(20.0),
                  child: Row(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
