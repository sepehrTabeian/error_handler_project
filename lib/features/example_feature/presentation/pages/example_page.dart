import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/example_request_entity.dart';
import '../bloc/example_bloc.dart';
import '../bloc/example_event.dart';
import '../bloc/example_state.dart';
import '../widgets/example_widget.dart';

/// Page displaying the example feature.
///
/// This is the screen-level widget for the example feature.
/// It sets up the BlocProvider and handles navigation.
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExampleBloc(
        getExampleUseCase: getIt(),
        createExampleUseCase: getIt(),
      ),
      child: const ExampleView(),
    );
  }
}

/// The actual view widget for the example feature.
///
/// This widget contains the UI logic and is separate from the BlocProvider setup.
class ExampleView extends StatelessWidget {
  const ExampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example Feature'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ExampleBloc, ExampleState>(
        builder: (context, state) {
          if (state is ExampleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExampleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ExampleBloc>().add(const ExamplesRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ExampleLoaded) {
            if (state.examples.isEmpty) {
              return const Center(child: Text('No examples found'));
            }

            return ListView.builder(
              itemCount: state.examples.length,
              itemBuilder: (context, index) {
                final example = state.examples[index];
                return ExampleWidget(
                  example: example,
                  onTap: () {
                    // TODO: Navigate to detail view
                  },
                  onDelete: () {
                    context.read<ExampleBloc>().add(ExampleDeleted(example.id));
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Example'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final request = ExampleRequestEntity(
                name: nameController.text,
                description: descriptionController.text,
              );
              context.read<ExampleBloc>().add(ExampleCreated(request));
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
