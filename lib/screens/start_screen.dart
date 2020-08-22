import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/screens/home_screen.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> _load(String scan) async {
      List<String> splitRes = scan.split('//');
      String _restaurant = splitRes[0];
      String _address = splitRes[1];
      await FirebaseFirestore.instance
          .collection(_restaurant)
          .doc(_address)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  HomeScreen(restaurant: _restaurant, address: _address),
            ),
          );
        } else {
          print('Error Firebase');
        }
      });
    }

    Future<void> _scanQR() async {
      var barcodeScanRes = 'Jardin//Одесса, ул. Гаванная 10';
      /*try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666",
          "Отмена",
          true,
          ScanMode.QR,
        );
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }

      if (!mounted) return;*/

      if (barcodeScanRes.contains('//')) {
        _load(barcodeScanRes);
      } else{
        print('Error contains');
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
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
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
                    onPressed: () async {
                      await _scanQR();
                    },
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
