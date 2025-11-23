import 'package:flutter/material.dart';

class Minutes extends StatelessWidget {
  final int mins;
  const Minutes({super.key, required this.mins});

  @override
  Widget build(BuildContext context) {
    return Text(mins.toString());
  }
}

class Seconds extends StatelessWidget {
  final int seconds;
  const Seconds({super.key, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Text(seconds < 10 ? '0${seconds.toString()}' : seconds.toString());
  }
}

class TemperatureDegrees extends StatelessWidget {
  final int degrees;
  const TemperatureDegrees({super.key, required this.degrees});

  @override
  Widget build(BuildContext context) {
    return Text('${degrees.toString()}°');
  }
}
