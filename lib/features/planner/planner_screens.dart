import 'package:flutter/material.dart';

import '../../data/planner_store.dart';
import '../../ui/planner_design.dart';

class PlannerHomeScreen extends StatelessWidget {
  const PlannerHomeScreen({required this.store, super.key});

  final PlannerStore store;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => PlannerPage(
      title: 'Planner',
      subtitle: 'Choose a view, then make a little room for what matters.',
      actions: [
        IconButton(
          tooltip: 'Add task',
          onPressed: () => _push(context, TaskFormScreen(store: store)),
          icon: const Icon(Icons.add),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreviewBanner(),
          const SizedBox(height: 16),
          if (store.isLoading)
            const LinearProgressIndicator(
              semanticsLabel: 'Loading saved tasks',
            ),
          if (store.persistenceError != null) ...[
            PlannerCard(
              color: const Color(0xFFFFE4E1),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    color: PlannerColors.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(store.persistenceError!)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          PlannerCard(
            color: PlannerColors.deepPurple,
            onTap: () => _push(context, const DeadlineRadarScreen()),
            child: const Row(
              children: [
                Icon(Icons.radar_rounded, color: PlannerColors.lime, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deadline Radar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'See what needs attention next.',
                        style: TextStyle(
                          color: Color(0xFFEAE5FF),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeading(title: 'Plan your time'),
          const SizedBox(height: 10),
          _PlannerAction(
            title: 'Calendar',
            detail: 'See your week and upcoming dates',
            icon: Icons.calendar_month_rounded,
            color: PlannerColors.lavender,
            onTap: () => _push(context, const CalendarViewScreen()),
          ),
          const SizedBox(height: 9),
          _PlannerAction(
            title: 'Timetable',
            detail: 'Review classes and study blocks',
            icon: Icons.calendar_view_week_rounded,
            color: PlannerColors.aqua,
            onTap: () => _push(context, const TimetableViewScreen()),
          ),
          const SizedBox(height: 9),
          _PlannerAction(
            title: 'All tasks',
            detail: '${store.openTasks.length} still to do',
            icon: Icons.checklist_rounded,
            color: PlannerColors.blush,
            onTap: () => _push(context, TaskListScreen(store: store)),
          ),
          const SizedBox(height: 9),
          _PlannerAction(
            title: 'AI Academic Copilot',
            detail: 'Explore a clearly labeled offline preview',
            icon: Icons.auto_awesome_rounded,
            color: PlannerColors.butter,
            onTap: () => _push(context, const CopilotScreen()),
          ),
        ],
      ),
    ),
  );
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({required this.store, super.key});

  final PlannerStore store;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  TaskCategory? category;
  bool showCompleted = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) {
      final query = _searchController.text.trim().toLowerCase();
      final filtered = widget.store.tasks.where((task) {
        return task.title.toLowerCase().contains(query) &&
            (category == null || task.category == category) &&
            (showCompleted || !task.isCompleted);
      }).toList();

      return PlannerPage(
        title: 'All tasks',
        subtitle: 'Academic and personal plans, kept easy to scan.',
        actions: [
          IconButton(
            tooltip: 'Create task',
            onPressed: () =>
                _push(context, TaskFormScreen(store: widget.store)),
            icon: const Icon(Icons.add),
          ),
        ],
        child: Column(
          children: [
            const PreviewBanner(),
            const SizedBox(height: 14),
            if (widget.store.isLoading)
              const LinearProgressIndicator(
                semanticsLabel: 'Loading saved tasks',
              ),
            if (widget.store.persistenceError != null) ...[
              PlannerCard(
                color: const Color(0xFFFFE4E1),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      color: PlannerColors.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(widget.store.persistenceError!)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                filled: true,
                fillColor: PlannerColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: category == null,
                  onSelected: (_) => setState(() => category = null),
                ),
                for (final option in TaskCategory.values)
                  FilterChip(
                    label: Text(_categoryLabel(option)),
                    selected: category == option,
                    onSelected: (_) => setState(
                      () => category = category == option ? null : option,
                    ),
                  ),
                FilterChip(
                  label: const Text('Hide completed'),
                  selected: !showCompleted,
                  onSelected: (_) =>
                      setState(() => showCompleted = !showCompleted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (filtered.isEmpty)
              EmptyState(
                title: 'No matching tasks',
                message: query.isEmpty
                    ? 'Add a task to begin your list.'
                    : 'Try a different search or filter.',
                icon: Icons.search_off_rounded,
                actionLabel: query.isEmpty ? 'Add task' : null,
                onAction: query.isEmpty
                    ? () => _push(context, TaskFormScreen(store: widget.store))
                    : null,
              )
            else
              for (final task in filtered)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TaskListTile(
                    task: task,
                    onToggle: (value) => widget.store.toggleTask(task, value),
                    onTap: () => _push(
                      context,
                      TaskDetailScreen(store: widget.store, task: task),
                    ),
                  ),
                ),
          ],
        ),
      );
    },
  );
}

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({required this.store, required this.task, super.key});

  final PlannerStore store;
  final PlannerTask task;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => PlannerPage(
      title: 'Task details',
      subtitle: 'Preview task · stored in memory only.',
      actions: [
        IconButton(
          tooltip: 'Edit task',
          onPressed: () =>
              _push(context, TaskFormScreen(store: store, existing: task)),
          icon: const Icon(Icons.edit_outlined),
        ),
        IconButton(
          tooltip: 'Delete task',
          onPressed: () => _delete(context),
          icon: const Icon(Icons.delete_outline),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlannerCard(
            color: task.isCompleted
                ? PlannerColors.aqua
                : PlannerColors.lavender,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    color: PlannerColors.ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailLine(
                  icon: Icons.calendar_today_outlined,
                  label: task.dueLabel,
                ),
                _DetailLine(
                  icon: Icons.category_outlined,
                  label: _categoryLabel(task.category),
                ),
                _DetailLine(
                  icon: Icons.flag_outlined,
                  label: _priorityLabel(task.priority),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Completed'),
                  value: task.isCompleted,
                  onChanged: (value) => store.toggleTask(task, value),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _delete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this task?'),
        content: Text('“${task.title}” will be removed from this preview.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    store.deleteTask(task);
    if (context.mounted) {
      Navigator.of(context).pop();
      showPlannerMessage(context, 'Task deleted.');
    }
  }
}

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({
    required this.store,
    super.key,
    this.existing,
    this.isAssignment = false,
  });

  final PlannerStore store;
  final PlannerTask? existing;
  final bool isAssignment;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController titleController;
  late final TextEditingController dueController;
  late TaskCategory category;
  late TaskPriority priority;

  bool get isAssignment =>
      widget.isAssignment || widget.existing?.isAssignment == true;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.existing?.title ?? '');
    dueController = TextEditingController(
      text: widget.existing?.dueLabel ?? '',
    );
    category =
        widget.existing?.category ??
        (widget.isAssignment ? TaskCategory.academic : TaskCategory.personal);
    priority = widget.existing?.priority ?? TaskPriority.normal;
  }

  @override
  void dispose() {
    titleController.dispose();
    dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: widget.existing != null
        ? 'Edit ${isAssignment ? 'assignment' : 'task'}'
        : 'Create ${isAssignment ? 'assignment' : 'task'}',
    subtitle: 'This preview keeps changes in memory only.',
    child: Form(
      key: _formKey,
      child: Column(
        children: [
          const PreviewBanner(),
          const SizedBox(height: 14),
          PlannerCard(
            child: Column(
              children: [
                TextFormField(
                  controller: titleController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: isAssignment ? 'Assignment title' : 'Task title',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a title'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dueController,
                  decoration: InputDecoration(
                    labelText: 'Due date or reminder',
                    hintText: 'For example: Friday at 16:00',
                    prefixIcon: const Icon(Icons.event_outlined),
                    suffixIcon: IconButton(
                      tooltip: 'Choose a date',
                      onPressed: _chooseDate,
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskCategory>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final value in TaskCategory.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(_categoryLabel(value)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => category = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskPriority>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: [
                    for (final value in TaskPriority.values)
                      DropdownMenuItem(
                        value: value,
                        child: Text(_priorityLabel(value)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => priority = value);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Save preview'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      dueController.text = '${date.day}/${date.month}/${date.year}';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.store.saveTask(
      title: titleController.text.trim(),
      category: category,
      dueLabel: dueController.text.trim().isEmpty
          ? 'No due date'
          : dueController.text.trim(),
      priority: priority,
      existing: widget.existing,
      isAssignment: isAssignment,
    );
    Navigator.of(context).pop();
    showPlannerMessage(context, 'Saved in this session.');
  }
}

class DeadlineRadarScreen extends StatelessWidget {
  const DeadlineRadarScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Deadline Radar',
    subtitle: 'A transparent look at items that may need attention.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewBanner(),
        const SizedBox(height: 14),
        PlannerCard(
          color: PlannerColors.deepPurple,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.radar_rounded, color: PlannerColors.lime, size: 30),
              SizedBox(height: 10),
              Text(
                'No magic, just your dates.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'This preview sorts the due dates you entered. It does not estimate workload or connect to a university.',
                style: TextStyle(color: Color(0xFFEAE5FF), height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final item in const [
          ('Research reflection', 'Tomorrow · Academic', PlannerColors.blush),
          ('Finish assignment', 'Today · Academic', PlannerColors.lavender),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: PlannerCard(
              color: item.$3,
              child: Row(
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    color: PlannerColors.deepPurple,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            color: PlannerColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: PlannerColors.deepPurple,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        const Text(
          'Recommendations are not automatic. Review dates and priorities before changing your plan.',
          style: TextStyle(color: PlannerColors.mutedInk, fontSize: 11),
        ),
      ],
    ),
  );
}

class CalendarViewScreen extends StatelessWidget {
  const CalendarViewScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Calendar',
    subtitle: 'Week of today · tap a date to review its plans.',
    child: const _CalendarPreview(),
  );
}

class TimetableViewScreen extends StatelessWidget {
  const TimetableViewScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Timetable',
    subtitle: 'Preview schedule · times use your device timezone.',
    actions: [
      IconButton(
        tooltip: 'Add class',
        onPressed: () => showPlannerMessage(context, 'Class editor opened.'),
        icon: const Icon(Icons.add),
      ),
    ],
    child: const _TimetablePreview(),
  );
}

class CopilotScreen extends StatefulWidget {
  const CopilotScreen({super.key});

  @override
  State<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends State<CopilotScreen> {
  final controller = TextEditingController();
  String? preview;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Academic Copilot',
    subtitle: 'A UI preview only · no AI service is connected.',
    child: Column(
      children: [
        const PlannerCard(
          color: PlannerColors.lavender,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: PlannerColors.deepPurple),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your text stays in this screen. This preview does not send it to an AI provider or create tasks automatically.',
                  style: TextStyle(
                    color: PlannerColors.deepPurple,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Try describing a study task…',
            filled: true,
            fillColor: PlannerColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              if (controller.text.trim().isEmpty) {
                showPlannerMessage(context, 'Enter a note to preview first.');
                return;
              }
              setState(() {
                preview =
                    'Preview only: review “${controller.text.trim()}” '
                    'and confirm its date and duration before adding.';
              });
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Preview a safe interpretation'),
          ),
        ),
        if (preview != null) ...[
          const SizedBox(height: 14),
          PlannerCard(
            color: PlannerColors.butter,
            child: Text(
              preview!,
              style: const TextStyle(
                color: PlannerColors.deepPurple,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

class TaskListTile extends StatelessWidget {
  const TaskListTile({
    required this.task,
    required this.onToggle,
    required this.onTap,
    super.key,
  });

  final PlannerTask task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: PlannerColors.surface,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            semanticLabel: 'Mark ${task.title} complete',
            onChanged: (value) => onToggle(value ?? false),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: PlannerColors.ink,
                      fontWeight: FontWeight.w700,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${task.dueLabel} · ${_categoryLabel(task.category)}',
                    style: const TextStyle(
                      color: PlannerColors.mutedInk,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.chevron_right, color: PlannerColors.mutedInk),
          ),
        ],
      ),
    ),
  );
}

class _PlannerAction extends StatelessWidget {
  const _PlannerAction({
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    tileColor: PlannerColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    leading: CircleAvatar(
      backgroundColor: color,
      child: Icon(icon, color: PlannerColors.deepPurple),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: PlannerColors.ink,
        fontWeight: FontWeight.w700,
      ),
    ),
    subtitle: Text(detail),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 7),
    child: Row(
      children: [
        Icon(icon, size: 17, color: PlannerColors.purple),
        const SizedBox(width: 9),
        Text(label, style: const TextStyle(color: PlannerColors.ink)),
      ],
    ),
  );
}

class _CalendarPreview extends StatefulWidget {
  const _CalendarPreview();

  @override
  State<_CalendarPreview> createState() => _CalendarPreviewState();
}

class _CalendarPreviewState extends State<_CalendarPreview> {
  DateTime selected = DateTime.now();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      PlannerCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  tooltip: 'Previous week',
                  onPressed: () => setState(
                    () => selected = selected.subtract(const Duration(days: 7)),
                  ),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${selected.day}/${selected.month}/${selected.year}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                IconButton(
                  tooltip: 'Next week',
                  onPressed: () => setState(
                    () => selected = selected.add(const Duration(days: 7)),
                  ),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Row(
              children: List.generate(7, (index) {
                final day = selected.subtract(
                  Duration(days: selected.weekday - 1 - index),
                );
                return Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => selected = day),
                    style: TextButton.styleFrom(
                      backgroundColor: day.day == selected.day
                          ? PlannerColors.lavender
                          : Colors.transparent,
                    ),
                    child: Text('${day.day}'),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      const PlannerCard(
        color: PlannerColors.aqua,
        child: Row(
          children: [
            Icon(Icons.school_outlined, color: PlannerColors.deepPurple),
            SizedBox(width: 10),
            Text('09:00 · Design studio'),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const PlannerCard(
        color: PlannerColors.blush,
        child: Row(
          children: [
            Icon(Icons.flag_outlined, color: PlannerColors.deepPurple),
            SizedBox(width: 10),
            Text('Tomorrow · Research reflection'),
          ],
        ),
      ),
    ],
  );
}

class _TimetablePreview extends StatelessWidget {
  const _TimetablePreview();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final entry in const [
        ('Mon / Wed', '09:00', 'Design studio'),
        ('Tue / Thu', '13:30', 'Human-computer interaction'),
        ('Friday', '10:00', 'Research methods'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: PlannerCard(
            color: PlannerColors.surface,
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded, color: PlannerColors.purple),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.$3,
                        style: const TextStyle(
                          color: PlannerColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${entry.$1} · ${entry.$2}',
                        style: const TextStyle(
                          color: PlannerColors.mutedInk,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit ${entry.$3}',
                  onPressed: () => showPlannerMessage(
                    context,
                    'Class editor opened for ${entry.$3}.',
                  ),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
        ),
      OutlinedButton.icon(
        onPressed: () => showPlannerMessage(
          context,
          'Choose a day, time, and subject to add a class.',
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
    ],
  );
}

String _categoryLabel(TaskCategory category) =>
    category == TaskCategory.academic ? 'Academic' : 'Personal';

String _priorityLabel(TaskPriority priority) => switch (priority) {
  TaskPriority.low => 'Low',
  TaskPriority.normal => 'Normal',
  TaskPriority.high => 'High',
};

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}
