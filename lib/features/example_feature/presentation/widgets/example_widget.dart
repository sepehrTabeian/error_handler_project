import 'package:flutter/material.dart';

import '../../domain/entities/example_entity.dart';

/// Widget displaying a single example entity.
///
/// This is a reusable widget that can be used in different contexts.
/// It should be focused and do one thing well.
class ExampleWidget extends StatelessWidget {
  final ExampleEntity example;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExampleWidget({
    required this.example,
    this.onTap,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(example.name),
        subtitle: Text(example.description),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
