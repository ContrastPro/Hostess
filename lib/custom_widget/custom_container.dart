import 'package:flutter/material.dart';
import 'package:hostess/global/colors.dart';

class CustomContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const CustomContainer({Key key, @required this.title, @required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: 25.0),
            width: double.infinity,
            height: 65.0,
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 19.0,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: c_background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
