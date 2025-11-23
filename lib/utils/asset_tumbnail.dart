import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class AssetTumbnail extends StatelessWidget {
  final AssetEntity asset;
  const AssetTumbnail({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: asset.thumbnailData.then((value) => value!),
      builder: (_, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return const CircularProgressIndicator();
        return Image.memory(bytes, fit: BoxFit.cover);
      },
    );
  }
}
