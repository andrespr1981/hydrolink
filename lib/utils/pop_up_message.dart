import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showMessage(
  BuildContext context,
  Color color,
  String image,
  String title,
  String message,
) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            height: 100,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0, 0, 0, 0, 255, // Red
                    0, 0, 0, 0, 255, // Green
                    0, 0, 0, 0, 255, // Blue
                    0, 0, 0, 1, 0, // Alpha
                  ]),
                  child: Image.asset(image),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      Text(
                        message,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  icon: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
