import 'package:flutter/material.dart';

import '../utils/color_btn.dart';
import '../utils/database.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(actions: [
          
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Container(
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
                SizedBox(height: 10),
                ColorBtn(
                  text: 'Eliminar base de datos',
                  colors: const [Colors.red, Colors.orange],
                  onTap: () async {
                    await LocalDatabase().clearAllData();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
