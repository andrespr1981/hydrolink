import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hydrolink/utils/tiles.dart';
import 'package:hydrolink/utils/database.dart';
import 'package:hydrolink/utils/color_btn.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hydrolink/utils/pop_up_message.dart';
import 'package:hydrolink/utils/switch_color_btn.dart';
import 'package:hydrolink/utils/fan_progress_indicator.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import '../utils/linear_chart.dart';
import '../utils/mqtt_service.dart';

import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int graphicSelected = 0;

  final List<String> days = [
    'Domingo',
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
  ];

  List<bool> waterDays = [false, false, false, false, false, false, false];

  bool waterOn = false;
  double waterRemaining = 0;
  late int waterMinutes = 0;
  late int waterSeconds = 0;

  bool waterOnRecom = false;
  bool fanOnRecom = false;

  late int recomWaterTimeMinutes = 0;
  late int recomWaterTimeSeconds = 0;

  late int recomFanTimeMinutes = 0;
  late int recomFanTimeSeconds = 0;

  late int fanMinutes = 0;
  late int fanSeconds = 0;
  bool fanOn = false;

  late String humidity = '0';
  late int minHumidity = 0;
  late int minHumiditySend = 0;
  late double humiditySpot = 5.5;
  late String temperature = '0';
  late double temperatureSpot = 5.5;
  late int maxTemperature = 0;
  late int maxTemperatureSend = 0;

  late List<FlSpot> humiditySpots = [];
  late List<FlSpot> lightSpots = [];
  late List<FlSpot> dirtHumiditySpots = [];
  late List<FlSpot> temperatureSpots = [];

  late String light = '0';

  late String dirtHumidity = '0';

  final mqtt = MqttService();
  static String topicEntry = 'hydrolink/entry';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    connectMqtt();
  }

  void connectMqtt() async {
    mqtt.onMessage = (payload) {
      Map<String, dynamic> json = jsonDecode(payload);

      if (mounted) {
        setState(() {
          if (json['humidity'] < 40) {
            recomWaterTimeMinutes = 1;
          } else if (json['humidity'] < 60) {
            recomFanTimeSeconds = 30;
          } else {
            recomWaterTimeMinutes = 2;
          }

          if (json['temperature'] > 30) {
            temperatureSpot = 7.5;
          } else if (json['temperature'] < 25 && json['temperature'] > 18) {
            temperatureSpot = 5.5;
          } else {
            temperatureSpot = 2.5;
          }

          humidity = json['humidity'].toString();
          humiditySpot = double.parse(humidity);
          temperature = json['temperature'].toString();
          dirtHumidity = json['dirt_humidity'].toString();
          light = json['light'].toString();
          minHumidity = json['minHumidity'];
          maxTemperature = json['maxTemperature'];
          waterRemaining = (json['waterRemaining'] ?? 0).toDouble();
          waterDays = List<bool>.from(json['water_days']);
        });
        addGrapithData();
      }
    };
    if (await mqtt.connect()) {
      if (mounted) {
        showSuccessMesage(
          context,
          '!Conectado!',
          'Se conecto correcamente con el servicio',
        );
      }
      mqtt.publishJson(topicEntry, {"online": true});
    } else {
      if (mounted) {
        showErrorMesage(
          context,
          'Ups...',
          'No se pudo conectar con el servicio.',
        );
      }
    }
  }

  DateTime getNextWateringDate(List<bool> daysMondayFirst) {
    DateTime now = DateTime.now();

    // Dart: monday=1 → queremos monday=0
    int todayIndex = now.weekday - 1;

    for (int i = 0; i < 7; i++) {
      int index = (todayIndex + i) % 7;
      if (daysMondayFirst[index]) {
        return now.add(Duration(days: i));
      }
    }

    return now; // si no hay ningún día marcado
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("HydroLink"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height * 0.27,
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
                              'Floracion: 00 dias',
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Desarrollo: 00 dias',
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
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.topCenter,
                height: size.height * 0.50,
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
                    changeWidget(graphicSelected, size),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: size.height * 0.42,
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
                        Text(
                          'AGUA RESTANTE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                            if (waterMinutes > 0 || waterSeconds > 0) {
                              if (!waterOn) {
                                setState(() {
                                  waterOn = true;
                                });
                                int time = (60 * waterMinutes) + waterSeconds;
                                mqtt.publishJson(topicEntry, {
                                  "waterPump": time,
                                });
                                Timer(Duration(seconds: time), () {
                                  setState(() {
                                    waterOn = false;
                                  });
                                });
                              } else {
                                setState(() {
                                  waterOn = false;
                                });
                                mqtt.publishJson(topicEntry, {
                                  "waterPump": false,
                                });
                              }
                            } else {
                              showErrorMesage(
                                context,
                                'Ups...',
                                'Ingresa un tiempo mayor a cero.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: size.height * 0.42,
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
                        Text(
                          'TEMPERATURA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        fanOn
                            ? FanProgressIndicator(progress: 1)
                            : Image.asset('assets/fan.png', height: 100),
                        SizedBox(height: 10),
                        ColorBtn(
                          text:
                              'Tiempo de ventilación: $fanMinutes:${fanSeconds < 10 ? '0$fanSeconds' : fanSeconds}${fanMinutes < 1 ? ' seg' : ' min'}',
                          colors: const [Colors.lightGreen, Colors.green],
                          onTap: () {},
                          height: 60,
                          width: 170,
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
                                    fanMinutes = (value % 6);
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
                                    fanSeconds = value % 61;
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
                          textTrue: 'Apagar ventiladores',
                          textFalse: 'Encender ventilador',
                          colorsTrue: const [Colors.red, Colors.orange],
                          colorsFalse: const [
                            Colors.blue,
                            Colors.lightBlueAccent,
                          ],
                          state: fanOn,
                          onTap: () {
                            if (fanMinutes > 0 || fanSeconds > 0) {
                              if (!fanOn) {
                                setState(() {
                                  fanOn = true;
                                });
                                int time = (60 * fanMinutes) + fanSeconds;
                                mqtt.publishJson(topicEntry, {"fan": time});
                                Timer(Duration(seconds: time), () {
                                  setState(() {
                                    fanOn = false;
                                  });
                                });
                              } else {
                                setState(() {
                                  fanOn = false;
                                });
                                mqtt.publishJson(topicEntry, {"fan": false});
                              }
                            } else {
                              showErrorMesage(
                                context,
                                'Ups...',
                                'Ingresa un tiempo mayor a cero.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: size.height * 0.18,
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
                      children: [
                        SizedBox(height: 10),
                        ColorBtn(
                          text:
                              'Tiempo recomendado de regado: $recomWaterTimeMinutes:${recomWaterTimeSeconds < 10 ? '0$recomWaterTimeSeconds' : recomWaterTimeSeconds}${recomWaterTimeMinutes < 1 ? ' seg' : ' min'}',
                          colors: const [Colors.lightGreen, Colors.green],
                          onTap: () {},
                          height: 60,
                          width: 170,
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
                          state: waterOnRecom,
                          onTap: () {
                            if (recomWaterTimeMinutes > 0 ||
                                recomWaterTimeSeconds > 0) {
                              if (!waterOn) {
                                setState(() {
                                  waterOnRecom = true;
                                });
                                int time =
                                    (60 * recomWaterTimeMinutes) +
                                    recomWaterTimeSeconds;
                                mqtt.publishJson(topicEntry, {
                                  "waterPump": time,
                                });
                                Timer(Duration(seconds: time), () {
                                  setState(() {
                                    waterOnRecom = false;
                                  });
                                });
                              } else {
                                setState(() {
                                  waterOnRecom = false;
                                });
                                mqtt.publishJson(topicEntry, {
                                  "waterPump": false,
                                });
                              }
                            } else {
                              showErrorMesage(
                                context,
                                'Ups...',
                                'Ingresa un tiempo mayor a cero.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: size.height * 0.18,
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
                      children: [
                        SizedBox(height: 10),
                        ColorBtn(
                          text:
                              'Tiempo recomendado de ventilación: $recomFanTimeMinutes:${recomFanTimeSeconds < 10 ? '0$recomFanTimeSeconds' : recomFanTimeSeconds}${recomFanTimeMinutes < 1 ? ' seg' : ' min'}',
                          colors: const [Colors.lightGreen, Colors.green],
                          onTap: () {},
                          height: 60,
                          width: 170,
                        ),
                        SizedBox(height: 10),
                        SwitchColorBtn(
                          textTrue: 'Detener ventiladores',
                          textFalse: 'Encender ventiladores',
                          colorsTrue: const [Colors.red, Colors.orange],
                          colorsFalse: const [
                            Colors.blue,
                            Colors.lightBlueAccent,
                          ],
                          state: fanOnRecom,
                          onTap: () {
                            if (recomFanTimeMinutes > 0 ||
                                recomFanTimeSeconds > 0) {
                              if (!waterOn) {
                                setState(() {
                                  fanOnRecom = true;
                                });
                                int time =
                                    (60 * recomFanTimeMinutes) +
                                    recomFanTimeSeconds;
                                mqtt.publishJson(topicEntry, {"fan": time});
                                Timer(Duration(seconds: time), () {
                                  setState(() {
                                    fanOnRecom = false;
                                  });
                                });
                              } else {
                                setState(() {
                                  fanOnRecom = false;
                                });
                                mqtt.publishJson(topicEntry, {"fan": false});
                              }
                            } else {
                              showErrorMesage(
                                context,
                                'Ups...',
                                'Ingresa un tiempo mayor a cero.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                height: size.height * 0.57,
                width: size.width,
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      'FECHAS DE REGADO',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TableCalendar(
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Mes',
                        CalendarFormat.week: 'Semana',
                      },
                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, focusedDay) {
                          if (day.weekday == DateTime.sunday && waterDays[0] ||
                              day.weekday == DateTime.monday && waterDays[1] ||
                              day.weekday == DateTime.tuesday && waterDays[2] ||
                              day.weekday == DateTime.wednesday &&
                                  waterDays[3] ||
                              day.weekday == DateTime.thursday &&
                                  waterDays[4] ||
                              day.weekday == DateTime.friday && waterDays[5] ||
                              day.weekday == DateTime.saturday &&
                                  waterDays[6]) {
                            return Container(
                              margin: const EdgeInsets.all(6.0),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: Text(
                                  '${day.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                          return null;
                        },
                      ),
                      locale: 'es_ES',
                      focusedDay: DateTime.now(),
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      calendarFormat: CalendarFormat.month,
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(fontSize: 10),
                        weekendStyle: TextStyle(fontSize: 10),
                      ),
                      calendarStyle: const CalendarStyle(
                        defaultTextStyle: TextStyle(fontSize: 10),
                        weekendTextStyle: TextStyle(fontSize: 10),
                        outsideTextStyle: TextStyle(
                          fontSize: 8,
                          color: Colors.grey,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        leftChevronIcon: Icon(Icons.chevron_left, size: 18),
                        rightChevronIcon: Icon(Icons.chevron_right, size: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ColorBtn(
                          text: 'Cambiar Fechas de regado',
                          colors: const [Colors.blue, Colors.lightBlueAccent],
                          onTap: () {
                            showDatePicker();
                          },
                          height: 60,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> buildSpots(List<Map<String, dynamic>> list) {
    List<FlSpot> spots = [];
    for (int i = 0; i < list.length; i++) {
      double x = i.toDouble() + 1;
      double y = double.tryParse(list[i]['data'].toString()) ?? 0.0;
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  void getGrapithData() async {
    final humidityList = await LocalDatabase().readData('humidity');
    final lightList = await LocalDatabase().readData('light');
    final dirtHumList = await LocalDatabase().readData('dirtHumidity');
    final temperatureList = await LocalDatabase().readData('temperature');

    setState(() {
      humiditySpots = buildSpots(humidityList);
      lightSpots = buildSpots(lightList);
      dirtHumiditySpots = buildSpots(dirtHumList);
      temperatureSpots = buildSpots(temperatureList);
    });
  }

  void addGrapithData() async {
    final data = await LocalDatabase().readData('humidity');
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    if (data.isEmpty) {
      await LocalDatabase().addData('humidity', formattedDate, humidity);
      await LocalDatabase().addData('light', formattedDate, light);
      await LocalDatabase().addData(
        'dirtHumidity',
        formattedDate,
        dirtHumidity,
      );
      await LocalDatabase().addData('temperature', formattedDate, temperature);
      getGrapithData();
      return;
    }
    final finalRow = data.last;
    if (finalRow['date'] == formattedDate) {
      getGrapithData();
      return;
    }

    await LocalDatabase().addData('humidity', formattedDate, humidity);
    await LocalDatabase().addData('light', formattedDate, light);
    await LocalDatabase().addData('dirtHumidity', formattedDate, dirtHumidity);
    await LocalDatabase().addData('temperature', formattedDate, temperature);
    getGrapithData();

    return;
  }

  Widget changeWidget(int value, dynamic size) {
    if (value == 0) {
      return relativeHumidityWidget(size);
    } else if (value == 1) {
      return lightWidget(size);
    } else if (value == 2) {
      return dirtHumidityWidget(size);
    } else {
      return temperatureWidget(size);
    }
  }

  Widget relativeHumidityWidget(dynamic size) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GraphicWidget(
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 100,
            pointsList: humiditySpots,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                ColorBtn(
                  text: 'Humedad relativa: $humidity',
                  colors: const [Colors.lightGreen, Colors.green],
                  onTap: () {},
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: size.width * 0.40,
                  child: ScalesWidget(
                    colors: [
                      Color(0xFFFF4500),
                      Color.fromARGB(255, 255, 112, 60),
                      Color(0xFF87CEFA),
                      Color.fromARGB(255, 123, 204, 255),
                      const Color.fromARGB(255, 56, 165, 255),
                      Colors.blue,
                    ],
                    pointsList: [FlSpot(humiditySpot, 0.5)],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                ColorBtn(
                  text: 'Humedad relativa minima: $minHumidity',
                  colors: const [Colors.redAccent, Colors.red],
                  onTap: () {},
                ),
                SizedBox(height: 10),
                ColorBtn(
                  text: 'Cambiar humedad relativa minima',
                  colors: const [Colors.blue, Colors.lightBlueAccent],
                  onTap: () {
                    showMinHumidityPicker();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget lightWidget(dynamic size) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GraphicWidget(
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 1,
            pointsList: lightSpots,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ColorBtn(
              text: "Cantidad de luz recibida: $light",
              colors: const [Colors.lightGreen, Colors.green],
              onTap: () {},
              width: size.width * 0.40,
            ),
            SizedBox(
              height: 50,
              width: size.width * 0.40,
              child: ScalesWidget(
                colors: [
                  Color(0xFFFF4500),
                  Color(0xFFFFA500),
                  Color(0xFFFFD700),
                  Color(0xFFFFFFE0),
                  Color(0xFFF0F8FF),
                  Color(0xFFE0FFFF),
                  Color(0xFFB0E0E6),
                  Color(0xFF87CEFA),
                  Color(0xFF4682B4),
                  Color(0xFF0000FF),
                ],
                pointsList: [
                  FlSpot(
                    light == "0" ? 5.5 : (double.parse(light) / 10) * 10,
                    0.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget dirtHumidityWidget(dynamic size) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GraphicWidget(
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 4000,
            pointsList: dirtHumiditySpots,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ColorBtn(
              text: 'Humedad de la tierra: $dirtHumidity',
              colors: const [Colors.lightGreen, Colors.green],
              onTap: () {},
              width: size.width * 0.40,
            ),
            SizedBox(
              height: 50,
              width: size.width * 0.40,
              child: ScalesWidget(
                colors: [
                  Color(0xFFFF4500),
                  Color.fromARGB(255, 255, 112, 60),
                  Color(0xFF87CEFA),
                  Color.fromARGB(255, 123, 204, 255),
                  const Color.fromARGB(255, 56, 165, 255),
                  Colors.blue,
                ],
                pointsList: [
                  FlSpot(
                    dirtHumidity == "0"
                        ? 5.5
                        : (double.parse(dirtHumidity) / 4095) * 10,
                    0.5,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget temperatureWidget(dynamic size) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GraphicWidget(
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 100,
            pointsList: temperatureSpots,
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                ColorBtn(
                  text: 'Temperatura: $temperature°',
                  colors: const [Colors.lightGreen, Colors.green],
                  onTap: () {},
                ),
                SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  width: size.width * 0.40,
                  child: ScalesWidget(
                    colors: [
                      Color(0xFF0000FF),
                      Color(0xFF00BFFF),
                      Color(0xFF00FF7F),
                      Color(0xFF7CFC00),
                      Color(0xFFFFFF00),
                      Color(0xFFFFA500),
                      Color(0xFFFF4500),
                      Color(0xFFFF0000),
                    ],
                    pointsList: [FlSpot(temperatureSpot, 0.5)],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                ColorBtn(
                  text: 'Temperatura maxima: $maxTemperature°',
                  colors: const [Colors.redAccent, Colors.red],
                  onTap: () {},
                ),
                SizedBox(height: 10),
                ColorBtn(
                  text: 'Cambiar temperatura maxima',
                  colors: const [Colors.blue, Colors.lightBlueAccent],
                  onTap: () {
                    showMaxTempPicker();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void showDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Selecciona días de riego"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(days.length, (index) {
                    return CheckboxListTile(
                      title: Text(days[index]),
                      value: waterDays[index],
                      onChanged: (value) {
                        setStateDialog(() {
                          waterDays[index] = value!;
                        });
                      },
                    );
                  }),
                ),
              );
            },
          ),
          actions: [
            ColorBtn(
              text: 'Cancelar',
              colors: const [Colors.blue, Colors.lightBlueAccent],
              onTap: () {
                Navigator.pop(context);
              },
              width: 120,
            ),
            ColorBtn(
              text: 'Guardar',
              colors: const [Colors.blue, Colors.lightBlueAccent],
              onTap: () {
                setState(() {});
                mqtt.publishJson(topicEntry, {"waterDays": waterDays});
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
        );
      },
    );
  }

  void showMinHumidityPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleciona el minimo de humedad relativa"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Si la humedad relativa baja hasta ese punto, el riego se activará de forma automática.',
                    ),
                    SizedBox(height: 10),
                    ColorBtn(
                      text: minHumiditySend.toString(),
                      colors: const [Colors.lightGreen, Colors.green],
                      onTap: () {},
                    ),
                    SizedBox(
                      height: 70,
                      width: 50,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 30,
                        onSelectedItemChanged: (value) {
                          setStateDialog(() {
                            minHumiditySend = value % 303;
                            minHumidity = minHumiditySend;
                          });
                        },
                        perspective: 0.01,
                        diameterRatio: 3,
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 303,
                          builder: (context, index) {
                            final value = index % 303;
                            return Minutes(mins: value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            ColorBtn(
              text: 'Cancelar',
              colors: const [Colors.blue, Colors.lightBlueAccent],
              onTap: () {
                setState(() {
                  minHumiditySend = 0;
                });
                Navigator.pop(context);
              },
              width: 120,
            ),
            ColorBtn(
              text: 'Guardar',
              colors: const [Colors.blue, Colors.lightBlueAccent],
              onTap: () {
                setState(() {});
                mqtt.publishJson(topicEntry, {"minHumidity": minHumiditySend});
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
        );
      },
    );
  }

  void showMaxTempPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleciona la temperatura maxima"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Si la temperatura sube hasta ese punto, el ventilador se activará de forma automática.',
                    ),
                    SizedBox(height: 10),
                    ColorBtn(
                      text: '${maxTemperatureSend.toString()}°',
                      colors: const [Colors.lightGreen, Colors.green],
                      onTap: () {},
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 70,
                      width: 50,
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 30,
                        onSelectedItemChanged: (value) {
                          setStateDialog(() {
                            maxTemperatureSend = value % 101;
                          });
                        },
                        perspective: 0.01,
                        diameterRatio: 3,
                        childDelegate: ListWheelChildBuilderDelegate(
                          childCount: 303,
                          builder: (context, index) {
                            final degrees = index % 101;
                            return TemperatureDegrees(degrees: degrees);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            ColorBtn(
              text: 'Cancelar',
              colors: const [Colors.blue, Colors.lightBlueAccent],
              onTap: () {
                setState(() {
                  maxTemperatureSend = 0;
                });
                Navigator.pop(context);
              },
              width: 120,
            ),
            ColorBtn(
              text: 'Guardar',
              colors: const [Colors.blue, Colors.lightBlueAccent],
              onTap: () {
                setState(() {});
                mqtt.publishJson(topicEntry, {
                  "maxTemperature": maxTemperatureSend,
                });
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
        );
      },
    );
  }
}
