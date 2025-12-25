import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';

class TodoProvider extends ChangeNotifier {
  static const String _boxName = 'todos';
  Box<Todo>? _todoBox;
  List<Todo> _todos = [];
  String _searchQuery = '';
  bool _showCompletedOnly = false;

  List<Todo> get todos {
    List<Todo> filtered = _todos;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            todo.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply completion filter
    if (_showCompletedOnly) {
      filtered = filtered.where((todo) => todo.isCompleted).toList();
    }

    return filtered;
  }

  int get totalTodos => _todos.length;
  int get completedTodos => _todos.where((t) => t.isCompleted).length;
  int get pendingTodos => _todos.where((t) => !t.isCompleted).length;

  bool get showCompletedOnly => _showCompletedOnly;

  // Initialize Hive and load todos
  Future<void> init() async {
    _todoBox = await Hive.openBox<Todo>(_boxName);
    _loadTodos();
  }

  void _loadTodos() {
    _todos = _todoBox?.values.toList() ?? [];
    _todos.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
    notifyListeners();
  }

  // Add new todo
  Future<void> addTodo(String title, String description) async {
    final todo = Todo(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );

    await _todoBox?.add(todo);
    _loadTodos();
  }

  // Update todo
  Future<void> updateTodo(Todo todo, String title, String description) async {
    todo.title = title;
    todo.description = description;
    await todo.save();
    _loadTodos();
  }

  // Toggle completion
  Future<void> toggleTodo(Todo todo) async {
    todo.toggleCompleted();
    _loadTodos();
  }

  // Delete todo
  Future<void> deleteTodo(Todo todo) async {
    await todo.delete();
    _loadTodos();
  }

  // Delete all completed todos
  Future<void> deleteCompletedTodos() async {
    final completed = _todos.where((t) => t.isCompleted).toList();
    for (var todo in completed) {
      await todo.delete();
    }
    _loadTodos();
  }

  // Search
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Filter
  void toggleShowCompletedOnly() {
    _showCompletedOnly = !_showCompletedOnly;
    notifyListeners();
  }

  // Clear all todos (for testing)
  Future<void> clearAll() async {
    await _todoBox?.clear();
    _loadTodos();
  }
}