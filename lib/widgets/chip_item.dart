import 'package:flutter/material.dart';
import 'package:hostess/global/colors.dart';
import 'package:hostess/notifier/food_notifier.dart';
import 'package:provider/provider.dart';

class ChipItem extends StatelessWidget {
  _buildListIngredients(FoodNotifier foodNotifier) {
    List<Widget> choices = List();

    foodNotifier.currentFood.subIngredients.forEach((ingredient) {
      choices.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          padding: const EdgeInsets.only(right: 10.0),
          child: Chip(
            padding: EdgeInsets.all(10),
            backgroundColor: t_secondary.withOpacity(0.3),
            elevation: 0,
            avatar: Text(
              '#',
              style: TextStyle(
                fontSize: 14.0,
                color: c_primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            label: Text(
              ingredient,
              style: TextStyle(
                fontSize: 14.0,
                color: t_primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    FoodNotifier foodNotifier = Provider.of<FoodNotifier>(context);

    return Wrap(children: _buildListIngredients(foodNotifier));
  }
}
