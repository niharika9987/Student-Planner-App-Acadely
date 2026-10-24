class StudentProfile {
  const StudentProfile({
    required this.displayName,
    required this.email,
    this.university,
    this.universityId,
    this.degree,
    this.department,
    this.currentSemester,
    this.academicYear,
    this.timezone = 'UTC',
    this.preferredWeekStart = 1,
    this.theme = 'system',
    this.notificationsEnabled = true,
    this.studyGoals = const [],
    this.onboardingComplete = false,
  });

  final String displayName;
  final String email;
  final String? university;
  final String? universityId;
  final String? degree;
  final String? department;
  final String? currentSemester;
  final String? academicYear;
  final String timezone;
  final int preferredWeekStart;
  final String theme;
  final bool notificationsEnabled;
  final List<String> studyGoals;
  final bool onboardingComplete;

  StudentProfile copyWith({
    String? displayName,
    String? email,
    String? university,
    String? universityId,
    String? degree,
    String? department,
    String? currentSemester,
    String? academicYear,
    String? timezone,
    int? preferredWeekStart,
    String? theme,
    bool? notificationsEnabled,
    List<String>? studyGoals,
    bool? onboardingComplete,
  }) => StudentProfile(
    displayName: displayName ?? this.displayName,
    email: email ?? this.email,
    university: university ?? this.university,
    universityId: universityId ?? this.universityId,
    degree: degree ?? this.degree,
    department: department ?? this.department,
    currentSemester: currentSemester ?? this.currentSemester,
    academicYear: academicYear ?? this.academicYear,
    timezone: timezone ?? this.timezone,
    preferredWeekStart: preferredWeekStart ?? this.preferredWeekStart,
    theme: theme ?? this.theme,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    studyGoals: studyGoals ?? this.studyGoals,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
  );

  Map<String, Object?> toMap() => {
    'displayName': displayName.trim(),
    'email': email.trim().toLowerCase(),
    'university': university?.trim(),
    'universityId': universityId,
    'degree': degree?.trim(),
    'department': department?.trim(),
    'currentSemester': currentSemester?.trim(),
    'academicYear': academicYear?.trim(),
    'timezone': timezone,
    'preferredWeekStart': preferredWeekStart,
    'theme': theme,
    'notificationsEnabled': notificationsEnabled,
    'studyGoals': studyGoals,
    'onboardingComplete': onboardingComplete,
    'schemaVersion': 1,
  };

  factory StudentProfile.fromMap(Map<String, dynamic> map) => StudentProfile(
    displayName: map['displayName'] as String? ?? '',
    email: map['email'] as String? ?? '',
    university: map['university'] as String?,
    universityId: map['universityId'] as String?,
    degree: map['degree'] as String?,
    department: map['department'] as String?,
    currentSemester: map['currentSemester'] as String?,
    academicYear: map['academicYear'] as String?,
    timezone: map['timezone'] as String? ?? 'UTC',
    preferredWeekStart: map['preferredWeekStart'] as int? ?? 1,
    theme: map['theme'] as String? ?? 'system',
    notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    studyGoals: List<String>.from(map['studyGoals'] as List? ?? const []),
    onboardingComplete: map['onboardingComplete'] as bool? ?? false,
  );
}
