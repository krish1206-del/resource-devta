import 'package:flutter/material.dart';

class PriorityBadge extends StatelessWidget {
  final double score;

  const PriorityBadge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final normalized = (score / 100).clamp(0.0, 1.0);
    final color = Color.lerp(cs.secondaryContainer, cs.errorContainer, normalized)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        score.toStringAsFixed(0),
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}

