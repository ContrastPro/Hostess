import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:hostess/api/categories_api.dart';
import 'package:hostess/api/food_api.dart';

import 'package:hostess/global/colors.dart';

import 'package:hostess/notifier/categories_notifier.dart';
import 'package:hostess/notifier/food_notifier.dart';
import 'package:hostess/widgets/appbar_item.dart';

import 'package:hostess/widgets/menu_item.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String restaurant;
  final String address;

  HomeScreen({this.restaurant, this.address});

  @override
  _HomeScreenState createState() =>
      _HomeScreenState(restaurant: restaurant, address: address);
}

class _HomeScreenState extends State<HomeScreen> {
  final String restaurant;
  final String address;

  _HomeScreenState({this.restaurant, this.address});

  @override
  void initState() {
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);
    getCategories(categoriesNotifier, restaurant, address);

    FoodNotifier foodNotifier =
        Provider.of<FoodNotifier>(context, listen: false);
    getFoods(foodNotifier, restaurant, address, 'Рекомендуем');

    super.initState();
  }

  int _selectedIndex = 0;

  _onSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context);
    FoodNotifier foodNotifier = Provider.of<FoodNotifier>(context);

    Future<void> _refreshList(String category) async {
      getFoods(foodNotifier, restaurant, address, category);
    }

    return Scaffold(
      backgroundColor: c_secondary,
      body: Stack(
        children: <Widget>[
          CachedNetworkImage(
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            imageUrl:
                "https://scontent.fods1-1.fna.fbcdn.net/v/t1.0-9/29793576_1684370508325904_4507416152489590784_o.jpg?_nc_cat=104&_nc_sid=e3f864&_nc_ohc=fKoopbyia_MAX8uJk0w&_nc_ht=scontent.fods1-1.fna&oh=874f09b23ffce4e766f06456bcc2e55b&oe=5F512503",
            placeholder: (context, url) => Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 50.0),
                child: CircularProgressIndicator(strokeWidth: 10),
              ),
            ),
            errorWidget: (context, url, error) =>
                Image.asset('assets/placeholder_1024.png', fit: BoxFit.cover),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.55,
            height: double.infinity,
            color: c_primary,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 50.0, 10.0, 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    restaurant,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 18.0,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '12:00 - 23:00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: DraggableScrollableSheet(
              initialChildSize: 0.13,
              maxChildSize: 0.80,
              minChildSize: 0.13,
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
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: <Widget>[
                      SliverList(
                        delegate: SliverChildListDelegate(
                          <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30.0, right: 30.0, top: 40.0),
                                        child: Text(
                                          'Меню',
                                          style: TextStyle(
                                            color: t_primary,
                                            fontSize: 30.0,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 80,
                                  child: ListView.builder(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categoriesNotifier
                                        .categoriesList.length,
                                    itemBuilder: (context, index) => Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: FilterChip(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        label: Text(
                                          categoriesNotifier
                                              .categoriesList[index].title,
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            color: _selectedIndex != null &&
                                                    _selectedIndex == index
                                                ? c_background
                                                : t_primary.withOpacity(0.4),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        backgroundColor:
                                            _selectedIndex != null &&
                                                    _selectedIndex == index
                                                ? c_primary
                                                : Colors.white.withOpacity(0),
                                        elevation: 0.0,
                                        pressElevation: 0.0,
                                        onSelected: (bool value) {
                                          _onSelected(index);
                                          _refreshList(categoriesNotifier
                                              .categoriesList[index].title);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 100),
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              strokeWidth: 10)),
                                    ),
                                    ListView.builder(
                                      padding: EdgeInsets.only(
                                        left: 25.0,
                                        top: 0.0,
                                        right: 30.0,
                                        bottom: 20.0,
                                      ),
                                      itemCount: foodNotifier.foodList.length,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return Container(
                                          color: c_background,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5.0),
                                            child: MenuItem(
                                              index: index,
                                              title: foodNotifier
                                                  .foodList[index].title,
                                              image: foodNotifier
                                                  .foodList[index].imageLow,
                                              price: foodNotifier
                                                  .foodList[index].price,
                                              description: foodNotifier
                                                  .foodList[index].description,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          CustomAppBar(),
        ],
      ),
    );
  }
}
