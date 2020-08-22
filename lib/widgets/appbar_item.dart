import 'package:flutter/material.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/screens/cart_screen.dart';

class CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
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
            child: RawMaterialButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartScreen(),
                  ),
                );
              },
              fillColor: c_secondary.withOpacity(0.5),
              child: Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              padding: EdgeInsets.all(13.0),
              shape: CircleBorder(),
            ),
          ),
          /*Padding(
            padding: EdgeInsets.all(20.0),
            child: ButtonTheme(
              minWidth: 10.0,
              height: 50.0,
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                elevation: 0,
                highlightElevation: 0,
                color: c_secondary.withOpacity(0.5),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),*/
          /*Padding(
            padding: EdgeInsets.all(20.0),
            child: ButtonTheme(
              minWidth: 10.0,
              height: 50.0,
              child: RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CartScreen(),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                elevation: 0,
                highlightElevation: 0,
                color: c_secondary.withOpacity(0.5),
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}
