import 'package:flutter/material.dart';

class EventsButton extends StatelessWidget {
  const EventsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF4A4A4A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'lib/assets/icons/Vector2.png',
            width: 20,
            height: 20,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          const Text(
            'Events',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}