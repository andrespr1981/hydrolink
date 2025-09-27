import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'dart:typed_data';

import '../utils/pop_up_message.dart';

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
            print("Conectado a $targetDeviceName");
            setState(() => isConnected = true);

            // Descubrir servicios
            List<BluetoothService> services = await device!.discoverServices();
            for (var s in services) {
              if (s.uuid.toString() == serviceUuid) {
                for (var c in s.characteristics) {
                  if (c.uuid.toString() == characteristicUuid) {
                    characteristic = c;
                    print("Characteristic lista");
                    await characteristic!.setNotifyValue(true);
                    characteristic!.lastValueStream.listen((value) {
                      String msg = String.fromCharCodes(value);
                      print("Mensaje recibido: $msg");
                    });
                  }
                }
              }
            }
          } catch (e) {
            print("Error al conectar: $e");
          }
        }
      }
    });
  }

  void sendData(String text) async {
    if (characteristic != null && isConnected) {
      // Convertimos String a bytes
      Uint8List bytes = Uint8List.fromList(text.codeUnits);
      await characteristic!.write(bytes, withoutResponse: false);
      print("Enviado: $text");
    } else {
      print("No conectado o característica nula");
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
    return Scaffold(
      appBar: AppBar(title: const Text("BLE ESP32")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(isConnected ? "Conectado al ESP32" : "Desconectado"),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Mensaje a enviar"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                sendData(controller.text);
                controller.clear();
              },
              child: const Text("Enviar"),
            ),
            ElevatedButton(
              onPressed: () {
                scanAndConnect();
              },
              child: Text('Conectar'),
            ),
            ElevatedButton(
              onPressed: () {
                showMessage(
                  context,
                  Colors.red,
                  'images/bad_plant.png',
                  'Prueba 1',
                  'Prueba 2',
                );
              },
              child: Text('Error'),
            ),
          ],
        ),
      ),
    );
  }
}
