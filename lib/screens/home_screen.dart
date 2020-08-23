import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:hostess/api/categories_api.dart';
import 'package:hostess/api/food_api.dart';
import 'package:hostess/api/profile_api.dart';

import 'package:hostess/global/colors.dart';

import 'package:hostess/notifier/categories_notifier.dart';
import 'package:hostess/notifier/food_notifier.dart';
import 'package:hostess/notifier/profile_notifier.dart';
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

  int _isExist = 1;
  int _selectedIndex = 0;

  @override
  void initState() {
    _load();
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);
    getCategories(categoriesNotifier, restaurant, address);

    FoodNotifier foodNotifier =
        Provider.of<FoodNotifier>(context, listen: false);
    getFoods(foodNotifier, restaurant, address, 'Рекомендуем');

    ProfileNotifier profileNotifier =
        Provider.of<ProfileNotifier>(context, listen: false);
    getProfile(profileNotifier, restaurant, address);
    super.initState();
  }

  Future<void> _load() async {
    await FirebaseFirestore.instance
        .collection(restaurant)
        .doc(address)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          _isExist = 0;
        });
      } else {
        setState(() {
          _isExist = 2;
        });
      }
    });
  }

  _onSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context);
    FoodNotifier foodNotifier = Provider.of<FoodNotifier>(context);

    ProfileNotifier profileNotifier = Provider.of<ProfileNotifier>(context);

    Future<void> _refreshList(String category) async {
      getFoods(foodNotifier, restaurant, address, category);
    }

    Widget _homeScreen() {
      return Scaffold(
        backgroundColor: c_secondary,
        body: Stack(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: double.infinity,
              child: profileNotifier.profileList[0].image != null
                  ? CachedNetworkImage(
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      imageUrl: profileNotifier.profileList[0].image,
                      placeholder: (context, url) => Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 50.0),
                          child: CircularProgressIndicator(strokeWidth: 10),
                        ),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                          'assets/placeholder_1024.png',
                          fit: BoxFit.cover),
                    )
                  : Image.asset('assets/placeholder_1024.png',
                      fit: BoxFit.cover),
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
                      profileNotifier.profileList[0].title,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    profileNotifier.profileList[0].time != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 18.0,
                              ),
                              SizedBox(width: 10),
                              Text(
                                profileNotifier.profileList[0].time,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          )
                        : Container(),
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
                builder: (context, scrollController) {
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
                                              left: 30.0,
                                              right: 30.0,
                                              top: 40.0),
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
                                        padding:
                                            const EdgeInsets.only(top: 100),
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
                                                price: foodNotifier
                                                    .foodList[index]
                                                    .subPrice[0],
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

    Widget _setWidget() {
      if (_isExist == 0) {
        return _homeScreen();
      } else if (_isExist == 1) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(strokeWidth: 10),
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/empty_search.png',
                fit: BoxFit.cover,
              ),
              SizedBox(height: 40.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Упс...',
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
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
                child: Text(
                  'Похоже заведение которое вы ищите ещё не существует :(',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: t_primary.withOpacity(0.5),
                    fontSize: 20.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 0.0),
                child: FloatingActionButton.extended(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: t_primary,
                  ),
                  label: Text(
                    'Вернуться назад',
                    style: TextStyle(
                      color: t_primary,
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  backgroundColor: c_background,
                ),
              ),
            ],
          ),
        );
      }
    }

    return _setWidget();
  }
}
