import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_app/data/account_service.dart';
import 'package:to_do_app/data/planner_store.dart';
import 'package:to_do_app/data/student_profile.dart';
import 'package:to_do_app/app/planner_app.dart';

class _FakeAccountService implements AccountService {
  final _changes = StreamController<AccountIdentity?>.broadcast(sync: true);
  final profiles = <String, StudentProfile>{};
  AccountIdentity? identity;

  @override
  AccountIdentity? get currentIdentity => identity;

  @override
  Stream<AccountIdentity?> authStateChanges() async* {
    yield identity;
    yield* _changes.stream;
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    identity = AccountIdentity(uid: 'student-1', email: email);
    profiles[identity!.uid] = StudentProfile(
      displayName: displayName,
      email: email,
    );
    _changes.add(identity);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    identity = AccountIdentity(uid: 'student-1', email: email);
    _changes.add(identity);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}

  @override
  Future<StudentProfile?> loadProfile(String uid) async {
    if (identity?.uid != uid) {
      throw const AccountFailure(
        'You are not authorized to access this profile.',
      );
    }
    return profiles[uid];
  }

  @override
  Future<void> saveProfile(String uid, StudentProfile profile) async {
    if (identity?.uid != uid) {
      throw const AccountFailure(
        'You are not authorized to access this profile.',
      );
    }
    profiles[uid] = profile;
  }

  @override
  Future<void> signOut() async {
    identity = null;
    _changes.add(null);
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    profiles.remove(identity?.uid);
    await signOut();
  }

  Future<void> dispose() => _changes.close();
}

class _MemoryTaskPersistence implements TaskPersistence {
  _MemoryTaskPersistence(this.saved);

  final List<PlannerTask> saved;

  @override
  Future<List<PlannerTask>> loadTasks() async =>
      saved.map(copyTask).toList(growable: true);

  PlannerTask copyTask(PlannerTask task) => PlannerTask(
    id: task.id,
    title: task.title,
    category: task.category,
    dueLabel: task.dueLabel,
    priority: task.priority,
    isCompleted: task.isCompleted,
    isAssignment: task.isAssignment,
  );

  @override
  Future<void> saveTask(PlannerTask task) async {
    final index = saved.indexWhere((entry) => entry.id == task.id);
    if (index == -1) {
      saved.add(copyTask(task));
    } else {
      saved[index] = copyTask(task);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    saved.removeWhere((task) => task.id == id);
  }
}

void main() {
  test(
    'authenticated task data loads and persists through its repository',
    () async {
      final task = PlannerTask(
        id: 'owned-task',
        title: 'Review lecture notes',
        category: TaskCategory.academic,
      );
      final persistence = _MemoryTaskPersistence([task]);
      final store = PlannerStore(
        includePreviewData: false,
        persistence: persistence,
      );
      await Future<void>.delayed(Duration.zero);

      expect(store.tasks.single.title, 'Review lecture notes');
      store.toggleTask(task, true);
      await Future<void>.delayed(Duration.zero);
      expect(persistence.saved.single.isCompleted, isTrue);

      store.dispose();
    },
  );

  testWidgets('dashboard task completion updates its progress', (tester) async {
    await tester.pumpWidget(const MyPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Hello, lovely!'), findsOneWidget);
    expect(find.text('1 of 3 little tasks done'), findsOneWidget);

    final checkbox = find.byWidgetPredicate(
      (widget) =>
          widget is Checkbox &&
          widget.semanticLabel == 'Mark Review today’s lecture notes complete',
    );
    await tester.scrollUntilVisible(
      checkbox,
      350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(checkbox);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('A fresh little start'),
      -350,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('2 of 3 little tasks done'), findsOneWidget);
  });

  testWidgets('all five primary destinations open', (tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyPlannerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-Academics')));
    await tester.pumpAndSettle();
    expect(find.text('Your academic toolkit'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-Planner')));
    await tester.pumpAndSettle();
    expect(find.text('Deadline Radar'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('nav-Vault')));
    await tester.pumpAndSettle();
    expect(find.text('Academic Vault'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-My Life')));
    await tester.pumpAndSettle();
    expect(find.text('Habits & routines'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('task creation validates and adds a local preview task', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyPlannerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-Planner')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All tasks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Create task'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save preview'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a title'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).first,
      'Prepare portfolio',
    );
    await tester.tap(find.text('Save preview'));
    await tester.pumpAndSettle();

    expect(find.text('Prepare portfolio'), findsOneWidget);
  });

  testWidgets('dashboard fits a narrow mobile viewport', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyPlannerApp());
    await tester.pumpAndSettle();

    expect(find.text('Hello, lovely!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('academic subjects and attendance details open', (tester) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyPlannerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-Academics')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Design studio').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Design studio').last);
    await tester.pumpAndSettle();
    expect(find.text('Syllabus progress'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Attendance').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Attendance').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('75% requirement'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Vault note creation adds a searchable session item', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyPlannerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-Vault')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add a note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Lecture recap');
    await tester.enterText(find.byType(TextFormField).last, 'Key points');
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();

    expect(find.text('Lecture recap'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('welcome flow exposes onboarding and account forms', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyPlannerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('nav-My Life')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'My Life tab');
    await tester.tap(find.byTooltip('Profile and settings').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'settings screen');
    await tester.ensureVisible(find.text('View welcome screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('View welcome screen'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'welcome screen');

    await tester.tap(find.text('Set up my space'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'onboarding screen');
    expect(find.text('University (optional)'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'return to welcome');
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(tester.takeException(), isNull, reason: 'account screen');
    expect(find.text('Create account'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'registration, onboarding, refresh, login, and logout use the account gate',
    (tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = _FakeAccountService();
      addTearDown(service.dispose);
      await tester.pumpWidget(MyPlannerApp(accountService: service));
      await tester.pumpAndSettle();
      expect(find.text('A little more room\nfor everything.'), findsOneWidget);

      await tester.tap(find.text('Create account'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Taylor Student',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'taylor@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'StudentPass123!',
      );
      expect(
        find
            .byType(TextFormField)
            .evaluate()
            .map(
              (element) => (element.widget as TextFormField).controller!.text,
            ),
        ['Taylor Student', 'taylor@example.com', 'StudentPass123!'],
      );
      final submitButton = find.widgetWithText(FilledButton, 'Create account');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
      expect(service.identity, isNotNull);
      expect(tester.takeException(), isNull);
      expect(find.text('Set up your space'), findsOneWidget);

      await tester.ensureVisible(find.text('Save and continue'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save and continue'));
      await tester.pumpAndSettle();
      expect(service.profiles['student-1']?.onboardingComplete, isTrue);
      expect(find.text('Hello, Taylor Student!'), findsOneWidget);
      expect(find.text('Review today’s lecture notes'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MyPlannerApp(accountService: service));
      await tester.pumpAndSettle();
      expect(find.text('Hello, Taylor Student!'), findsOneWidget);

      await tester.tap(find.byTooltip('Profile and settings').first);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Log out'),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('A little more room\nfor everything.'), findsOneWidget);

      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'taylor@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'StudentPass123!',
      );
      await tester.tap(find.text('Log in').last);
      await tester.pumpAndSettle();
      expect(find.text('Hello, Taylor Student!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
