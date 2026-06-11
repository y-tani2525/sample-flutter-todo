import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';
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

  void _toggleTodo(int index) {
    setState(() {
      _todos[index] = _todos[index].copyWith(done: !_todos[index].done);
    });
    _saveTodos();
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  void _editTodo(int index) {
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
            Expanded(
              child: _todos.isEmpty
                  ? const Center(
                      child: Text(
                        'タスクがありません',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _todos.length,
                      separatorBuilder: (_, __) => Container(
                        height: 0.5,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: CupertinoColors.separator,
                      ),
                      itemBuilder: (context, index) => TodoTile(
                        todo: _todos[index],
                        onToggle: () => _toggleTodo(index),
                        onDelete: () => _removeTodo(index),
                        onEdit: () => _editTodo(index),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
