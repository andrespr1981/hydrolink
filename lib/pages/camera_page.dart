import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:hydrolink/utils/switch_color_btn.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/color_btn.dart';
import '../utils/pop_up_message.dart';
import '../utils/asset_tumbnail.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  String cameraIp = '10.202.81.50';
  final ValueNotifier<bool> flashOn = ValueNotifier<bool>(false);

  bool savePhotoPermission = false;
  bool readPhotosPermission = false;

  List<AssetEntity> assets = [];

  //Variable para recargar el stream en caso de que algo pase
  late Key keyRefresh;

  //Inicializar el variable key con un valor
  @override
  void initState() {
    super.initState();
    checkGalleryPermission();
    keyRefresh = UniqueKey();
  }

  //Funcion para recargar el stream
  void refreshStream() {
    setState(() {
      keyRefresh = UniqueKey();
    });
  }

  Future<void> toggleFlash() async {
    final newState = !flashOn.value ? 'on' : 'off';
    final url = Uri.parse('http://$cameraIp/flash?state=$newState');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        flashOn.value = !flashOn.value;
      }
    } catch (e) {
      if (mounted) {
        showErrorMesage(
          context,
          'Ups...',
          'No se ha podido encender el flash.',
        );
      }
    }
  }

  Future<bool> checkGalleryPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      setState(() {
        readPhotosPermission = true;
      });
      loadAssets();
      return true;
    }
    return false;
  }

  Future<void> loadAssets() async {
    await PhotoManager.clearFileCache();

    AssetPathEntity? hydroLinkAlbum;

    final albumsList = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      hasAll: true,
    );

    for (var album in albumsList) {
      if (album.name == 'HydroLinkAlbum') {
        hydroLinkAlbum = album;
        break;
      }
    }

    if (hydroLinkAlbum == null) {
      setState(() {
        assets = [];
      });
      return;
    }

    final photos = await hydroLinkAlbum.getAssetListRange(start: 0, end: 200);

    setState(() {
      assets = photos;
    });
  }

  // Esta funcion limpia el cache para que las imagenes se puedan mostrar despues de guardar una nueva
  Future<void> onPhotoSaved() async {
    PhotoManager.clearFileCache();

    await Future.delayed(Duration(milliseconds: 300));
    await loadAssets();
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
              refreshStream();
            },
            icon: Icon(Icons.refresh_rounded),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.settings)),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(16.0),
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  height: size.height * 0.45,
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
                    children: [
                      Padding(
                        padding: EdgeInsetsGeometry.only(top: 16.0),
                        child: Mjpeg(
                          stream: 'http://$cameraIp:81/stream',
                          key: keyRefresh,
                          isLive: true,
                          timeout: Duration(seconds: 10),
                          error: (contet, error, stack) {
                            return Text(
                              'Ups... No se pudo conectar con la camara',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: flashOn,
                            builder: (_, isOn, _) {
                              return SwitchColorBtn(
                                textTrue: 'Apagar Flash',
                                textFalse: 'Encender Flash',
                                colorsTrue: const [Colors.red, Colors.orange],
                                colorsFalse: const [
                                  Colors.blue,
                                  Colors.lightBlueAccent,
                                ],
                                state: isOn,
                                onTap: () {
                                  toggleFlash();
                                },
                              );
                            },
                          ),
                          ColorBtn(
                            text: 'Tomar foto',
                            colors: const [Colors.blue, Colors.lightBlueAccent],
                            onTap: () async {
                              shotAndSave();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: size.height * 0.45,
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
                    children: [
                      SizedBox(height: 20),
                      Text('Galeria'),
                      SizedBox(height: 20),
                      readPhotosPermission
                          ? SizedBox(
                              height: 250,
                              width: size.width * 0.85,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                    ),
                                itemCount: assets.length,
                                itemBuilder: (_, index) {
                                  return Padding(
                                    padding: EdgeInsetsGeometry.all(1),
                                    child: AssetTumbnail(asset: assets[index]),
                                  );
                                },
                              ),
                            )
                          : ColorBtn(
                              text: 'Soliciar permiso',
                              colors: const [
                                Colors.blue,
                                Colors.lightBlueAccent,
                              ],
                              onTap: () async {},
                            ),
                    ],
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void shotAndSave() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdk = androidInfo.version.sdkInt;

      final status = sdk >= 33
          //Este es para Android 13+
          ? await Permission.photos.request()
          //Y este es para Android 13-
          : await Permission.storage.request();

      if (!status.isGranted) return;
    }

    final response = await http.get(Uri.parse('http://$cameraIp/capture'));
    final bytes = response.bodyBytes;

    await PhotoManager.editor.saveImage(
      bytes,
      filename: "hydrolink_${DateTime.now().millisecondsSinceEpoch}.jpg",
      relativePath: "Pictures/HydroLinkAlbum",
    );

    await onPhotoSaved();
  }
}
