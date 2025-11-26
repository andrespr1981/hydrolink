import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hydrolink/utils/color_btn.dart';
import 'package:hydrolink/utils/fan_progress_indicator.dart';
import 'package:hydrolink/utils/pop_up_message.dart';
import 'package:hydrolink/utils/switch_color_btn.dart';
import 'package:hydrolink/utils/tiles.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:table_calendar/table_calendar.dart';

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

  late String humidity = '0';

  final List<String> days = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
    'Sabado',
    'Domingo',
  ];

  List<bool> waterDays = [false, false, false, false, false, false, false];

  late int waterMinutes = 0;
  late int waterSeconds = 0;

  late int fanMinutes = 0;
  late int fanSeconds = 0;
  bool fanOn = false;

  final mqtt = MqttService();
  static String topic = 'hydrolink/entry';

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
                      onPressed: () {
                        mqtt.publish(topic, "0");
                      },
                    ),

                    ElevatedButton(
                      child: Text("Suscribirse"),
                      onPressed: () {
                        mqtt.connect();
                      },
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
                    changeGraphic(graphicSelected),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            if (waterMinutes > 0 || waterSeconds > 0) {
                              if (!waterOn) {
                                setState(() {
                                  waterOn = true;
                                });
                                mqtt.publishJson(topic, {
                                  "waterPump":
                                      (60 / waterMinutes) + waterSeconds,
                                });
                              } else {
                                setState(() {
                                  waterOn = false;
                                });
                                mqtt.publishJson(topic, {"waterPump": false});
                              }
                            } else {
                              showErrorMesage(
                                context,
                                'Ups...',
                                'Por favor, ingresa un tiempo de riego mayor a cero.',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
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
                        Text('TEMPERATURA'),
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
                            if (!fanOn) {
                              setState(() {
                                fanOn = true;
                              });
                              mqtt.publishJson(topic, {
                                "fan": (60 / fanMinutes) + fanSeconds,
                              });
                            } else {
                              setState(() {
                                fanOn = false;
                              });
                              mqtt.publishJson(topic, {"fan": false});
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
                height: size.height * 0.55,
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
                          if (day.weekday == DateTime.monday && waterDays[0] ||
                              day.weekday == DateTime.tuesday && waterDays[1] ||
                              day.weekday == DateTime.wednesday &&
                                  waterDays[2] ||
                              day.weekday == DateTime.thursday &&
                                  waterDays[3] ||
                              day.weekday == DateTime.friday && waterDays[4] ||
                              day.weekday == DateTime.saturday &&
                                  waterDays[5] ||
                              day.weekday == DateTime.sunday && waterDays[6]) {
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
                          setStateDialog(() {
                            waterDays[index] = value!;
                          });
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
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
        );
      },
    );
  }

  Widget changeGraphic(int value) {
    if (value == 0) {
      return relativeHumidity();
    } else if (value == 1) {
      return light();
    } else if (value == 2) {
      return dirtHumidity();
    } else {
      return temperature();
    }
  }

  Widget relativeHumidity() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GraphicWidget(
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 4000,
            pointsList: [FlSpot(1, 8), FlSpot(2, 6), FlSpot(3, 4)],
          ),
        ),
        ColorBtn(
          text: 'Humedad relativa: $humidity',
          colors: const [Colors.lightGreen, Colors.green],
          onTap: () {},
        ),
      ],
    );
  }

  Widget light() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GraphicWidget(
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 12000,
            pointsList: [FlSpot(1, 8), FlSpot(2, 6), FlSpot(3, 4)],
          ),
        ),
      ],
    );
  }

  Widget dirtHumidity() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GraphicWidget(
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 4000,
            pointsList: [FlSpot(1, 8), FlSpot(2, 6), FlSpot(3, 4)],
          ),
        ),
      ],
    );
  }

  Widget temperature() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: GraphicWidget(
            minX: 1,
            maxX: 7,
            minY: 0,
            maxY: 100,
            pointsList: [FlSpot(1, 8), FlSpot(2, 6), FlSpot(3, 4)],
          ),
        ),
      ],
    );
  }
}
