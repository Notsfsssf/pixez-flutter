import 'package:flutter/material.dart';

class BenchmarkSection extends StatelessWidget {
  final String title;
  final List<List<Widget>> children;

  const BenchmarkSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: children.map((column) {
            return Column(
              children: column,
            );
          }).toList(),
        ),
      ],
    );
  }
}
