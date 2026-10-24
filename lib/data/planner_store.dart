import 'dart:async';

import 'package:flutter/foundation.dart';

abstract interface class TaskPersistence {
  Future<List<PlannerTask>> loadTasks();

  Future<void> saveTask(PlannerTask task);

  Future<void> deleteTask(String id);
}

enum TaskCategory { academic, personal }

enum TaskPriority { low, normal, high }

class PlannerTask {
  PlannerTask({
    required this.id,
    required this.title,
    required this.category,
    this.dueLabel = 'Today',
    this.priority = TaskPriority.normal,
    this.isCompleted = false,
    this.isAssignment = false,
  });

  final String id;
  String title;
  TaskCategory category;
  String dueLabel;
  TaskPriority priority;
  bool isCompleted;
  bool isAssignment;
}

class PlannerStore extends ChangeNotifier {
  PlannerStore({bool includePreviewData = true, this.persistence})
    : tasks = includePreviewData
          ? [
              PlannerTask(
                id: 'task-1',
                title: 'Review today’s lecture notes',
                category: TaskCategory.academic,
                dueLabel: 'Today · 11:00',
                priority: TaskPriority.high,
              ),
              PlannerTask(
                id: 'task-2',
                title: 'Finish assignment',
                category: TaskCategory.academic,
                dueLabel: 'Today · 16:00',
                priority: TaskPriority.high,
                isAssignment: true,
              ),
              PlannerTask(
                id: 'task-3',
                title: 'Organise my study desk',
                category: TaskCategory.personal,
                dueLabel: 'Today',
                isCompleted: true,
              ),
            ]
          : [] {
    if (persistence != null) _loadTasks();
  }

  final List<PlannerTask> tasks;
  final TaskPersistence? persistence;
  String? energy;
  bool isLoading = false;
  String? persistenceError;

  int get completedCount => tasks.where((task) => task.isCompleted).length;

  List<PlannerTask> get openTasks =>
      tasks.where((task) => !task.isCompleted).toList();

  List<PlannerTask> get assignments =>
      tasks.where((task) => task.isAssignment).toList();

  void toggleTask(PlannerTask task, bool completed) {
    task.isCompleted = completed;
    notifyListeners();
    if (persistence != null) {
      unawaited(_persist(() => persistence!.saveTask(task)));
    }
  }

  void saveTask({
    required String title,
    required TaskCategory category,
    required String dueLabel,
    required TaskPriority priority,
    PlannerTask? existing,
    bool isAssignment = false,
  }) {
    if (existing != null) {
      existing
        ..title = title
        ..category = category
        ..dueLabel = dueLabel
        ..priority = priority
        ..isAssignment = isAssignment;
    } else {
      tasks.insert(
        0,
        PlannerTask(
          id: 'task-${DateTime.now().microsecondsSinceEpoch}',
          title: title,
          category: category,
          dueLabel: dueLabel,
          priority: priority,
          isAssignment: isAssignment,
        ),
      );
    }
    notifyListeners();
    if (persistence != null) {
      unawaited(_persist(() => persistence!.saveTask(existing ?? tasks.first)));
    }
  }

  void deleteTask(PlannerTask task) {
    tasks.remove(task);
    notifyListeners();
    if (persistence != null) {
      unawaited(_persist(() => persistence!.deleteTask(task.id)));
    }
  }

  void setEnergy(String? value) {
    energy = value;
    notifyListeners();
  }

  Future<void> _loadTasks() async {
    isLoading = true;
    notifyListeners();
    try {
      final loaded = await persistence!.loadTasks();
      tasks
        ..clear()
        ..addAll(loaded);
      persistenceError = null;
    } on PlannerPersistenceFailure catch (error) {
      persistenceError = error.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persist(Future<void> Function() operation) async {
    try {
      await operation();
      persistenceError = null;
      notifyListeners();
    } on PlannerPersistenceFailure catch (error) {
      persistenceError = error.message;
      notifyListeners();
    }
  }
}

class PlannerPersistenceFailure implements Exception {
  const PlannerPersistenceFailure(this.message);

  final String message;
}
