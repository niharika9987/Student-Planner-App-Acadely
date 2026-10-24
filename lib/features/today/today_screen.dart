import 'package:flutter/material.dart';

import '../../data/planner_store.dart';
import '../../ui/planner_design.dart';
import '../academics/academic_screens.dart';
import '../planner/planner_screens.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    required this.store,
    required this.onProfile,
    this.displayName,
    super.key,
  });

  final PlannerStore store;
  final VoidCallback onProfile;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${_weekday(now.weekday)}, ${_month(now.month)} ${now.day}';
    final name = displayName?.trim();
    final greeting = name == null || name.isEmpty
        ? 'Hello, lovely!'
        : 'Hello, $name!';

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final openTasks = store.openTasks.take(3).toList();
        final done = store.completedCount;
        return CustomScrollView(
          key: const ValueKey('today-screen'),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  ScreenHeader(
                    eyebrow: date,
                    title: greeting,
                    subtitle: 'One little step at a time.',
                    trailing: IconButton(
                      tooltip: 'Profile and settings',
                      onPressed: onProfile,
                      icon: const CircleAvatar(
                        backgroundColor: PlannerColors.lavender,
                        child: Icon(
                          Icons.spa_rounded,
                          color: PlannerColors.purple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const PreviewBanner(),
                  const SizedBox(height: 18),
                  if (store.isLoading)
                    const LinearProgressIndicator(
                      semanticsLabel: 'Loading saved tasks',
                    ),
                  if (store.persistenceError != null) ...[
                    _PersistenceError(message: store.persistenceError!),
                    const SizedBox(height: 12),
                  ],
                  _ProgressCard(done: done, total: store.tasks.length),
                  const SizedBox(height: 18),
                  _EnergyCheckIn(store: store),
                  const SizedBox(height: 24),
                  SectionHeading(
                    title: 'Today’s classes',
                    actionLabel: 'Timetable',
                    onAction: () => _open(context, const TimetableScreen()),
                  ),
                  const SizedBox(height: 10),
                  _ClassTile(
                    time: '09:00',
                    title: 'Design studio',
                    detail: 'Room 204 · 60 min',
                    color: PlannerColors.aqua,
                    icon: Icons.draw_rounded,
                    onTap: () => _open(
                      context,
                      const SubjectDetailScreen(subjectName: 'Design studio'),
                    ),
                  ),
                  const SizedBox(height: 9),
                  _ClassTile(
                    time: '13:30',
                    title: 'Human-computer interaction',
                    detail: 'Lecture hall B · 90 min',
                    color: PlannerColors.lavender,
                    icon: Icons.menu_book_rounded,
                    onTap: () => _open(
                      context,
                      const SubjectDetailScreen(
                        subjectName: 'Human-computer interaction',
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SectionHeading(
                    title: 'Coming up',
                    actionLabel: 'Deadline Radar',
                    onAction: () => _open(context, const DeadlineRadarScreen()),
                  ),
                  const SizedBox(height: 10),
                  _DeadlineCard(
                    title: 'Research reflection',
                    detail: 'Assignment · Tomorrow',
                    color: PlannerColors.blush,
                    onTap: () =>
                        _open(context, AssignmentListScreen(store: store)),
                  ),
                  const SizedBox(height: 22),
                  SectionHeading(
                    title: 'Your next steps',
                    actionLabel: 'See all',
                    onAction: () =>
                        _open(context, TaskListScreen(store: store)),
                  ),
                  const SizedBox(height: 10),
                  if (openTasks.isEmpty)
                    EmptyState(
                      title: 'All caught up',
                      message: 'Your task list is clear for now.',
                      icon: Icons.check_circle_outline_rounded,
                      actionLabel: 'Open planner',
                      onAction: () =>
                          _open(context, TaskListScreen(store: store)),
                    )
                  else
                    ...openTasks.map(
                      (task) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _TaskRow(
                          task: task,
                          onToggle: (value) => store.toggleTask(task, value),
                          onTap: () => _open(
                            context,
                            TaskDetailScreen(store: store, task: task),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  SectionHeading(
                    title: 'A little study time',
                    actionLabel: 'Plan my day',
                    onAction: () => _open(context, const CalendarScreen()),
                  ),
                  const SizedBox(height: 10),
                  PlannerCard(
                    color: PlannerColors.deepPurple,
                    onTap: () => _open(context, const CalendarScreen()),
                    child: const Row(
                      children: [
                        Icon(Icons.timer_outlined, color: PlannerColors.lime),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '15:30  ·  Focus session',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Review your lecture notes · 30 min',
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
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'You don’t have to do it all today.',
                      style: TextStyle(
                        color: PlannerColors.mutedInk,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    return PlannerCard(
      color: PlannerColors.purple,
      padding: const EdgeInsets.all(19),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'A fresh little start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$done of $total little tasks done',
                  style: const TextStyle(color: Color(0xFFEAE5FF)),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: PlannerColors.lime,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You don’t have to do it all today.',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const _MascotBadge(),
        ],
      ),
    );
  }
}

class _MascotBadge extends StatelessWidget {
  const _MascotBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F95B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sentiment_satisfied_alt_rounded,
              size: 38,
              color: PlannerColors.deepPurple,
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.auto_awesome, color: PlannerColors.lime),
          ),
        ],
      ),
    );
  }
}

class _EnergyCheckIn extends StatelessWidget {
  const _EnergyCheckIn({required this.store});

  final PlannerStore store;

  @override
  Widget build(BuildContext context) {
    return PlannerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How’s your energy?',
            style: TextStyle(
              color: PlannerColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              for (final mood in ['Low', 'Steady', 'Bright'])
                ChoiceChip(
                  label: Text(mood),
                  selected: store.energy == mood,
                  onSelected: (_) =>
                      store.setEnergy(store.energy == mood ? null : mood),
                  selectedColor: PlannerColors.lime,
                ),
            ],
          ),
          const Text(
            'Optional · only used to shape today’s suggestions.',
            style: TextStyle(color: PlannerColors.mutedInk, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  const _ClassTile({
    required this.time,
    required this.title,
    required this.detail,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String time;
  final String title;
  final String detail;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PlannerCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: PlannerColors.deepPurple),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 48,
            child: Text(
              time,
              style: const TextStyle(
                color: PlannerColors.purple,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PlannerColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    color: PlannerColors.mutedInk,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: PlannerColors.mutedInk),
        ],
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard({
    required this.title,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PlannerCard(
      color: color,
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: PlannerColors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PlannerColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    color: PlannerColors.deepPurple,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: PlannerColors.deepPurple),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final PlannerTask task;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PlannerColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              semanticLabel: 'Mark ${task.title} complete',
              onChanged: (value) => onToggle(value ?? false),
              activeColor: PlannerColors.purple,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      color: PlannerColors.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.dueLabel,
                    style: const TextStyle(
                      color: PlannerColors.mutedInk,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: PlannerColors.mutedInk),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersistenceError extends StatelessWidget {
  const _PersistenceError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => PlannerCard(
    color: const Color(0xFFFFE4E1),
    child: Row(
      children: [
        const Icon(Icons.cloud_off_outlined, color: PlannerColors.error),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
      ],
    ),
  );
}

String _weekday(int day) => const [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][day - 1];

String _month(int month) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month - 1];
