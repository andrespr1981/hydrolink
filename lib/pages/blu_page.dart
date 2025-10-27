import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import 'dart:typed_data';

import '../utils/fan_progress_indicator.dart';
import '../utils/pop_up_message.dart';
import '../utils/linear_chart.dart';

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

  int graphicSelected = 0;
  bool waterOn = false;
  double waterRemaining = 0.5;

  bool fanOn = false;

  @override
  void initState() {
    super.initState();
    scanAndConnect();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: size.height * 0.25,
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
                        Column(children: [Text('FASE')]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsetsGeometry.only(left: 20),
                              child: Image.asset(
                                'assets/semillac.png',
                                height: 100,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('00 dias'),
                                Text('00 dias'),
                                Text('00 dias'),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.blue, Colors.lightBlueAccent],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                sendData('ON');
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: const Center(
                                child: Text(
                                  "Iniciar regado",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: size.height * 0.20,
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

                        // Condicion para mostrar un boton en caso de que haya regado o no
                        Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: waterOn
                                  ? const [Colors.red, Colors.orange]
                                  : const [Colors.blue, Colors.lightBlueAccent],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (!waterOn) {
                                  setState(() {
                                    waterOn = true;
                                  });
                                  sendData('waterOn');
                                } else {
                                  setState(() {
                                    waterOn = false;
                                  });
                                  sendData('waterOff');
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Center(
                                child: waterOn
                                    ? const Text(
                                        "Detener regado",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const Text(
                                        "Iniciar regado",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
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
                    height: size.height * 0.25,
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
                                'assets/temperature.png',
                                height: 50,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('20°C'),
                            fanOn
                                ? FanProgressIndicator(progress: 1)
                                : Image.asset('assets/fan.png', height: 70),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: fanOn
                                  ? const [Colors.red, Colors.orange]
                                  : const [Colors.blue, Colors.lightBlueAccent],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (!fanOn) {
                                  setState(() {
                                    fanOn = true;
                                  });
                                  sendData('fanOn');
                                } else {
                                  setState(() {
                                    fanOn = false;
                                  });
                                  sendData('fanOff');
                                }
                              },
                              borderRadius: BorderRadius.circular(30),
                              child: Center(
                                child: fanOn
                                    ? const Text(
                                        "Apagar ventilador",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const Text(
                                        "Encender ventilador",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: size.height * 0.25,
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
                              child: Image.asset('assets/ph.jpg', height: 50),
                            ),
                          ],
                        ),
                        Text('7'),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: size.width * 0.40,
                          child: ScalesWidget(
                            colors: [
                              Color(0xFF8B0000),
                              Color(0xFFB22222),
                              Color(0xFFFF4500),
                              Color(0xFFFF6347),
                              Color(0xFFFFA07A),
                              Color(0xFFFFFF00),
                              Color(0xFFADFF2F),
                              Color(0xFF00FF00),
                              Color(0xFF32CD32),
                              Color(0xFF00CED1),
                              Color(0xFF1E90FF),
                              Color(0xFF4169E1),
                              Color(0xFF6A5ACD),
                              Color(0xFF8A2BE2),
                              Color(0xFF9400D3),
                            ],
                            pointsList: [FlSpot(7, 0.5)],
                          ),
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
                    height: size.height * 0.25,
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
                                'assets/luxes.png',
                                height: 50,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('7'),
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
                    height: size.height * 0.25,
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
                          ],
                        ),
                        Column(
                          children: [
                            Text('7'),
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
            ],
          ),
        ),
      ),
    );
  }

  void scanAndConnect() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.advName == targetDeviceName && !isConnecting) {
          isConnecting = true;
          await FlutterBluePlus.stopScan();
          device = r.device;

          try {
            try {
              await device!.disconnect();
            } catch (_) {}

            await device!.connect(autoConnect: false);
            setState(() => isConnected = true);

            List<BluetoothService> services = await device!.discoverServices();
            for (var s in services) {
              if (s.uuid.toString() == serviceUuid) {
                for (var c in s.characteristics) {
                  if (c.uuid.toString() == characteristicUuid) {
                    characteristic = c;
                    await characteristic!.setNotifyValue(true);
                    characteristic!.lastValueStream.listen((value) {
                      String msg = String.fromCharCodes(value);
                      print(msg);
                    });
                  }
                }
              }
            }

            if (mounted) {
              showMessage(
                context,
                Colors.green,
                'assets/sunny_plant.png',
                'Conectado',
                '¡Conexión Bluetooth establecida con éxito!',
              );
            }
          } catch (e) {
            if (mounted) {
              showMessage(
                context,
                Colors.red,
                'assets/bad_plant.png',
                'Error',
                'No se pudo establecer la conexión Bluetooth.',
              );
            }
          }

          return;
        }
      }
    });
  }

  void sendData(String text) async {
    if (characteristic != null && isConnected) {
      Uint8List bytes = Uint8List.fromList(text.codeUnits);
      await characteristic!.write(bytes, withoutResponse: false);
    } else {
      showMessage(
        context,
        Colors.red,
        'assets/bad_plant.png',
        'Algo paso',
        'Ups... parece que no estás conectado',
      );
    }
  }
}
