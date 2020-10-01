import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/screens/home_screen.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  bool _scan = false;
  bool _isClicked = false;
  double myOpacity = 0;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
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
      String _restaurant = splitRes[0];
      String _address = splitRes[1];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(uid: _restaurant, address: _address),
        ),
      );
    } else {
      _showAlertDialog(context);
    }
  }

  _testScanQR() async {
    var barcodeScanRes;
    if (_scan == false) {
      barcodeScanRes = 'zY31D7xo2pQWXjAkQz2L6NOnIkR2#iOACZRNjMVD6ISDm6zjd';
    } else {
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
    }

    if (barcodeScanRes.contains('#')) {
      List<String> splitRes = barcodeScanRes.split('#');
      String _restaurant = splitRes[0];
      String _address = splitRes[1];
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(uid: _restaurant, address: _address),
        ),
      );
    } else {
      _showAlertDialog(context);
    }
  }

  _testDialog(BuildContext context) {
    Widget cancelButton = FlatButton(
      child: Text("Тестовые"),
      onPressed: () {
        setState(() {
          _scan = false;
        });
        Navigator.of(context).pop();
        _testScanQR();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Сканировать"),
      onPressed: () {
        setState(() {
          _scan = true;
        });
        Navigator.of(context).pop();
        _testScanQR();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Для разработчиков"),
      content: Text("Выберите действие"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.of(context).pop(),
    );
    AlertDialog alert = AlertDialog(
      title: Text('Упс...'),
      content: Text('Похоже ваш QR код неверного формата :('),
      actions: [okButton],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildSearchField() {
      final border = OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(90.0)),
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      );

      return Theme(
        data: Theme.of(context).copyWith(
          cursorColor: Colors.redAccent,
          hintColor: Colors.transparent,
        ),
        child: TextFormField(
          decoration: InputDecoration(
            focusedBorder: border,
            border: border,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            filled: true,
            hintText: 'Название заведения',
            hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
            fillColor: Colors.white.withOpacity(0.8),
            /*helperText: 'Например: ',
            helperStyle: TextStyle(color: Colors.white.withOpacity(0.8)),*/
          ),
          controller: _searchController,
          onChanged: (String value) {
            setState(() => _searchQuery = value);
          },
        ),
      );
    }

    Widget _setScanSearch() {
      return AnimatedContainer(
        height: _isClicked ? MediaQuery.of(context).size.height * 0.25 : 100.0,
        duration: Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            AnimatedContainer(
              width: _isClicked ? MediaQuery.of(context).size.width : 60.0,
              duration: Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              child: _buildSearchField(),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  setState(() => _isClicked = !_isClicked);
                  if (_isClicked == false) {
                    setState(() {
                      myOpacity = 0.0;
                      _searchQuery = "";
                    });
                    _searchController.clear();
                  } else {
                    setState(() => myOpacity = 1.0);
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  child: Image.asset('assets/en.png'),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _setScan() {
      return Column(
        children: [
          SizedBox(height: 100),
          CircleAvatar(
            radius: 80,
            backgroundColor: c_background,
            backgroundImage: AssetImage('assets/qrcode.png'),
          ),
          SizedBox(height: 50.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 80.0, 20.0, 0.0),
            child: FloatingActionButton.extended(
              elevation: 2,
              focusElevation: 4,
              hoverElevation: 4,
              highlightElevation: 8,
              /*onPressed: () => _scanQR(),*/
              onPressed: () => _testDialog(context),
              icon: Icon(
                Icons.camera_enhance,
                color: t_primary,
              ),
              label: Text(
                'Сканировать',
                style: TextStyle(
                  color: t_primary,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: c_background,
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
          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');

          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(30),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data.docs[index].data()['title']),
                  subtitle: Text(snapshot.data.docs[index].data()['address']),
                );
              },
            );
          }

          return Center(child: CircularProgressIndicator(strokeWidth: 6));
        },
      );
    }

    Widget _setSearch() {
      return _searchQuery.isNotEmpty
          ? _searchList()
          : Column(
              children: [
                SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    'Привет!',
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
                    'Найдите заведение, которое вам нравиться, прямо сейчас!',
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

    return Scaffold(
      backgroundColor: c_primary,
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
                  height: MediaQuery.of(context).size.height * 0.35,
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
            duration: Duration(seconds: 1),
          ),
          _setScanSearch(),
          AnimatedContainer(
              margin: EdgeInsets.only(
                  top: _isClicked
                      ? MediaQuery.of(context).size.height * 0.30
                      : MediaQuery.of(context).size.height * 0.15),
              constraints: BoxConstraints.expand(
                height: double.infinity,
              ),
              duration: Duration(seconds: 1),
              curve: Curves.fastOutSlowIn,
              decoration: BoxDecoration(
                color: c_background,
                borderRadius: BorderRadius.only(
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
              )),
        ],
      ),
    );
  }
}
