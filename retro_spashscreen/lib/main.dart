import 'package:flutter/material.dart';
import 'package:retro_spashscreen/screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Retro Splash Screen', home: SplashScreen());
  }
}
