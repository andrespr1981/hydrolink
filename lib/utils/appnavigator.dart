import 'package:flutter/material.dart';
import '../pages/wifi_page.dart';
import '../pages/blu_page.dart';
import '../pages/camera_page.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int myCurrentIndex = 0;
  final List pages = [HomePage(), BluPage(), CameraPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: pages[myCurrentIndex]),
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BottomNavigationBar(
                  currentIndex: myCurrentIndex,
                  backgroundColor: Colors.white.withOpacity(0.95),
                  selectedItemColor: Colors.green,
                  unselectedItemColor: Colors.black,
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    height: 1.0,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    height: 1.0,
                  ),
                  iconSize: 24,
                  onTap: (index) {
                    setState(() {
                      myCurrentIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.wifi),
                      label: 'WIFI',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bluetooth),
                      label: 'BLUETOOTH',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt),
                      label: 'CAMARA',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
