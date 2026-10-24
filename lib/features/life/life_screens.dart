import 'package:flutter/material.dart';

import '../../ui/planner_design.dart';

class MyLifeScreen extends StatelessWidget {
  const MyLifeScreen({required this.onSettings, super.key});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'My Life',
    subtitle: 'Make space for the things that keep you well.',
    actions: [
      IconButton(
        tooltip: 'Profile and settings',
        onPressed: onSettings,
        icon: const Icon(Icons.settings_outlined),
      ),
    ],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PreviewBanner(),
        const SizedBox(height: 14),
        _LifeLink(
          title: 'Habits & routines',
          detail: 'Small routines, one day at a time',
          icon: Icons.repeat_rounded,
          color: PlannerColors.aqua,
          onTap: () => _push(context, const HabitsScreen()),
        ),
        const SizedBox(height: 9),
        _LifeLink(
          title: 'Personal goals',
          detail: 'Track what matters to you',
          icon: Icons.flag_outlined,
          color: PlannerColors.lavender,
          onTap: () => _push(context, const GoalsScreen()),
        ),
        const SizedBox(height: 9),
        _LifeLink(
          title: 'Progress analytics',
          detail: 'A gentle weekly check-in',
          icon: Icons.insights_rounded,
          color: PlannerColors.butter,
          onTap: () => _push(context, const ProgressScreen()),
        ),
        const SizedBox(height: 9),
        _LifeLink(
          title: 'Personal tasks & events',
          detail: 'Errands, birthdays, and appointments',
          icon: Icons.event_note_outlined,
          color: PlannerColors.blush,
          onTap: () => _push(context, const PersonalTasksScreen()),
        ),
        const SizedBox(height: 9),
        _LifeLink(
          title: 'Profile & settings',
          detail: 'Privacy, appearance, and account',
          icon: Icons.settings_outlined,
          color: PlannerColors.lavender,
          onTap: onSettings,
        ),
        const SizedBox(height: 20),
        const Text(
          'Gentle progress, not pressure.',
          style: TextStyle(
            color: PlannerColors.deepPurple,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final habits = <String, bool>{
    'Read for ten minutes': false,
    'Take a short walk': true,
    'Wind down before bed': false,
  };

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Habits & routines',
    subtitle: 'Today’s check-in · completion stays in this preview session.',
    actions: [
      IconButton(
        tooltip: 'Add a habit',
        onPressed: _addHabit,
        icon: const Icon(Icons.add),
      ),
    ],
    child: Column(
      children: [
        const PreviewBanner(),
        const SizedBox(height: 14),
        for (final habit in habits.keys.toList())
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CheckboxListTile(
              value: habits[habit],
              onChanged: (value) =>
                  setState(() => habits[habit] = value ?? false),
              title: Text(habit),
              subtitle: const Text('Daily · you choose the pace'),
              activeColor: PlannerColors.purple,
              tileColor: PlannerColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        const SizedBox(height: 10),
        const EmptyState(
          title: 'Missed a day? Start again gently.',
          message: 'Your history is a guide, not a score.',
          icon: Icons.spa_outlined,
        ),
      ],
    ),
  );

  Future<void> _addHabit() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a habit'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Habit name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) return;
    setState(() => habits[name] = false);
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final goals = <String, double>{
    'Read one book this month': 0.4,
    'Study in focused blocks': 0.6,
    'Move a little every day': 0.25,
  };

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Personal goals',
    subtitle: 'Your goals are yours to define and adjust.',
    actions: [
      IconButton(
        tooltip: 'Add goal',
        onPressed: _addGoal,
        icon: const Icon(Icons.add),
      ),
    ],
    child: Column(
      children: [
        const PreviewBanner(),
        const SizedBox(height: 14),
        for (final goal in goals.keys.toList())
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: PlannerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal,
                    style: const TextStyle(
                      color: PlannerColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: goals[goal],
                    color: PlannerColors.purple,
                    backgroundColor: PlannerColors.lavender,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(
                        () =>
                            goals[goal] = (goals[goal]! + 0.1).clamp(0.0, 1.0),
                      ),
                      child: const Text('Update progress'),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Future<void> _addGoal() async {
    final controller = TextEditingController();
    final goal = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a goal'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'What matters to you?'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (goal == null) return;
    setState(() => goals[goal] = 0);
  }
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Progress',
    subtitle: 'A reflection on what you have logged, not a grade.',
    child: Column(
      children: [
        const PreviewBanner(),
        const SizedBox(height: 14),
        const PlannerCard(
          color: PlannerColors.lavender,
          child: Row(
            children: [
              Icon(Icons.insights_rounded, color: PlannerColors.deepPurple),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'This week · preview sample',
                  style: TextStyle(
                    color: PlannerColors.deepPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _MetricRow(
          icon: Icons.check_circle_outline,
          label: 'Tasks completed',
          value: '1 of 3',
        ),
        const _MetricRow(
          icon: Icons.timer_outlined,
          label: 'Study time',
          value: 'No sessions logged',
        ),
        const _MetricRow(
          icon: Icons.fact_check_outlined,
          label: 'Attendance',
          value: 'Add class records',
        ),
        const SizedBox(height: 14),
        const EmptyState(
          title: 'Build a personal baseline',
          message: 'More logged weeks make trends more useful. No estimates are shown yet.',
          icon: Icons.show_chart_rounded,
        ),
      ],
    ),
  );
}

class PersonalTasksScreen extends StatefulWidget {
  const PersonalTasksScreen({super.key});

  @override
  State<PersonalTasksScreen> createState() => _PersonalTasksScreenState();
}

class _PersonalTasksScreenState extends State<PersonalTasksScreen> {
  final items = <String, bool>{
    'Pick up groceries': false,
    'Call a friend': false,
    'Plan weekend walk': true,
  };

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Personal tasks',
    subtitle: 'Errands and little life admin.',
    actions: [
      IconButton(
        tooltip: 'Add personal task',
        onPressed: _addTask,
        icon: const Icon(Icons.add),
      ),
    ],
    child: Column(
      children: [
        const PreviewBanner(),
        const SizedBox(height: 14),
        for (final item in items.keys.toList())
          CheckboxListTile(
            value: items[item],
            title: Text(item),
            onChanged: (value) => setState(() => items[item] = value ?? false),
            activeColor: PlannerColors.purple,
            tileColor: PlannerColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2040),
          ),
          icon: const Icon(Icons.event),
          label: const Text('Add personal event'),
        ),
      ],
    ),
  );

  Future<void> _addTask() async {
    final controller = TextEditingController();
    final task = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a personal task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Task'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (task == null) return;
    setState(() => items[task] = false);
  }
}

class _LifeLink extends StatelessWidget {
  const _LifeLink({
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
    title: Text(title),
    subtitle: Text(detail),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: PlannerCard(
      child: Row(
        children: [
          Icon(icon, color: PlannerColors.purple),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              color: PlannerColors.deepPurple,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
