import 'package:flutter/material.dart';

class StepsIndicator extends StatelessWidget {
  final String count;
  final String title;
  final String description;

  const StepsIndicator({
    super.key,
    required this.count,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            count,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Title
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Description
        Text(description, style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
