import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../constants/test_keys.dart';

/// A card widget that displays a single [Task] with a checkbox,
/// priority badge, optional due date, and a popup menu for edit/delete.
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = Color(task.priority.colorValue);

    return AnimatedContainer(
      key: Key(TestKeys.taskItem(task.id)),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted
              ? Colors.white.withValues(alpha: 0.04)
              : priorityColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Semantics(
            identifier: TestKeys.taskItemCheckbox(task.id),
            child: GestureDetector(
              key: Key(TestKeys.taskItemCheckbox(task.id)),
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? const Color(0xFF10B981)
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? const Color(0xFF10B981)
                        : Colors.white38,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.white38 : Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: Colors.white38,
                    decorationThickness: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Description
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    task.description,
                    style: TextStyle(
                      color: task.isCompleted
                          ? Colors.white24
                          : const Color(0xFF71717A),
                      fontSize: 12,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Colors.white24,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                // Meta row: priority badge + due date
                Row(
                  children: [
                    // Priority badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.priority.label,
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Due date
                    if (task.dueDate != null) ...[
                      const SizedBox(width: 8),
                      _DueDateBadge(
                        dueDate: task.dueDate!,
                        isCompleted: task.isCompleted,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Popup menu
          PopupMenuButton<String>(
            key: Key(TestKeys.taskItemMenu(task.id)),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_vert, color: Colors.white38, size: 22),
            color: const Color(0xFF2A2738),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Edit',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.redAccent, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final DateTime dueDate;
  final bool isCompleted;

  const _DueDateBadge({required this.dueDate, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final isOverdue = !isCompleted && due.isBefore(today);
    final isToday = due == today;

    Color badgeColor;
    String label;
    if (isCompleted) {
      badgeColor = Colors.white24;
      label = DateFormat('MMM d').format(dueDate);
    } else if (isOverdue) {
      badgeColor = const Color(0xFFEF4444);
      label = 'Overdue';
    } else if (isToday) {
      badgeColor = const Color(0xFFF59E0B);
      label = 'Today';
    } else {
      badgeColor = Colors.white38;
      label = DateFormat('MMM d').format(dueDate);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.calendar_today_outlined, color: badgeColor, size: 11),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: badgeColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
