import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hostess/custom_widget/custom_container.dart';
import 'package:hostess/custom_widget/custom_fade_route.dart';
import 'package:hostess/custom_widget/product_widget/product_widget.dart';
import 'package:hostess/global/colors.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  _showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Упс...'),
          titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
          contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
          children: <Widget>[
            Divider(),
            SizedBox(height: 10),
            Text(
              'Похоже ваш QR код неверного формата :(',
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
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
          page: ProductWidget(uid: splitRes[0], address: splitRes[1]),
        ),
      );
    } else {
      _showAlertDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _setScan() {
      return Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.20),
          Container(
            width: 180,
            height: 180,
            child: FlareActor(
              "assets/rive/qrcode.flr",
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: "show",
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

    return Scaffold(
      backgroundColor: c_primary,
      body: CustomContainer(
        title: 'Главная',
        child: _setScan(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c_secondary,
        onPressed: () => _scanQR(),
        icon: const Icon(Icons.camera_enhance),
        label: const Text(
          'СКАНИРОВАТЬ',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
      ),
    );
  }
}
