import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/inicializar.dart';
import 'package:guia_turismo/screens/lugares_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(inicializar());
}

class inicializar extends StatefulWidget {
  const inicializar({super.key});

  @override
  State<inicializar> createState() => _inicializarState();
}

class _inicializarState extends State<inicializar> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => LugaresController()),
      //ChangeNotifierProvider(create: (_)=> AuthController())
    ],
    child: Consumer(
      builder: (context, lugaresController, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: 'lugares',
        routes: {
          'lugares': (context) => LugaresScreen()
        },
      ),
    ),
    );
  }
}