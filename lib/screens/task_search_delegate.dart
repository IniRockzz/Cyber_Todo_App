import 'package:flutter/material.dart';
import '../models/task.dart';
import '../screens/task_edit_screen.dart';

class TaskSearchDelegate extends SearchDelegate<Task?> {
  final List<Task> allTasks;

  TaskSearchDelegate(this.allTasks);

  @override
  String? get searchFieldLabel => 'Search tasks...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allTasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('No matching tasks found.'));
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final task = results[i];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description ?? ''),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TaskEditScreen(task: task)),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allTasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
          (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, i) {
        final task = suggestions[i];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description ?? ''),
          onTap: () {
            query = task.title;
            showResults(context);
          },
        );
      },
    );
  }
}
