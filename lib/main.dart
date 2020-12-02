import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CheckConnection(),
    );
  }
}

class CheckConnection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(child: Text("Error: ${snapshot.error}")));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return StartScreen();
        }

        return Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 6)));
      },
    );
  }
}

// flutter build apk --target-platform android-arm
