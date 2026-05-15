import 'package:flutter/material.dart';

class MapMarker extends StatelessWidget {
  final Color color;
  final bool isStart;
  const MapMarker({super.key, required this.color, required this.isStart});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Icon(isStart ? Icons.my_location_rounded : Icons.location_on_rounded, color: color, size: 20),
      ],
    );
  }
}
