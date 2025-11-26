import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hydrolink/utils/color_btn.dart';
import 'package:hydrolink/utils/switch_color_btn.dart';
import 'package:hydrolink/utils/tiles.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import '../utils/linear_chart.dart';

import '../utils/mqtt_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int graphicSelected = 0;
  bool waterOn = false;
  double waterRemaining = 0;

  late int waterMinutes = 0;
  late int waterSeconds = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("HydroLink"),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height * 0.40,
                width: size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.3),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(10, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: Offset(10, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 5),
                        Text(
                          'FASE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          'assets/semillac.png',
                          height: 100,
                          width: 100,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Produccion: 00 dias',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Floracion: 00 dias',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Desarrollo: 00 dias',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Germinacion: 00 dias',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Semilla: 00 dias',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ColorBtn(
                          text: 'Regresar fase',
                          colors: const [Colors.blue, Colors.lightBlueAccent],
                          onTap: () {},
                        ),
                        ColorBtn(
                          text: 'Empezar nueva fase',
                          colors: const [Colors.blue, Colors.lightBlueAccent],
                          onTap: () {},
                        ),
                      ],
                    ),
                    ElevatedButton(
                      child: Text("Enviar mensaje"),
                      onPressed: () {},
                    ),

                    ElevatedButton(
                      child: Text("Suscribirse"),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.topCenter,
                height: size.height * 0.5,
                width: size.width * 1,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(10, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(),
                      blurRadius: 50,
                      offset: Offset(-1, -1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          child: Image.asset('assets/humidity.jpg', height: 50),
                          onTap: () {
                            setState(() {
                              graphicSelected = 0;
                            });
                          },
                        ),
                        GestureDetector(
                          child: Image.asset('assets/luxes.png', height: 50),
                          onTap: () {
                            setState(() {
                              graphicSelected = 1;
                            });
                          },
                        ),
                        GestureDetector(
                          child: Image.asset(
                            'assets/dirt_humidity.png',
                            height: 50,
                          ),
                          onTap: () {
                            setState(() {
                              graphicSelected = 2;
                            });
                          },
                        ),
                        GestureDetector(
                          child: Image.asset(
                            'assets/temperature.png',
                            height: 50,
                          ),
                          onTap: () {
                            setState(() {
                              graphicSelected = 3;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 200,
                      child: changeGraphic(graphicSelected),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    height: size.height * 0.37,
                    width: size.width * 0.45,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(),
                          spreadRadius: 1,
                          blurRadius: 10,
                          offset: Offset(10, 5),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(),
                          blurRadius: 50,
                          offset: Offset(-1, -1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('AGUA RESTANTE'),
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: LiquidCircularProgressIndicator(
                            value: waterRemaining,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.blueAccent,
                            ),
                            backgroundColor: Colors.white,
                            borderColor: Colors.black,
                            borderWidth: 0.0,
                            direction: Axis.vertical,
                          ),
                        ),
                        SizedBox(height: 10),
                        ColorBtn(
                          text:
                              'Tiempo de regado: $waterMinutes:${waterSeconds < 10 ? '0$waterSeconds' : waterSeconds}${waterMinutes < 1 ? ' seg' : ' min'}',
                          colors: const [Colors.lightGreen, Colors.green],
                          onTap: () {},
                          height: 60,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 70,
                              width: 50,
                              child: ListWheelScrollView.useDelegate(
                                onSelectedItemChanged: (value) {
                                  setState(() {
                                    waterMinutes = (value % 6);
                                  });
                                },
                                itemExtent: 30,
                                perspective: 0.01,
                                diameterRatio: 3,
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 50,
                                  builder: (context, index) {
                                    final minute = index % 6;
                                    return Minutes(mins: minute);
                                  },
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 70,
                              width: 50,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 30,
                                onSelectedItemChanged: (value) {
                                  setState(() {
                                    waterSeconds = value % 61;
                                  });
                                },
                                perspective: 0.01,
                                diameterRatio: 3,
                                childDelegate: ListWheelChildBuilderDelegate(
                                  childCount: 183,
                                  builder: (context, index) {
                                    final second = index % 61;
                                    return Seconds(seconds: second);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        SwitchColorBtn(
                          textTrue: 'Detener regado',
                          textFalse: 'Iniciar regado',
                          colorsTrue: const [Colors.red, Colors.orange],
                          colorsFalse: const [
                            Colors.blue,
                            Colors.lightBlueAccent,
                          ],
                          state: waterOn,
                          onTap: () {
                            if (!waterOn) {
                              setState(() {
                                waterOn = true;
                              });
                            } else {
                              setState(() {
                                waterOn = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget changeGraphic(int value) {
    //ph lx humedad c
    final List<double> maxY = [4000, 12000, 4000, 100];

    return GraphicWidget(
      minX: 1,
      maxX: 7,
      minY: 0,
      maxY: maxY[value],
      pointsList: [FlSpot(1, 8), FlSpot(2, 6), FlSpot(3, 4)],
    );
  }
}
