import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/global/fade_route.dart';
import 'package:hostess/screens/home_screen.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _isClicked = false;
  double myOpacity = 0;
  String _searchQuery = "";
  String _animationQr = "show";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  _showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: const Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );
    AlertDialog alert = AlertDialog(
      title: const Text('Упс...'),
      content: const Text('Похоже ваш QR код неверного формата :('),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _scanQR() async {
    var barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666",
        "Отмена",
        true,
        ScanMode.QR,
      );
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;

    if (barcodeScanRes.contains('#')) {
      List<String> splitRes = barcodeScanRes.split('#');
      Navigator.push(
        context,
        FadeRoute(
          page: HomeScreen(uid: splitRes[0], address: splitRes[1]),
        ),
      );
    } else {
      _showAlertDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildSearchField() {
      final border = OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(90.0)),
        borderSide: BorderSide(color: Colors.transparent),
      );

      return Theme(
        data: Theme.of(context).copyWith(
          cursorColor: c_accent,
          hintColor: Colors.transparent,
        ),
        child: TextFormField(
          decoration: InputDecoration(
            suffix: const SizedBox(width: 50),
            focusedBorder: border,
            border: border,
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            filled: true,
            hintText: 'Название заведения',
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
            fillColor: Colors.white.withOpacity(0.8),
          ),
          readOnly: _isClicked ? false : true,
          controller: _searchController,
          onChanged: (String value) {
            setState(() => _searchQuery = value.toLowerCase());
          },
        ),
      );
    }

    Widget _setScanSearch() {
      return SafeArea(
        child: AnimatedContainer(
          height: _isClicked ? MediaQuery.of(context).size.height * 0.25 : 80.0,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
          padding: const EdgeInsets.only(top: 20.0, left: 6, right: 6),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              AnimatedContainer(
                width: _isClicked ? MediaQuery.of(context).size.width : 60.0,
                duration: const Duration(seconds: 1),
                curve: Curves.fastOutSlowIn,
                child: _buildSearchField(),
                margin: const EdgeInsets.symmetric(horizontal: 14),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: RawMaterialButton(
                  onPressed: () {
                    setState(() => _isClicked = !_isClicked);
                    if (_isClicked == false) {
                      setState(() {
                        myOpacity = 0;
                        _searchQuery = "";
                        _animationQr = "scanning";
                      });
                      _searchController.clear();
                    } else {
                      setState(() => myOpacity = 1);
                    }
                  },
                  elevation: 2.0,
                  fillColor: Colors.white,
                  child: Icon(
                    _isClicked ? Icons.clear : Icons.search,
                    size: 30.0,
                  ),
                  padding: const EdgeInsets.all(15.0),
                  shape: const CircleBorder(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _setScan() {
      return Column(
        children: [
          SizedBox(height: 60),
          Container(
            width: 180,
            height: 180,
            child: FlareActor(
              "assets/rive/qrcode.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: _animationQr,
            ),
          ),
          SizedBox(height: 50.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Text(
              'Просканируйте Qr код',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t_primary,
                fontSize: 22.0,
                letterSpacing: 1.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
            child: Text(
              'Нажмите кнопку "Сканировать", наведите камеру на QR код и всё готово!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: t_primary.withOpacity(0.5),
                fontSize: 18.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      );
    }

    Widget _searchList() {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Global_Search')
            .where('subSearchKey', arrayContains: _searchQuery)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: const CircularProgressIndicator(),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(30),
            itemCount: snapshot.data.docs.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                color: c_background,
                child: ListTile(
                  title: Text(snapshot.data.docs[index].data()['title']),
                  subtitle: Text(snapshot.data.docs[index].data()['address']),
                  onTap: () {
                    List<String> splitRes =
                        snapshot.data.docs[index].data()['id'].split('#');
                    Navigator.push(
                      context,
                      FadeRoute(
                        page:
                            HomeScreen(uid: splitRes[0], address: splitRes[1]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }

    Widget _globalList() {
      return _isClicked == true
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Global_Search')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(30),
                  itemCount: snapshot.data.docs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      color: c_background,
                      child: ListTile(
                        title: Text(snapshot.data.docs[index].data()['title']),
                        subtitle:
                            Text(snapshot.data.docs[index].data()['address']),
                        onTap: () {
                          List<String> splitRes =
                              snapshot.data.docs[index].data()['id'].split('#');
                          Navigator.push(
                            context,
                            FadeRoute(
                              page: HomeScreen(
                                  uid: splitRes[0], address: splitRes[1]),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            )
          : SizedBox();
    }

    Widget _setSearch() {
      return Stack(
        children: [
          _isClicked == true
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: _searchQuery.isNotEmpty
                        ? SizedBox()
                        : CircularProgressIndicator(),
                  ),
                )
              : SizedBox(),
          _searchQuery.isNotEmpty ? _searchList() : _globalList(),
        ],
      );
    }

    return Scaffold(
      backgroundColor: c_primary,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedOpacity(
            child: Stack(
              children: [
                Image.asset(
                  'assets/login.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.40,
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
              ],
            ),
            opacity: myOpacity,
            duration: const Duration(seconds: 1),
          ),
          _setScanSearch(),
          AnimatedContainer(
            margin: EdgeInsets.only(
                top: _isClicked
                    ? MediaQuery.of(context).size.height * 0.35
                    : MediaQuery.of(context).size.height * 0.20),
            constraints: BoxConstraints.expand(
              height: double.infinity,
            ),
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
              color: c_background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0),
              ),
            ),
            child: AnimatedCrossFade(
              duration: const Duration(seconds: 1),
              firstChild: _setSearch(),
              secondChild: _setScan(),
              crossFadeState: _isClicked
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: _isClicked ? false : true,
        child: FloatingActionButton.extended(
          backgroundColor: c_secondary,
          onPressed: () => _scanQR(),
          icon: const Icon(Icons.camera_enhance),
          label: const Text(
            'СКАНИРОВАТЬ',
            style: TextStyle(color: Colors.white),
          ),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
