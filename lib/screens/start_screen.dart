import 'dart:async';
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
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  }

  bool _scan = false;

  @override
  Widget build(BuildContext context) {
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

     Future<void> _testScanQR() async {
      var barcodeScanRes;
      if (_scan == false) {
        barcodeScanRes = 'kcPUo1hVcOShQQychzNdyw7Du9h1//4fibItto27xzlJb5elJm';
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

      if (barcodeScanRes.contains('//')) {
        List<String> splitRes = barcodeScanRes.split('//');
        String _restaurant = splitRes[0];
        String _address = splitRes[1];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(restaurant: _restaurant, address: _address),
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

    Future<void> _scanQR() async {
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

      if (barcodeScanRes.contains('//')) {
        List<String> splitRes = barcodeScanRes.split('//');
        String _restaurant = splitRes[0];
        String _address = splitRes[1];
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HomeScreen(restaurant: _restaurant, address: _address),
          ),
        );
      } else {
        _showAlertDialog(context);
      }
    }

    return Scaffold(
      backgroundColor: c_background,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 120,
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
                      fontSize: 25.0,
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
                      fontSize: 20.0,
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
                    onPressed: () => _scanQR(),
                    /*onPressed: () => _testDialog(context),*/
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
            ),
          ),
        ],
      ),
    );
  }
}
