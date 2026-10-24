import 'package:flutter/material.dart';

import '../../data/planner_store.dart';
import '../../ui/planner_design.dart';
import '../planner/planner_screens.dart';

class AcademicOverviewScreen extends StatelessWidget {
  const AcademicOverviewScreen({required this.store, super.key});

  final PlannerStore store;

  @override
  Widget build(BuildContext context) {
    return PlannerPage(
      title: 'Academics',
      subtitle: 'Your semester, one clear step at a time.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreviewBanner(),
          const SizedBox(height: 16),
          PlannerCard(
            color: PlannerColors.deepPurple,
            onTap: () => _push(context, const SemesterDetailScreen()),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT SEMESTER',
                        style: TextStyle(
                          color: PlannerColors.lime,
                          fontSize: 10,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'Semester 2 · 2026',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '3 subjects · 12 credits',
                        style: TextStyle(color: Color(0xFFEAE5FF)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const SectionHeading(title: 'Your academic toolkit'),
          const SizedBox(height: 10),
          _FeatureGrid(
            items: [
              _FeatureItem(
                'Weekly timetable',
                Icons.calendar_view_week_rounded,
                PlannerColors.lavender,
                () => _push(context, const TimetableScreen()),
              ),
              _FeatureItem(
                'Assignments & exams',
                Icons.assignment_outlined,
                PlannerColors.blush,
                () => _push(context, AssignmentListScreen(store: store)),
              ),
              _FeatureItem(
                'Attendance',
                Icons.fact_check_outlined,
                PlannerColors.aqua,
                () => _push(context, const AttendanceScreen()),
              ),
              _FeatureItem(
                'Grades & GPA',
                Icons.bar_chart_rounded,
                PlannerColors.butter,
                () => _push(context, const GradesScreen()),
              ),
              _FeatureItem(
                'Exam preparation',
                Icons.auto_stories_rounded,
                PlannerColors.lavender,
                () => _push(context, const ExamPreparationScreen()),
              ),
              _FeatureItem(
                'Calendar',
                Icons.calendar_month_rounded,
                PlannerColors.aqua,
                () => _push(context, const CalendarScreen()),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SectionHeading(
            title: 'Subjects',
            actionLabel: 'Semester',
            onAction: () => _push(context, const SemesterDetailScreen()),
          ),
          const SizedBox(height: 10),
          for (final subject in const [
            ('Design studio', '4 credits · 2 classes this week'),
            ('Human-computer interaction', '4 credits · 3 classes this week'),
            ('Research methods', '4 credits · 2 classes this week'),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _SubjectTile(
                title: subject.$1,
                subtitle: subject.$2,
                onTap: () => _push(
                  context,
                  SubjectDetailScreen(subjectName: subject.$1),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Academic results shown here are personal estimates, not official university records.',
            style: TextStyle(
              color: PlannerColors.mutedInk,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class SemesterDetailScreen extends StatefulWidget {
  const SemesterDetailScreen({super.key});

  @override
  State<SemesterDetailScreen> createState() => _SemesterDetailScreenState();
}

class _SemesterDetailScreenState extends State<SemesterDetailScreen> {
  String semesterName = 'Semester 2 · 2026';
  final List<String> subjects = [
    'Design studio',
    'Human-computer interaction',
    'Research methods',
  ];

  @override
  Widget build(BuildContext context) {
    return PlannerPage(
      title: semesterName,
      subtitle: 'Your semester overview · 12 credits',
      actions: [
        IconButton(
          tooltip: 'Edit semester',
          onPressed: _editSemester,
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreviewBanner(),
          const SizedBox(height: 16),
          const PlannerCard(
            color: PlannerColors.lavender,
            child: Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  color: PlannerColors.deepPurple,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'October 1 – December 18, 2026',
                    style: TextStyle(
                      color: PlannerColors.deepPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeading(title: 'Subjects in this semester'),
          const SizedBox(height: 10),
          for (final subject in subjects)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _SubjectTile(
                title: subject,
                subtitle: '4 credits · View schedule and progress',
                onTap: () =>
                    _push(context, SubjectDetailScreen(subjectName: subject)),
              ),
            ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _showAddSubject(context),
            icon: const Icon(Icons.add),
            label: const Text('Add a subject'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSubject(BuildContext context) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add subject'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Subject name'),
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
    if (!mounted || !context.mounted || name == null) return;
    setState(() => subjects.add(name));
    showPlannerMessage(context, '$name added to this session.');
  }

  Future<void> _editSemester() async {
    final controller = TextEditingController(text: semesterName);
    final updatedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit semester'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Semester name'),
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || updatedName == null) return;
    setState(() => semesterName = updatedName);
    showPlannerMessage(context, 'Semester updated in this session.');
  }
}

class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({required this.subjectName, super.key});

  final String subjectName;

  @override
  Widget build(BuildContext context) {
    return PlannerPage(
      title: subjectName,
      subtitle: 'Semester 2 · 4 credits',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreviewBanner(),
          const SizedBox(height: 16),
          PlannerCard(
            color: PlannerColors.aqua,
            child: const Row(
              children: [
                Icon(Icons.school_rounded, color: PlannerColors.deepPurple),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Next class · Today at 13:30',
                    style: TextStyle(
                      color: PlannerColors.deepPurple,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _FeatureGrid(
            items: [
              _FeatureItem(
                'Timetable',
                Icons.calendar_view_week_rounded,
                PlannerColors.lavender,
                () => _push(context, const TimetableScreen()),
              ),
              _FeatureItem(
                'Attendance',
                Icons.fact_check_outlined,
                PlannerColors.aqua,
                () => _push(context, const AttendanceScreen()),
              ),
              _FeatureItem(
                'Assignments',
                Icons.assignment_outlined,
                PlannerColors.blush,
                () => _push(context, const SubjectAssignmentsScreen()),
              ),
              _FeatureItem(
                'Grades',
                Icons.bar_chart_rounded,
                PlannerColors.butter,
                () => _push(context, const GradesScreen()),
              ),
              _FeatureItem(
                'Study materials',
                Icons.auto_stories_rounded,
                PlannerColors.lavender,
                () => _push(context, const SubjectVaultScreen()),
              ),
              _FeatureItem(
                'Exam prep',
                Icons.psychology_alt_rounded,
                PlannerColors.blush,
                () => _push(context, const ExamPreparationScreen()),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionHeading(title: 'Syllabus progress'),
          const SizedBox(height: 10),
          const _SyllabusTile(title: 'Foundations', done: true),
          const _SyllabusTile(title: 'Research and methods', done: false),
          const _SyllabusTile(title: 'Designing for people', done: false),
        ],
      ),
    );
  }
}

class SubjectAssignmentsScreen extends StatelessWidget {
  const SubjectAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Subject assignments',
    subtitle: 'Assignments and exams for this subject.',
    child: const _StaticAssignmentList(),
  );
}

class AssignmentListScreen extends StatelessWidget {
  const AssignmentListScreen({required this.store, super.key});

  final PlannerStore store;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final assignments = store.assignments;
        return PlannerPage(
          title: 'Assignments & exams',
          subtitle: 'Keep upcoming coursework in view.',
          actions: [
            IconButton(
              tooltip: 'Create assignment',
              onPressed: () => _push(
                context,
                TaskFormScreen(store: store, isAssignment: true),
              ),
              icon: const Icon(Icons.add),
            ),
          ],
          child: assignments.isEmpty
              ? EmptyState(
                  title: 'No assignments yet',
                  message: 'Add a deadline when you are ready.',
                  icon: Icons.assignment_outlined,
                  actionLabel: 'Create assignment',
                  onAction: () => _push(
                    context,
                    TaskFormScreen(store: store, isAssignment: true),
                  ),
                )
              : Column(
                  children: [
                    for (final task in assignments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          tileColor: PlannerColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          leading: const CircleAvatar(
                            backgroundColor: PlannerColors.blush,
                            child: Icon(
                              Icons.assignment_outlined,
                              color: PlannerColors.deepPurple,
                            ),
                          ),
                          title: Text(task.title),
                          subtitle: Text(task.dueLabel),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _push(
                            context,
                            TaskDetailScreen(store: store, task: task),
                          ),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _StaticAssignmentList extends StatelessWidget {
  const _StaticAssignmentList();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const PreviewBanner(),
      const SizedBox(height: 14),
      const _AssignmentTile(
        title: 'Research reflection',
        due: 'Tomorrow · Draft in progress',
      ),
      const _AssignmentTile(
        title: 'Studio project review',
        due: 'Next Thursday · Not started',
      ),
      const EmptyState(
        title: 'No exams scheduled',
        message: 'Add an exam when your schedule is confirmed.',
        icon: Icons.event_note_rounded,
      ),
    ],
  );
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.title, required this.due});

  final String title;
  final String due;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      tileColor: PlannerColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      leading: const CircleAvatar(
        backgroundColor: PlannerColors.blush,
        child: Icon(Icons.assignment_outlined, color: PlannerColors.deepPurple),
      ),
      title: Text(title),
      subtitle: Text(due),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showPlannerMessage(context, 'Preview assignment details.'),
    ),
  );
}

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Timetable',
    subtitle: 'A quick look at the week ahead.',
    actions: [
      IconButton(
        tooltip: 'Add class',
        onPressed: () => showPlannerMessage(
          context,
          'Class editor is ready for your schedule details.',
        ),
        icon: const Icon(Icons.add),
      ),
    ],
    child: const _WeekSchedule(),
  );
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Calendar',
    subtitle: 'Classes, plans, and due dates in one place.',
    actions: [
      IconButton(
        tooltip: 'Choose date',
        onPressed: _chooseDate,
        icon: const Icon(Icons.calendar_month),
      ),
    ],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlannerCard(
          color: PlannerColors.lavender,
          child: Row(
            children: [
              const Icon(Icons.today_rounded, color: PlannerColors.deepPurple),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(
                    color: PlannerColors.deepPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => selectedDate = DateTime.now()),
                child: const Text('Today'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _WeekSchedule(),
        const SizedBox(height: 14),
        const SectionHeading(title: 'On this day'),
        const SizedBox(height: 8),
        const _CalendarEvent(
          time: '09:00',
          label: 'Design studio',
          color: PlannerColors.aqua,
        ),
        const _CalendarEvent(
          time: '13:30',
          label: 'Human-computer interaction',
          color: PlannerColors.lavender,
        ),
        const _CalendarEvent(
          time: '16:00',
          label: 'Assignment deadline',
          color: PlannerColors.blush,
        ),
      ],
    ),
  );

  Future<void> _chooseDate() async {
    final chosen = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (chosen != null) setState(() => selectedDate = chosen);
  }
}

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final Map<String, int> attended = {
    'Design studio': 8,
    'Human-computer interaction': 7,
    'Research methods': 9,
  };
  final Map<String, int> held = {
    'Design studio': 10,
    'Human-computer interaction': 9,
    'Research methods': 10,
  };

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Attendance',
    subtitle: 'Your entries and the assumptions behind them.',
    child: Column(
      children: [
        const PreviewBanner(),
        const SizedBox(height: 14),
        for (final subject in attended.keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PlannerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: PlannerColors.ink,
                          ),
                        ),
                      ),
                      Text(
                        '${(attended[subject]! / held[subject]! * 100).round()}%',
                        style: const TextStyle(
                          color: PlannerColors.purple,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${attended[subject]} attended · ${held[subject]} held · '
                    '75% requirement',
                    style: const TextStyle(
                      color: PlannerColors.mutedInk,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: attended[subject]! / held[subject]!,
                    color: PlannerColors.purple,
                    backgroundColor: PlannerColors.lavender,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _recordAttendance(subject),
                    icon: const Icon(Icons.add_task_rounded),
                    label: const Text('Record today’s class'),
                  ),
                ],
              ),
            ),
          ),
        const EmptyState(
          title: 'Projection, not a promise',
          message:
              'Forecasts depend on future class sessions and your attendance.',
          icon: Icons.info_outline_rounded,
        ),
      ],
    ),
  );

  Future<void> _recordAttendance(String subject) async {
    final status = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            for (final value in ['Present', 'Absent', 'Excused'])
              ListTile(
                leading: const Icon(Icons.fact_check_outlined),
                title: Text(value),
                onTap: () => Navigator.pop(sheetContext, value),
              ),
          ],
        ),
      ),
    );
    if (status == null) return;
    setState(() {
      held[subject] = held[subject]! + 1;
      if (status == 'Present') attended[subject] = attended[subject]! + 1;
    });
    if (mounted) showPlannerMessage(context, '$status attendance recorded.');
  }
}

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final _scoreController = TextEditingController();
  final _maximumController = TextEditingController();
  double? result;

  @override
  void dispose() {
    _scoreController.dispose();
    _maximumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Grades & GPA',
    subtitle: 'Personal estimates only · confirm your institution’s scale.',
    child: Column(
      children: [
        const PreviewBanner(),
        const SizedBox(height: 14),
        PlannerCard(
          color: PlannerColors.lavender,
          child: Row(
            children: [
              const Icon(
                Icons.calculate_outlined,
                color: PlannerColors.deepPurple,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result == null
                      ? 'Calculate a score percentage'
                      : 'Estimated score: ${result!.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: PlannerColors.deepPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PlannerCard(
          child: Column(
            children: [
              TextField(
                controller: _scoreController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Score achieved',
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _maximumController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Maximum score',
                  prefixIcon: Icon(Icons.functions),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _calculate,
                child: const Text('Calculate estimate'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const EmptyState(
          title: 'No official GPA scale selected',
          message: 'Add your institution’s grading scale before interpreting a GPA estimate.',
          icon: Icons.school_outlined,
        ),
      ],
    ),
  );

  void _calculate() {
    final score = double.tryParse(_scoreController.text);
    final maximum = double.tryParse(_maximumController.text);
    if (score == null ||
        maximum == null ||
        maximum <= 0 ||
        score < 0 ||
        score > maximum) {
      showPlannerMessage(context, 'Enter a valid score within the maximum.');
      return;
    }
    setState(() => result = score / maximum * 100);
  }
}

class ExamPreparationScreen extends StatelessWidget {
  const ExamPreparationScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Exam preparation',
    subtitle: 'Build a gentle revision plan from your available time.',
    actions: [
      IconButton(
        tooltip: 'Create a study plan',
        onPressed: () => showPlannerMessage(
          context,
          'Choose topics and available study time to create a plan.',
        ),
        icon: const Icon(Icons.add),
      ),
    ],
    child: Column(
      children: const [
        PreviewBanner(),
        SizedBox(height: 14),
        _SyllabusTile(title: 'Review lecture notes', done: false),
        _SyllabusTile(title: 'Practice key concepts', done: false),
        _SyllabusTile(title: 'Prepare questions for class', done: true),
        SizedBox(height: 14),
        EmptyState(
          title: 'No exam date added',
          message: 'Add a confirmed exam date before scheduling revision.',
          icon: Icons.event_available_outlined,
        ),
      ],
    ),
  );
}

class SubjectVaultScreen extends StatelessWidget {
  const SubjectVaultScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Subject resources',
    subtitle: 'Materials linked to this subject.',
    child: Column(
      children: [
        ListTile(
          tileColor: PlannerColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: const Icon(Icons.note_alt_outlined),
          title: const Text('Lecture notes'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _push(context, const SubjectNoteScreen()),
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: PlannerColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          leading: const Icon(Icons.style_outlined),
          title: const Text('Revision flashcards'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _push(context, const AcademicFlashcardsScreen()),
        ),
      ],
    ),
  );
}

class SubjectNoteScreen extends StatelessWidget {
  const SubjectNoteScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Lecture notes',
    subtitle: 'A preview note, not an uploaded course document.',
    child: const PlannerCard(
      child: Text(
        'Add your own notes and files in the Vault. No external documents or university materials are connected in this preview.',
        style: TextStyle(color: PlannerColors.ink, height: 1.5),
      ),
    ),
  );
}

class AcademicFlashcardsScreen extends StatelessWidget {
  const AcademicFlashcardsScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Flashcards',
    subtitle: 'Review sample cards or add your own material.',
    child: const _FlashcardPractice(),
  );
}

class _FlashcardPractice extends StatefulWidget {
  const _FlashcardPractice();

  @override
  State<_FlashcardPractice> createState() => _FlashcardPracticeState();
}

class _FlashcardPracticeState extends State<_FlashcardPractice> {
  int index = 0;
  bool revealed = false;

  static const cards = [
    (
      'What is a user-centered design?',
      'A design process shaped around user needs.',
    ),
    (
      'What does iteration mean?',
      'Improving a solution through repeated cycles.',
    ),
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      PlannerCard(
        color: revealed ? PlannerColors.lavender : PlannerColors.blush,
        onTap: () => setState(() => revealed = !revealed),
        child: SizedBox(
          height: 190,
          width: double.infinity,
          child: Center(
            child: Text(
              revealed ? cards[index].$2 : cards[index].$1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: PlannerColors.deepPurple,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => setState(() {
          index = (index + 1) % cards.length;
          revealed = false;
        }),
        child: const Text('Next card'),
      ),
    ],
  );
}

class _WeekSchedule extends StatelessWidget {
  const _WeekSchedule();

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1;
    return PlannerCard(
      padding: const EdgeInsets.fromLTRB(12, 15, 12, 12),
      child: Column(
        children: [
          Row(
            children: List.generate(7, (index) {
              const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              return Expanded(
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: today == index
                          ? PlannerColors.purple
                          : PlannerColors.lavender,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      weekdays[index],
                      style: TextStyle(
                        color: today == index
                            ? Colors.white
                            : PlannerColors.deepPurple,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          const _CalendarEvent(
            time: '09:00',
            label: 'Design studio',
            color: PlannerColors.aqua,
          ),
          const _CalendarEvent(
            time: '13:30',
            label: 'Human-computer interaction',
            color: PlannerColors.lavender,
          ),
          const _CalendarEvent(
            time: '15:30',
            label: 'Study block',
            color: PlannerColors.butter,
          ),
        ],
      ),
    );
  }
}

class _CalendarEvent extends StatelessWidget {
  const _CalendarEvent({
    required this.time,
    required this.label,
    required this.color,
  });

  final String time;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            time,
            style: const TextStyle(
              color: PlannerColors.mutedInk,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: PlannerColors.deepPurple,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _SyllabusTile extends StatefulWidget {
  const _SyllabusTile({required this.title, required this.done});

  final String title;
  final bool done;

  @override
  State<_SyllabusTile> createState() => _SyllabusTileState();
}

class _SyllabusTileState extends State<_SyllabusTile> {
  late bool done = widget.done;

  @override
  Widget build(BuildContext context) => CheckboxListTile(
    value: done,
    onChanged: (value) => setState(() => done = value ?? false),
    title: Text(widget.title),
    subtitle: const Text('Tap to update this preview checklist'),
    activeColor: PlannerColors.purple,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    tileColor: PlannerColors.surface,
    controlAffinity: ListTileControlAffinity.leading,
  );
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    tileColor: PlannerColors.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    leading: const CircleAvatar(
      backgroundColor: PlannerColors.lavender,
      child: Icon(Icons.menu_book_rounded, color: PlannerColors.deepPurple),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: PlannerColors.ink,
        fontWeight: FontWeight.w700,
      ),
    ),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _FeatureItem {
  const _FeatureItem(this.title, this.icon, this.color, this.onTap);

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.items});

  final List<_FeatureItem> items;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 360 ? 1 : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          mainAxisExtent: 116,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return PlannerCard(
            color: PlannerColors.surface,
            padding: const EdgeInsets.all(13),
            onTap: item.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 19,
                  backgroundColor: item.color,
                  child: Icon(
                    item.icon,
                    size: 19,
                    color: PlannerColors.deepPurple,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: PlannerColors.ink,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: PlannerColors.mutedInk,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _push(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}
