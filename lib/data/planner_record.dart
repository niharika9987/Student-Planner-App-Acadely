enum PlannerCollection {
  academicTerms('academicTerms'),
  subjects('subjects'),
  subjectEnrollments('subjectEnrollments'),
  classSessions('classSessions'),
  timetableEntries('timetableEntries'),
  attendanceRecords('attendanceRecords'),
  assignments('assignments'),
  assignmentMilestones('assignmentMilestones'),
  exams('exams'),
  assessmentComponents('assessmentComponents'),
  grades('grades'),
  tasks('tasks'),
  subtasks('subtasks'),
  personalEvents('personalEvents'),
  habits('habits'),
  habitCompletions('habitCompletions'),
  goals('goals'),
  goalMilestones('goalMilestones'),
  studySessions('studySessions'),
  notes('notes'),
  attachments('attachments'),
  flashcards('flashcards'),
  quizzes('quizzes'),
  notifications('notifications'),
  userPreferences('userPreferences'),
  aiPlanningSuggestions('aiPlanningSuggestions'),
  auditRecords('auditRecords');

  const PlannerCollection(this.path);

  final String path;
}

class PlannerRecord {
  const PlannerRecord({
    required this.id,
    required this.ownerUid,
    required this.collection,
    required this.data,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerUid;
  final PlannerCollection collection;
  final Map<String, dynamic> data;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
