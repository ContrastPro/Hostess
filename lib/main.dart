import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hostess/notifier/food_notifier.dart';
import 'package:hostess/notifier/profile_notifier.dart';
import 'package:hostess/screens/start_screen.dart';
import 'package:provider/provider.dart';

import 'notifier/categories_notifier.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => CategoriesNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => FoodNotifier(),
          ),
          ChangeNotifierProvider(
            create: (context) => ProfileNotifier(),
          ),
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hostess',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: CheckConnection(),
    );
  }
}

class CheckConnection extends StatefulWidget {
  @override
  _CheckConnectionState createState() => _CheckConnectionState();
}

class _CheckConnectionState extends State<CheckConnection> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StartScreen();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 10)));
      },
    );
  }
}

// flutter build apk --target-platform android-arm
