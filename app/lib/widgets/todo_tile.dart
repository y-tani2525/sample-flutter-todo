import 'package:flutter/cupertino.dart';
import '../models/todo_item.dart';

class TodoTile extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              todo.done
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.circle,
              color: todo.done
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemGrey,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 16,
                decoration:
                    todo.done ? TextDecoration.lineThrough : TextDecoration.none,
                color:
                    todo.done ? CupertinoColors.systemGrey : CupertinoColors.label,
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onDelete,
            child: const Icon(
              CupertinoIcons.trash,
              color: CupertinoColors.destructiveRed,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
