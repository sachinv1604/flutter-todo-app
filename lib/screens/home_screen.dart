import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_item.dart';
import '../widgets/add_todo_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SACHIN KA TODO LIST', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20),
                    SizedBox(width: 8),
                    Text('Clear Completed'),
                  ],
                ),
                onTap: () {
                  final provider = Provider.of<TodoProvider>(context, listen: false);
                  if (provider.completedTodos > 0) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Completed?'),
                        content: Text(
                          'This will delete ${provider.completedTodos} completed todo(s).',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              provider.deleteCompletedTodos();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No completed todos to delete')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Cards
          Consumer<TodoProvider>(
            builder: (context, provider, child) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildStatCard(
                      'Total',
                      provider.totalTodos,
                      Colors.blue,
                      Icons.list,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Pending',
                      provider.pendingTodos,
                      Colors.orange,
                      Icons.pending_actions,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Done',
                      provider.completedTodos,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ],
                ),
              );
            },
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search todos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<TodoProvider>(context, listen: false)
                              .setSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                Provider.of<TodoProvider>(context, listen: false)
                    .setSearchQuery(value);
              },
            ),
          ),

          // Filter Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Consumer<TodoProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    const Text('Show completed only:'),
                    const Spacer(),
                    Switch(
                      value: provider.showCompletedOnly,
                      onChanged: (value) {
                        provider.toggleShowCompletedOnly();
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          // Todo List
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, child) {
                final todos = provider.todos;

                if (todos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          provider.totalTodos == 0
                              ? 'No todos yet'
                              : 'No todos found',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.totalTodos == 0
                              ? 'Tap + to add your first todo'
                              : 'Try a different search',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    return TodoItem(todo: todos[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddTodoDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Todo'),
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}