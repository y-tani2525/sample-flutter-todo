import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';
import '../models/todo_filter.dart';
import '../widgets/todo_tile.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  static const _storageKey = 'todos';

  final List<TodoItem> _todos = [];
  final TextEditingController _controller = TextEditingController();
  TodoFilter _filter = TodoFilter.all;

  List<TodoItem> get _filteredTodos {
    switch (_filter) {
      case TodoFilter.all:
        return _todos;
      case TodoFilter.active:
        return _todos.where((t) => !t.done).toList();
      case TodoFilter.done:
        return _todos.where((t) => t.done).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return;
    setState(() {
      _todos.addAll(TodoItem.listFromJson(jsonStr));
    });
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, TodoItem.listToJson(_todos));
  }

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.add(TodoItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: text,
      ));
      _controller.clear();
    });
    _saveTodos();
  }

  void _toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;
    setState(() {
      _todos[index] = _todos[index].copyWith(done: !_todos[index].done);
    });
    _saveTodos();
  }

  void _removeTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
    _saveTodos();
  }

  void _editTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final controller = TextEditingController(text: _todos[index].title);
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('タスクを編集'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            onSubmitted: (_) => _saveEdit(context, index, controller),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          CupertinoDialogAction(
            onPressed: () => _saveEdit(context, index, controller),
            child: const Text('保存'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _saveEdit(
    BuildContext context,
    int index,
    TextEditingController controller,
  ) {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _todos[index] = _todos[index].copyWith(title: text);
      });
      _saveTodos();
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTodos;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Todo'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: _controller,
                      placeholder: 'タスクを入力',
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      onSubmitted: (_) => _addTodo(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _addTodo,
                    child: const Icon(
                      CupertinoIcons.add_circled_solid,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: CupertinoSlidingSegmentedControl<TodoFilter>(
                groupValue: _filter,
                onValueChanged: (value) {
                  if (value != null) setState(() => _filter = value);
                },
                children: const {
                  TodoFilter.all: Text('すべて'),
                  TodoFilter.active: Text('未完了'),
                  TodoFilter.done: Text('完了済み'),
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        _todos.isEmpty ? 'タスクがありません' : '該当するタスクがありません',
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: CupertinoColors.separator,
                      ),
                      itemBuilder: (context, index) {
                        final todo = filtered[index];
                        return TodoTile(
                          todo: todo,
                          onToggle: () => _toggleTodo(todo.id),
                          onDelete: () => _removeTodo(todo.id),
                          onEdit: () => _editTodo(todo.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
