import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class AdvancedControlsRow extends StatelessWidget {
  const AdvancedControlsRow({super.key});

  @override
  Widget build(BuildContext context) {
    double size = 28;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            iconSize: size,
            onPressed: () async {},
          ),
          IconButton(
            icon: const Icon(Icons.speed_outlined),
            iconSize: size,
            onPressed: () async {},
          ),
          IconButton(
            icon: const Icon(Iconsax.moon_outline),
            iconSize: size - 4,
            onPressed: () async {},
          ),
          IconButton(
            icon: const Icon(Icons.list_outlined),
            iconSize: size,
            onPressed: () async {},
          ),
        ],
      ),
    );
  }
}
