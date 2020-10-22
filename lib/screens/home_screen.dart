import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';

import 'package:flutter/material.dart';
import 'package:hostess/api/categories_api.dart';
import 'package:hostess/api/profile_api.dart';
import 'package:hostess/database/db_cart.dart';

import 'package:hostess/global/colors.dart';
import 'package:hostess/global/fade_route.dart';

import 'package:hostess/notifier/categories_notifier.dart';
import 'package:hostess/notifier/profile_notifier.dart';
import 'package:hostess/screens/cart_screen.dart';
import 'package:hostess/screens/details_screen.dart';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final String uid;
  final String address;

  HomeScreen({Key key, @required this.uid, this.address}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _isExist = 1;
  int _selectedIndex = 0;
  int _addressIndex = 0;
  int _total;
  bool _isClicked = false;
  String _language;
  final ScrollController _homeController = ScrollController();
  AnimationController _animationController;
  PageController _pageController;

  @override
  void initState() {
    _preLoad();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _pageController = PageController(
        initialPage: _addressIndex, keepPage: true, viewportFraction: 0.35);
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _preLoad() async {
    await FirebaseFirestore.instance
        .collection(widget.uid)
        .doc(widget.address)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          _isExist = 0;
        });
        _load();
        _isEmptyCart();
      } else {
        setState(() {
          _isExist = 2;
        });
      }
    });
  }

  _load() async {
    ProfileNotifier profileNotifier =
        Provider.of<ProfileNotifier>(context, listen: false);
    await getProfile(profileNotifier, widget.uid, widget.address);
    setState(() => _language = profileNotifier.profileList[0].subLanguages[0]);
    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context, listen: false);
    getCategories(categoriesNotifier, widget.uid, widget.address,
        profileNotifier.profileList[0].subLanguages[0]);
  }

  _isEmptyCart() async {
    int total = await MastersDatabaseProvider.db.calculateTotal();
    setState(() => _total = total);
  }

  @override
  Widget build(BuildContext context) {
    ProfileNotifier profileNotifier = Provider.of<ProfileNotifier>(context);

    CategoriesNotifier categoriesNotifier =
        Provider.of<CategoriesNotifier>(context);

    _onSelected(int index) {
      setState(() => _selectedIndex = index);
    }

    _launchMap(String openMap) async {
      String url =
          'https://www.google.com/maps/search/${Uri.encodeFull(openMap)}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    _makePhoneCall(String openPhone) async {
      if (await canLaunch(openPhone)) {
        await launch(openPhone);
      } else {
        throw 'Could not launch $openPhone';
      }
    }

    String _titleLanguage(String subLanguages) {
      switch (subLanguages) {
        case "ru":
          return "Русский";

          break;

        case "ua":
          return "Українська";

          break;

        default:
          return "English";

          break;
      }
    }

    _showLanguageDialog() {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text('Доступные языки'),
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount:
                          profileNotifier.profileList[0].subLanguages.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () {
                            if (_addressIndex != index) {
                              setState(() {
                                _addressIndex = index;
                                _language = profileNotifier
                                    .profileList[0].subLanguages[index];
                                _selectedIndex = 0;
                              });
                              getCategories(categoriesNotifier, widget.uid,
                                  widget.address, _language);
                              _pageController.jumpToPage(index);
                            }
                            Navigator.pop(context);
                          },
                          leading: Container(
                            width: 30,
                            height: 30,
                            child: Image.asset(
                                'assets/languages/${profileNotifier.profileList[0].subLanguages[index]}.png'),
                          ),
                          title: Text(
                            _titleLanguage(profileNotifier
                                .profileList[0].subLanguages[index]),
                          ),
                        );
                      }),
                ),
              ],
            );
          });
    }

    Widget _time() {
      DateTime date = DateTime.now();
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.access_time,
            color: Colors.white,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              profileNotifier.profileList[0].subTime[date.weekday - 1],
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      );
    }

    Widget _chip(int index) {
      return FilterChip(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        label: Text(
          categoriesNotifier.categoriesList[index].title,
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
        elevation:
            _selectedIndex != null && _selectedIndex == index ? 0.0 : 2.0,
        pressElevation: 0.0,
        onSelected: (bool value) {
          _onSelected(index);
        },
      );
    }

    Widget _price(subPrice) {
      List<String> splitRes = subPrice.split('#');
      String splitPrice = splitRes[1];
      return Text(
        splitPrice,
        style: TextStyle(
          color: t_primary,
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    Widget _menuItem(int index, DocumentSnapshot document) {
      return Container(
        color: c_background,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Container(
            height: 100,
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  FadeRoute(
                    page: FoodDetail(
                      imageHigh: document.data()['imageHigh'],
                      imageLow: document.data()['imageLow'],
                      title: document.data()['title'],
                      description: document.data()['description'],
                      subPrice: document.data()['subPrice'],
                    ),
                  ),
                );
                _isEmptyCart();
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 80,
                    height: 80,
                    child: Card(
                      semanticContainer: true,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: document.data()['imageLow'] != null
                          ? CachedNetworkImage(
                              imageUrl: document.data()['imageLow'],
                              fit: BoxFit.cover,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) => Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: CircularProgressIndicator(
                                    value: downloadProgress.progress,
                                    backgroundColor: c_background),
                              ),
                              errorWidget: (context, url, error) => Image.asset(
                                  'assets/placeholder_200.png',
                                  fit: BoxFit.cover),
                            )
                          : Image.asset('assets/placeholder_200.png',
                              fit: BoxFit.cover),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 2.0, 5.0, 2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            document.data()['title'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: t_primary,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            document.data()['description'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: t_secondary,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '₴',
                          style: TextStyle(
                            color: t_primary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2),
                        _price(document.data()['subPrice'][0]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget _setMenu() {
      return categoriesNotifier.categoriesList.isNotEmpty && _language != null
          ? StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(widget.uid)
                  .doc(widget.address)
                  .collection(_language)
                  .doc('Menu')
                  .collection(
                      categoriesNotifier.categoriesList[_selectedIndex].title)
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.only(
                      left: 25.0,
                      top: 0.0,
                      right: 30.0,
                      bottom: 20.0,
                    ),
                    itemCount: snapshot.data.documents.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return _menuItem(index, snapshot.data.documents[index]);
                    },
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 6)),
                );
              },
            )
          : Column(
              children: [
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
                  padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                  child: Text(
                    'Похоже меню на языке "$_language" всё ещё в разработке. Выберите другой язык!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: t_primary.withOpacity(0.5),
                      fontSize: 20.0,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
    }

    Widget _backSide() {
      return Stack(
        children: [
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
                        child: CircularProgressIndicator(
                            strokeWidth: 6, backgroundColor: c_background),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/placeholder_1024.png',
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset('assets/placeholder_1024.png', fit: BoxFit.cover),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.55,
            height: double.infinity,
            color: c_primary,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    '${profileNotifier.profileList[0].title}'.toUpperCase(),
                    maxLines: 3,
                    textAlign: TextAlign.left,
                    minFontSize: 25,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 35),
                  GestureDetector(
                    onTap: () => _launchMap(
                        profileNotifier.profileList[0].title +
                            ", " +
                            profileNotifier.profileList[0].address),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            profileNotifier.profileList[0].address,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  profileNotifier.profileList[0].phone.isNotEmpty
                      ? Column(
                          children: [
                            SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => _makePhoneCall(
                                  'tel:${profileNotifier.profileList[0].phone}'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      profileNotifier.profileList[0].phone,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : SizedBox(),
                  SizedBox(height: 20),
                  _time(),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget _langDots() {
      return _language != null
          ? GestureDetector(
              onTap: () => _showLanguageDialog(),
              child: SizedBox(
                width: 80,
                height: 30,
                child: PageView.builder(
                  itemCount: profileNotifier.profileList[0].subLanguages.length,
                  controller: _pageController,
                  onPageChanged: (int i) {
                    setState(() {
                      _addressIndex = i;
                      _language =
                          profileNotifier.profileList[0].subLanguages[i];
                      _selectedIndex = 0;
                    });
                    getCategories(categoriesNotifier, widget.uid,
                        widget.address, _language);
                  },
                  itemBuilder: (context, index) {
                    return Transform.scale(
                      scale: index == _addressIndex ? 1 : 0.8,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _addressIndex
                              ? c_accent
                              : c_secondary.withOpacity(0.5),
                        ),
                        child: Center(
                          child: Text(
                            profileNotifier.profileList[0].subLanguages[index]
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : SizedBox();
    }

    Widget _frontSide() {
      return Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              width: double.infinity,
              height: _isClicked
                  ? MediaQuery.of(context).size.height * 0.80
                  : 100.0,
              duration: Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                color: c_background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: CustomScrollView(
                physics: _isClicked ? null : NeverScrollableScrollPhysics(),
                controller: _homeController,
                slivers: <Widget>[
                  SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 25.0,
                                right: 25.0,
                                top: 40.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FloatingActionButton.extended(
                                    elevation: 0,
                                    focusElevation: 0,
                                    hoverElevation: 0,
                                    highlightElevation: 0,
                                    heroTag: 'menu',
                                    onPressed: () {
                                      setState(() {
                                        _isClicked = !_isClicked;
                                        _isClicked
                                            ? _animationController.forward()
                                            : _animationController.reverse();
                                      });
                                      if (_isClicked == false) {
                                        _homeController.animateTo(
                                          0.0,
                                          curve: Curves.easeOut,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        );
                                      }
                                    },
                                    icon: AnimatedIcon(
                                      icon: AnimatedIcons.menu_close,
                                      color: t_primary,
                                      progress: _animationController,
                                      size: 25,
                                    ),
                                    label: Text(
                                      'Меню',
                                      style: TextStyle(
                                        color: t_primary,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    backgroundColor: c_background,
                                  ),
                                  SizedBox(width: 16),
                                  _langDots(),
                                ],
                              ),
                            ),
                            Container(
                              height: 80,
                              child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24),
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      categoriesNotifier.categoriesList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: _chip(index),
                                    );
                                  }),
                            ),
                            _setMenu(),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
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
                  RawMaterialButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        FadeRoute(
                          page: CartScreen(),
                        ),
                      );
                      _isEmptyCart();
                    },
                    fillColor: c_secondary.withOpacity(.5),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        _total != null
                            ? Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: c_accent,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    padding: EdgeInsets.all(13.0),
                    shape: CircleBorder(),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    Widget _homeScreen() {
      return Scaffold(
        backgroundColor: c_secondary,
        body: profileNotifier.profileList.isNotEmpty
            ? Stack(
                children: <Widget>[
                  _backSide(),
                  _frontSide(),
                ],
              )
            : Center(child: CircularProgressIndicator(strokeWidth: 6)),
      );
    }

    Widget _setWidget() {
      if (_isExist == 0) {
        return _homeScreen();
      } else if (_isExist == 1) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(strokeWidth: 6),
          ),
        );
      } else {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                child: FlareActor(
                  "assets/rive/empty.flr",
                  alignment: Alignment.center,
                  fit: BoxFit.contain,
                  animation: "show",
                ),
              ),
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
                  'Похоже заведение которое вы ищите ещё не существует.',
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
