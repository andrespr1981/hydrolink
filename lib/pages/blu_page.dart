import 'dart:convert';

import 'package:hydrolink/utils/switch_color_btn.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import 'dart:typed_data';

import '../utils/pop_up_message.dart';
import '../utils/linear_chart.dart';
import '../utils/tiles.dart';
import '../utils/color_btn.dart';

class BluPage extends StatefulWidget {
  const BluPage({super.key});

  @override
  State<BluPage> createState() => _BluPageState();
}

class _BluPageState extends State<BluPage> {
  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;
  bool isConnected = false;
  bool isConnecting = false;

  final String targetDeviceName = "ESP32_BLE";
  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

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

  bool waterOn = false;

  bool fanOn = false;

  late int waterMinutes = 0;
  late int waterSeconds = 0;

  late int fanMinutes = 0;
  late int fanSeconds = 0;

  //data
  late double waterRemaining = 0.5;

  late String humidity = '0';
  late int minHumidity = 0;
  late int minHumiditySend = 0;
  late double humiditySpot = 5.5;
  late String temperature = '0';
  late double temperatureSpot = 5.5;
  late int maxTemperature = 0;
  late int maxTemperatureSend = 0;

  late String dirtHumidity = '0';

  late String light = '0';

  late DateTime nextWaterDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    scanAndConnect();
    initializeDateFormatting('es_ES', null);
  }

  @override
  void dispose() {
    device?.disconnect();
    super.dispose();
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
              scanAndConnect();
            },
            icon: Icon(Icons.refresh_rounded),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: size.height * 0.23,
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
                          onTap: () {
                            showFasePicker();
                          },
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
                height: size.height * 0.65,
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
                    SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'AGUA RESTANTE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'HUMEDAD RELATIVA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 10),
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
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
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
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
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
                                    sendData(
                                      'waterPump',
                                      (60 / waterMinutes) + waterSeconds,
                                    );
                                  } else {
                                    setState(() {
                                      waterOn = false;
                                    });
                                    sendData('waterPump', false);
                                  }
                                } else {
                                  showErrorMesage(
                                    context,
                                    'Alerta',
                                    'Debes de elegir ',
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Column(
                              children: [
                                ColorBtn(
                                  text: 'Humedad relativa: $humidity',
                                  colors: const [
                                    Colors.lightGreen,
                                    Colors.green,
                                  ],
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
                                SizedBox(height: 10),
                                ColorBtn(
                                  text: 'Humedad relativa minima: $minHumidity',
                                  colors: const [Colors.redAccent, Colors.red],
                                  onTap: () {},
                                ),
                                SizedBox(height: 10),
                                ColorBtn(
                                  text: 'Cambiar humedad relativa minima',
                                  colors: const [
                                    Colors.blue,
                                    Colors.lightBlueAccent,
                                  ],
                                  onTap: () {
                                    showMinHumidityPicker();
                                  },
                                ),
                                SizedBox(height: 10),
                                ColorBtn(
                                  text:
                                      'Proximo regado: ${DateFormat('yyyy-MM-dd').format(nextWaterDay)}',
                                  colors: const [
                                    Colors.lightGreen,
                                    Colors.green,
                                  ],
                                  onTap: () {},
                                  height: 60,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      'TEMPERATURA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                  Color(0xFFFF0000), //
                                ],
                                pointsList: [FlSpot(temperatureSpot, 0.5)],
                              ),
                            ),
                            SizedBox(height: 10),
                            ColorBtn(
                              text: 'Temperatura maxima: $maxTemperature°',
                              colors: const [Colors.redAccent, Colors.red],
                              onTap: () {},
                            ),
                            SizedBox(height: 10),
                            ColorBtn(
                              text: 'Cambiar temperatura maxima',
                              colors: const [
                                Colors.blue,
                                Colors.lightBlueAccent,
                              ],
                              onTap: () {
                                showMaxTempPicker();
                              },
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            ColorBtn(
                              text:
                                  'Tiempo de ventilación: $fanMinutes:${fanSeconds < 10 ? '0$fanSeconds' : fanSeconds}${fanMinutes < 1 ? ' seg' : ' min'}',
                              colors: const [Colors.lightGreen, Colors.green],
                              onTap: () {},
                              height: 60,
                              width: 170,
                            ),
                            SizedBox(height: 10),
                            Row(
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
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
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
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
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
                                  sendData(
                                    'fan',
                                    (60 / fanMinutes) + fanSeconds,
                                  );
                                } else {
                                  setState(() {
                                    fanOn = false;
                                  });
                                  sendData('fan', false);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: size.height * 0.15,
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
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.only(
                                left: 10,
                                top: 10,
                                right: 10,
                              ),
                              child: Image.asset(
                                'assets/luxes.png',
                                height: 50,
                              ),
                            ),
                            ColorBtn(
                              text: light,
                              colors: const [Colors.lightGreen, Colors.green],
                              onTap: () {},
                              width: 100,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
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
                                pointsList: [FlSpot(7, 0.5)],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: size.height * 0.15,
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
                        Row(
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.only(
                                left: 10,
                                top: 10,
                              ),
                              child: Image.asset(
                                'assets/humidity.jpg',
                                height: 50,
                              ),
                            ),
                            ColorBtn(
                              text: dirtHumidity,
                              colors: const [Colors.lightGreen, Colors.green],
                              onTap: () {},
                              width: 100,
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
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
                                pointsList: [FlSpot(7, 0.5)],
                              ),
                            ),
                          ],
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
                    Text(
                      'Fechas de regado',
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
                sendData('minHumidity', minHumiditySend);
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
        );
      },
    );
  }

  void showFasePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Seleciona la fase"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateDialog) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Si la temperatura sube hasta ese punto, el ventilador se activará de forma automática.',
                    ),

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
                Navigator.pop(context);
              },
            ),
            ColorBtn(
              text: 'Guardar',
              colors: const [Colors.blue, Colors.lightBlueAccent],
              onTap: () {
                sendData('maxTemperature', maxTemperatureSend);
                Navigator.pop(context);
              },
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
                sendData('maxTemperature', maxTemperatureSend);
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
        );
      },
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
                sendData('waterDays', waterDays);
                Navigator.pop(context);
              },
              width: 120,
            ),
          ],
        );
      },
    );
  }

  void scanAndConnect() async {
    try {
      if (await FlutterBluePlus.isSupported == false) {
        throw Exception();
      }

      if (device != null) {
        await device!.disconnect();
      }

      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      FlutterBluePlus.scanResults.listen((results) async {
        for (ScanResult r in results) {
          if (r.device.advName == targetDeviceName && !isConnecting) {
            isConnecting = true;
            await FlutterBluePlus.stopScan();
            device = r.device;

            try {
              await device!.connect(autoConnect: false);
              setState(() => isConnected = true);

              List<BluetoothService> services = await device!
                  .discoverServices();
              for (var s in services) {
                if (s.uuid.toString() == serviceUuid) {
                  for (var c in s.characteristics) {
                    if (c.uuid.toString() == characteristicUuid) {
                      characteristic = c;

                      await characteristic!.setNotifyValue(true);

                      characteristic!.lastValueStream.listen((value) {
                        String msg = String.fromCharCodes(value);
                        Map<String, dynamic> json = jsonDecode(msg);

                        if (json['humidity'] < 40) {
                          setState(() {
                            waterMinutes = 1;
                          });
                        } else if (json['humidity'] < 60) {
                          setState(() {
                            waterSeconds = 30;
                          });
                        } else {
                          setState(() {
                            waterMinutes = 2;
                          });
                        }

                        if (json['temperature'] > 30) {
                          setState(() {
                            temperatureSpot = 7.5;
                          });
                        } else if (json['temperature'] < 25 &&
                            json['temperature'] > 18) {
                          setState(() {
                            temperatureSpot = 5.5;
                          });
                        } else {
                          setState(() {
                            temperatureSpot = 2.5;
                          });
                        }

                        setState(() {
                          humidity = json['humidity'].toString();
                          humiditySpot = double.parse(humidity);
                          temperature = json['temperature'].toString();
                          dirtHumidity = json['dirt_humidity'].toString();
                          light = json['light'].toString();
                          minHumidity = json['minHumidity'];
                          maxTemperature = json['maxTemperature'];
                          waterDays = List<bool>.from(json['water_days']);
                          nextWaterDay = getNextWateringDate(waterDays);
                        });
                      });
                    }
                  }
                }
              }

              if (mounted) {
                showSuccessMesage(
                  context,
                  'Conectado',
                  '¡Conexión Bluetooth establecida con éxito!',
                );
              }
            } catch (e) {
              if (mounted) {
                showErrorMesage(
                  context,
                  'Ups..',
                  'No se ha podido establecer la conexión.',
                );
              }
            }
          }
        }
      });

      Future.delayed(const Duration(seconds: 6), () {
        if (!isConnected && mounted) {
          showErrorMesage(
            context,
            'Algo paso',
            'No se detectó el dispositivo.',
          );
        }
      });
    } catch (e) {
      if (mounted) {
        showErrorMesage(context, 'Ups..', 'Tu dispositivo no es compatible.');
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

  void sendData(String name, dynamic data) async {
    if (characteristic != null && isConnected) {
      final jsonString = {name: data};
      final json = jsonEncode(jsonString);
      Uint8List bytes = utf8.encode(json);
      await characteristic!.write(bytes, withoutResponse: false);
    } else {
      showErrorMesage(
        context,
        'Algo paso',
        'Ups... parece que no estás conectado',
      );
      if (waterOn) {
        setState(() {
          waterOn = false;
        });
      }
      if (fanOn) {
        setState(() {
          fanOn = false;
        });
      }
    }
  }
}
