import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'todo_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _todosKey = 'todos_list';
  List<TodoItem> _todos = [];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // ─── Persistence ────────────────────────────────────────────────────────────

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_todosKey) ?? [];
    setState(() {
      _todos = raw.map((e) => TodoItem.fromJson(e)).toList();
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_todosKey, _todos.map((e) => e.toJson()).toList());
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────────

  void _addTodo(TodoItem item) {
    setState(() => _todos.add(item));
    _saveTodos();
  }

  void _updateTodo(int index, TodoItem updated) {
    setState(() => _todos[index] = updated);
    _saveTodos();
  }

  void _deleteTodo(int index) {
    setState(() => _todos.removeAt(index));
    _saveTodos();
  }

  void _toggleDone(int index) {
    setState(() =>
        _todos[index] = _todos[index].copyWith(isDone: !_todos[index].isDone));
    _saveTodos();
  }

  // ─── Dialogs ─────────────────────────────────────────────────────────────────

  void _showTodoDialog({int? editIndex}) {
    final isEditing = editIndex != null;
    final existing = isEditing ? _todos[editIndex] : null;

    final titleController =
        TextEditingController(text: existing?.title ?? '');
    Urgency urgency = existing?.urgency ?? Urgency.lessUrgent;
    Importance importance =
        existing?.importance ?? Importance.lessImportant;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(isEditing ? 'Edit Task' : 'New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title field
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task title',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Urgency
                const Text('Urgency',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ToggleButtons(
                  isSelected: [
                    urgency == Urgency.urgent,
                    urgency == Urgency.lessUrgent,
                  ],
                  onPressed: (i) =>
                      setLocal(() => urgency = Urgency.values[i]),
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('🔴 Urgent')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('🟡 Less Urgent')),
                  ],
                ),
                const SizedBox(height: 12),

                // Importance
                const Text('Importance',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ToggleButtons(
                  isSelected: [
                    importance == Importance.important,
                    importance == Importance.lessImportant,
                  ],
                  onPressed: (i) =>
                      setLocal(() => importance = Importance.values[i]),
                  borderRadius: BorderRadius.circular(8),
                  children: const [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('⭐ Important')),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('📌 Less Important')),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                final item = TodoItem(
                  id: existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  isDone: existing?.isDone ?? false,
                  urgency: urgency,
                  importance: importance,
                );
                if (isEditing) {
                  _updateTodo(editIndex, item);
                } else {
                  _addTodo(item);
                }
                Navigator.pop(ctx);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text(
            'Are you sure you want to delete "${_todos[index].title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteTodo(index);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── UI Helpers ──────────────────────────────────────────────────────────────

  Color _urgencyColor(Urgency u) => u == Urgency.urgent
      ? const Color(0xFFE63946)
      : const Color(0xFFF4A261);

  Color _importanceColor(Importance i) => i == Importance.important
      ? const Color(0xFF2D6A4F)
      : const Color(0xFF74B69E);

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600)),
      );

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 6, top: 4),
        child: Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.grey)),
      );

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final pending = _todos.where((t) => !t.isDone).toList();
    final done = _todos.where((t) => t.isDone).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('My Tasks'),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No tasks yet. Tap + to add one.',
                      style:
                          TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (pending.isNotEmpty) ...[
                  _sectionHeader('Pending (${pending.length})'),
                  ...pending.map((todo) =>
                      _buildTodoCard(todo, _todos.indexOf(todo))),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _sectionHeader('Done (${done.length})'),
                  ...done.map((todo) =>
                      _buildTodoCard(todo, _todos.indexOf(todo))),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTodoDialog(),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildTodoCard(TodoItem todo, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (_) => _toggleDone(index),
          activeColor: const Color(0xFF2D6A4F),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration:
                todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            children: [
              _tag(
                todo.urgency == Urgency.urgent
                    ? '🔴 Urgent'
                    : '🟡 Less Urgent',
                _urgencyColor(todo.urgency),
              ),
              _tag(
                todo.importance == Importance.important
                    ? '⭐ Important'
                    : '📌 Less Important',
                _importanceColor(todo.importance),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _showTodoDialog(editIndex: index),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: Colors.redAccent),
              onPressed: () => _confirmDelete(index),
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}