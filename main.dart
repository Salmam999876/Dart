// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'font_provider.dart';
import 'package:my_daily_diary/screens/diary_list_screen.dart';
import 'package:my_daily_diary/screens/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FontProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fontName = Provider.of<FontProvider>(context).selectedFont;
    return MaterialApp(
      home: SplashScreen(),
      theme: ThemeData(
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: fontName,
            ),
      ),
    );
  }
}
