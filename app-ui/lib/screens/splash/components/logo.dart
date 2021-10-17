import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hashchecker/screens/splash/splash_screen.dart';
import 'package:simple_animations/simple_animations.dart';

class Logo extends StatefulWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  var _opacity = 0.0;

  @override
  void initState() {}

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      setState(() {
        _opacity = 1.0;
      });
    });
    return Center(
        child: AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 1250),
      curve: Curves.fastOutSlowIn,
      child: Image.asset(
        'assets/images/splash/logo.png',
        width: 250,
        height: 250,
      ),
    ));
  }
}
