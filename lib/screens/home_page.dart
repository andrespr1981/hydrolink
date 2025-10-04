import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import 'dart:typed_data';

import '../utils/pop_up_message.dart';
import '../utils/linear_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BluetoothDevice? device;
  BluetoothCharacteristic? characteristic;
  bool isConnected = false;

  final String targetDeviceName = "ESP32_BLE";
  final String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    scanAndConnect();
  }

  void scanAndConnect() async {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.advName == targetDeviceName) {
          await FlutterBluePlus.stopScan();
          device = r.device;
          try {
            try {
              await device!.disconnect();
            } catch (e) {
              print("No estaba conectado: $e");
            }
            await device!.connect(autoConnect: false);
            if (mounted) {
              showMessage(
                context,
                Colors.green,
                'assets/sunny_plant.png',
                'Conectado',
                '¡Conexión Bluetooth establecida con éxito!',
              );
            }
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
                    });
                  }
                }
              }
            }
          } catch (e) {
            if (mounted) {
              showMessage(
                context,
                Colors.red,
                'assets/bad_plant.png',
                'Algo paso',
                '¡No se pudo establecer la conexión Bluetooth. Intenta nuevamente.!',
              );
            }
          }
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

  @override
  void dispose() {
    device?.disconnect();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("HydroLink")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.only(left: 20),
                        child: Image.asset('assets/semillac.png'),
                      ),
                      Column(children: [Text('FASE')]),
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
                      Text('AGUA RESTANTE'),
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: LiquidCircularProgressIndicator(
                          value: 0.5,
                          valueColor: AlwaysStoppedAnimation(Colors.blueAccent),
                          backgroundColor: Colors.white,
                          borderColor: Colors.black,
                          borderWidth: 0.0,
                          direction: Axis.vertical,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                        child: Image.asset('assets/ph.jpg', height: 50),
                      ),
                      GestureDetector(
                        child: Image.asset('assets/luxes.png', height: 50),
                      ),
                      GestureDetector(
                        child: Image.asset('assets/humidity.jpg', height: 50),
                      ),
                      GestureDetector(
                        child: Image.asset(
                          'assets/temperature.png',
                          height: 50,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 200, child: LinearChartWidget()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//https://www.youtube.com/watch?v=0PxX6LMnmwo&list=PLNF7sp688eT8gImxZlw4D0LhOwykuuskL
class Flower extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint flowerPlotPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;
    flowerPlotPaint.strokeWidth = 5;

    Paint stemPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke;
    stemPaint.strokeWidth = 5;

    Paint flowerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke;
    flowerPaint.strokeWidth = 5;

    canvas.translate(-10, 40);

    final flowerpot = Path()
      ..moveTo(size.width * 0.4, size.height * 0.7)
      // Linea abajo
      ..lineTo(size.width * 0.6, size.height * 0.7)
      // Linea curva derecha
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.5,
        size.width * 0.75,
        size.height * 0.3,
      )
      // Linea arriba
      ..lineTo(size.width * 0.25, size.height * 0.3)
      // Linea curva izquierda
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.5,
        size.width * 0.4,
        size.height * 0.7,
      )
      ..close();

    final stemPlant = Path()
      ..moveTo(size.width * 0.5, size.height * 0.3)
      ..lineTo(size.width * 0.5, size.height * -0.2)
      ..moveTo(size.width * 0.5, size.height * 0.1)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * -0.2,
        size.width * 0.2,
        size.height * -0.15,
      )
      ..close();

    final flowerPlant = Path()
      ..moveTo(size.width * 0.75, size.height * -0.5)
      // Linea abajo
      ..lineTo(size.width * 0.75, size.height * -0.5)
      // Linea curva derecha
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * -0.5,
        size.width * 0.8,
        size.height * -0.5,
      )
      // Linea arriba
      ..lineTo(size.width * 0.25, size.height * -0.5)
      // Linea curva izquierda
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * -0.1,
        size.width * 0.75,
        size.height * -0.2,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * -0.1,
        size.width * 0.75,
        size.height * -0.2,
      )
      ..close();

    canvas.drawPath(flowerpot, flowerPlotPaint);
    canvas.drawPath(stemPlant, stemPaint);
    // Iba a hacer como una flor con la parte de abajo
    canvas.drawPath(flowerPlant, flowerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
