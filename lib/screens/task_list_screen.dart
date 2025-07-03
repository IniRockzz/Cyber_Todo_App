import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task.dart';
import '../models/task_priority.dart';
import '../models/task_status.dart';
import 'settings.dart';
import 'task_edit_screen.dart';
import 'task_search_delegate.dart';

class TaskHubScreen extends StatefulWidget {
  const TaskHubScreen({super.key});

  @override
  State<TaskHubScreen> createState() => _TaskHubScreenState();
}

class _TaskHubScreenState extends State<TaskHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  TaskPriority? _priorityFilter;
  DateTime? _dueDateFilter;

  String _searchInput = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final theme = context.watch<ThemeProvider>();

    // Apply filtering
    final all = _filterTasks(tasks.tasks);
    final open = _filterTasks(tasks.openTasks);
    final done = _filterTasks(tasks.completedTasks);

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(auth),
        flexibleSpace: _buildGradientBackground(),
        bottom: _buildTabBar(all.length, open.length, done.length),
        actions: _buildActions(context, theme, auth),
      ),
      body: Column(
        children: [
          if (_dueDateFilter != null) _buildActiveDateFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildTaskList(all, tasks),
                _buildTaskList(open, tasks),
                _buildTaskList(done, tasks),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TaskEditScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      ),
    );
  }

  Widget _buildAppBarTitle(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cyber Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
        if (auth.user != null)
          Text(
            auth.user!.email ?? 'No email',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
      ],
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTabBar(int all, int open, int done) {
    return TabBar(
      controller: _tabs,
      tabs: [
        _buildTab('All', all),
        _buildTab('Open', open),
        _buildTab('Done', done),
      ],
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: badges.Badge(
        badgeContent: Text('$count', style: const TextStyle(fontSize: 10)),
        child: Text(label),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ThemeProvider theme, AuthProvider auth) {
    return [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          showSearch(
            context: context,
            delegate: TaskSearchDelegate(Provider.of<TaskProvider>(context, listen: false).tasks),
          );
        },
      ),
      IconButton(icon: const Icon(Icons.filter_alt), onPressed: _showFilterModal),
      IconButton(
        icon: Icon(theme.isDark ? Icons.dark_mode : Icons.light_mode),
        onPressed: () => theme.toggleTheme(),
      ),
      PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'settings') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          } else if (value == 'logout') {
            _confirmLogout(context, auth);
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'settings', child: Text('Settings')),
          const PopupMenuItem(value: 'logout', child: Text('Logout')),
        ],
      )
    ];
  }

  Widget _buildActiveDateFilter() {
    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Due: ${DateFormat.yMMMd().format(_dueDateFilter!)}', style: const TextStyle(color: Colors.redAccent)),
          IconButton(
            icon: const Icon(Icons.clear, size: 16),
            onPressed: () => setState(() => _dueDateFilter = null),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterModal() async {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Filter by Date'),
              onTap: () {
                Navigator.pop(context);
                _pickDueDate();
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Filter by Priority'),
              onTap: () {
                Navigator.pop(context);
                _pickPriority();
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Filters'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _priorityFilter = null;
                  _dueDateFilter = null;
                  _searchInput = '';
                });
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDateFilter = picked);
    }
  }

  Future<void> _pickPriority() async {
    final selected = await showDialog<TaskPriority?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Select Priority'),
        children: TaskPriority.values
            .map((p) => SimpleDialogOption(
          child: Text(p.name.toUpperCase()),
          onPressed: () => Navigator.pop(ctx, p),
        ))
            .toList(),
      ),
    );
    if (selected != null) {
      setState(() => _priorityFilter = selected);
    }
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await auth.signOut();
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((t) {
      final matchesSearch = _searchInput.isEmpty ||
          t.title.toLowerCase().contains(_searchInput.toLowerCase()) ||
          (t.description?.toLowerCase().contains(_searchInput.toLowerCase()) ?? false);

      final matchesPriority = _priorityFilter == null || t.priority == _priorityFilter;

      final matchesDueDate = _dueDateFilter == null ||
          (t.dueDate?.year == _dueDateFilter!.year &&
              t.dueDate?.month == _dueDateFilter!.month &&
              t.dueDate?.day == _dueDateFilter!.day);

      return matchesSearch && matchesPriority && matchesDueDate;
    }).toList();
  }

  Widget _buildTaskList(List<Task> tasks, TaskProvider provider) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks found', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (ctx, i) {
        final task = tasks[i];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 2,
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(task.description ?? ''),
            trailing: Checkbox(
              value: task.status == TaskStatus.complete,
              onChanged: (_) => provider.toggleComplete(task.id),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TaskEditScreen(task: task)),
              );
            },
            onLongPress: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: Text('Delete "${task.title}"?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    )
                  ],
                ),
              );
              if (confirm == true) {
                provider.deleteTask(task.id);
              }
            },
          ),
        );
      },
    );
  }
}
