import 'package:flutter/material.dart';
import 'package:guia_turismo/screen/home_screen.dart';

class Inicializar extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'home',
      routes: {
       'home': (context) => HomeScreen(),
      } 
    );
  }
}