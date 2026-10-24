import 'package:flutter/material.dart';

import '../../data/account_service.dart';
import '../../data/student_profile.dart';
import '../../ui/planner_design.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    required this.onContinueAsGuest,
    this.accountService,
    super.key,
  });

  final VoidCallback onContinueAsGuest;
  final AccountService? accountService;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _WelcomeIllustration(),
                const SizedBox(height: 22),
                const Text(
                  'A little more room\nfor everything.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: PlannerColors.ink,
                    fontSize: 30,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Make space for classes, goals, and the life in between.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PlannerColors.mutedInk, height: 1.4),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => _push(context, const OnboardingScreen()),
                    child: const Text('Set up my space'),
                  ),
                ),
                TextButton(
                  onPressed: onContinueAsGuest,
                  child: const Text('Continue to the planner preview'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => _push(
                        context,
                        AccountFormScreen(
                          register: false,
                          accountService: accountService,
                        ),
                      ),
                      child: const Text('Log in'),
                    ),
                    const Text(
                      '·',
                      style: TextStyle(color: PlannerColors.mutedInk),
                    ),
                    TextButton(
                      onPressed: () => _push(
                        context,
                        AccountFormScreen(
                          register: true,
                          accountService: accountService,
                        ),
                      ),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  accountService == null
                      ? 'Account services are not connected in this preview.'
                      : 'Sign in to keep your planner private and in sync.',
                  style: TextStyle(color: PlannerColors.mutedInk, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _WelcomeIllustration(),
            const SizedBox(height: 18),
            const Text(
              'My Little Planner',
              style: TextStyle(
                color: PlannerColors.deepPurple,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'A calm home for your busy days.',
              style: TextStyle(color: PlannerColors.mutedInk),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Back to planner'),
            ),
          ],
        ),
      ),
    ),
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    this.accountService,
    this.uid,
    this.profile,
    this.onSaved,
    super.key,
  });

  final AccountService? accountService;
  final String? uid;
  final StudentProfile? profile;
  final VoidCallback? onSaved;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final universityController = TextEditingController();
  final departmentController = TextEditingController();
  final semesterController = TextEditingController();
  final academicYearController = TextEditingController();
  final timezoneController = TextEditingController();
  final goalsController = TextEditingController();
  String degree = 'Undergraduate';
  int preferredWeekStart = 1;
  bool reminders = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    if (profile != null) {
      nameController.text = profile.displayName;
      universityController.text = profile.university ?? '';
      departmentController.text = profile.department ?? '';
      semesterController.text = profile.currentSemester ?? '';
      academicYearController.text = profile.academicYear ?? '';
      timezoneController.text = profile.timezone;
      degree = profile.degree ?? degree;
      preferredWeekStart = profile.preferredWeekStart;
      reminders = profile.notificationsEnabled;
      goalsController.text = profile.studyGoals.join(', ');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    universityController.dispose();
    departmentController.dispose();
    semesterController.dispose();
    academicYearController.dispose();
    timezoneController.dispose();
    goalsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Set up your space',
    subtitle: 'The optional details can be changed whenever you need.',
    child: Form(
      key: formKey,
      child: Column(
        children: [
          const PreviewBanner(),
          const SizedBox(height: 14),
          PlannerCard(
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'What should we call you?',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: universityController,
                  decoration: const InputDecoration(
                    labelText: 'University (optional)',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: semesterController,
                  decoration: const InputDecoration(
                    labelText: 'Current semester (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: academicYearController,
                  decoration: const InputDecoration(
                    labelText: 'Academic year (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: timezoneController,
                  decoration: const InputDecoration(
                    labelText: 'Timezone (for example, Europe/London)',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: degree,
                  decoration: const InputDecoration(labelText: 'Study level'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Undergraduate',
                      child: Text('Undergraduate'),
                    ),
                    DropdownMenuItem(
                      value: 'Postgraduate',
                      child: Text('Postgraduate'),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Text('Other / prefer not to say'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => degree = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: preferredWeekStart,
                  decoration: const InputDecoration(
                    labelText: 'First day of the week',
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Monday')),
                    DropdownMenuItem(value: 7, child: Text('Sunday')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => preferredWeekStart = value);
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Gentle reminders'),
                  subtitle: const Text('Optional · can be changed later'),
                  value: reminders,
                  onChanged: (value) => setState(() => reminders = value),
                ),
                TextFormField(
                  controller: goalsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Study goals (optional)',
                    hintText: 'Separate goals with commas',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: saving ? null : _finish,
              child: Text(saving ? 'Saving…' : 'Save and continue'),
            ),
          ),
          TextButton(
            onPressed: saving ? null : _finish,
            child: const Text('Skip for now'),
          ),
        ],
      ),
    ),
  );

  Future<void> _finish() async {
    if (nameController.text.trim().isNotEmpty &&
        !formKey.currentState!.validate()) {
      return;
    }
    final service = widget.accountService;
    final uid = widget.uid;
    if (service != null && uid != null) {
      setState(() => saving = true);
      final profile =
          (widget.profile ??
                  StudentProfile(
                    displayName: nameController.text.trim(),
                    email: '',
                  ))
              .copyWith(
                displayName: nameController.text.trim(),
                university: universityController.text,
                degree: degree,
                department: departmentController.text,
                currentSemester: semesterController.text,
                academicYear: academicYearController.text,
                timezone: timezoneController.text.trim().isEmpty
                    ? 'UTC'
                    : timezoneController.text.trim(),
                notificationsEnabled: reminders,
                preferredWeekStart: preferredWeekStart,
                studyGoals: goalsController.text
                    .split(',')
                    .map((goal) => goal.trim())
                    .where((goal) => goal.isNotEmpty)
                    .toList(),
                onboardingComplete: true,
              );
      try {
        await service.saveProfile(uid, profile);
      } on AccountFailure catch (error) {
        if (mounted) showPlannerMessage(context, error.message);
        return;
      } finally {
        if (mounted) setState(() => saving = false);
      }
      if (!mounted) return;
    }
    if (widget.onSaved != null) {
      widget.onSaved!();
    } else {
      Navigator.of(context).pop();
    }
    if (mounted) {
      showPlannerMessage(
        context,
        service == null
            ? 'Setup saved for this session.'
            : 'Your profile was saved.',
      );
    }
  }
}

class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({
    required this.register,
    this.accountService,
    super.key,
  });

  final bool register;
  final AccountService? accountService;

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  bool obscurePassword = true;
  bool submitting = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: widget.register ? 'Create account' : 'Welcome back',
    subtitle: widget.register
        ? 'Create a secure account for your student planner.'
        : 'Sign in to continue to your planner.',
    child: Form(
      key: formKey,
      child: Column(
        children: [
          if (widget.accountService == null) const PreviewBanner(),
          const SizedBox(height: 14),
          PlannerCard(
            child: Column(
              children: [
                if (widget.register) ...[
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: obscurePassword
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    if (widget.register && value.length < 8) {
                      return 'Use at least 8 characters';
                    }
                    return null;
                  },
                ),
                if (!widget.register)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _resetPassword(context),
                      child: const Text('Forgot password?'),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: submitting ? null : _submit,
                    child: Text(
                      submitting
                          ? 'Please wait…'
                          : widget.register
                          ? 'Create account'
                          : 'Log in',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.accountService == null
                ? 'Firebase is not configured. Credentials will not be sent.'
                : 'Your password is handled by Firebase Authentication.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: PlannerColors.mutedInk, fontSize: 11),
          ),
        ],
      ),
    ),
  );

  Future<void> _submit() async {
    if (!formKey.currentState!.validate()) return;
    final service = widget.accountService;
    if (service == null) {
      showPlannerMessage(
        context,
        'Firebase is not configured; no credentials were sent.',
      );
      return;
    }
    setState(() => submitting = true);
    try {
      if (widget.register) {
        await service.register(
          email: emailController.text.trim(),
          password: passwordController.text,
          displayName: nameController.text.trim(),
        );
      } else {
        await service.signIn(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AccountFailure catch (error) {
      if (mounted) showPlannerMessage(context, error.message);
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Future<void> _resetPassword(BuildContext context) async {
    final resetController = TextEditingController(text: emailController.text);
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset password'),
        content: TextField(
          controller: resetController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Account email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (resetController.text.contains('@')) {
                Navigator.pop(dialogContext, resetController.text.trim());
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    resetController.dispose();
    if (email == null || !context.mounted) return;
    final service = widget.accountService;
    if (service == null) {
      showPlannerMessage(
        context,
        'Firebase is not configured; no reset email was sent.',
      );
      return;
    }
    try {
      await service.sendPasswordReset(email);
      if (context.mounted) {
        showPlannerMessage(
          context,
          'If an account exists for that email, reset instructions are on the way.',
        );
      }
    } on AccountFailure catch (error) {
      if (context.mounted) showPlannerMessage(context, error.message);
    }
  }
}

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLogout,
    this.profile,
    this.accountService,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final Future<void> Function() onLogout;
  final StudentProfile? profile;
  final AccountService? accountService;

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool remindersEnabled = true;
  bool localOnly = false;
  bool _loggingOut = false;
  StudentProfile? _profile;

  @override
  void initState() {
    super.initState();
    remindersEnabled = widget.profile?.notificationsEnabled ?? true;
    _profile = widget.profile;
  }

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Profile & settings',
    subtitle: widget.accountService == null
        ? 'Your preferences for this local preview.'
        : 'Your private student profile and account preferences.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.accountService == null) const PreviewBanner(),
        const SizedBox(height: 14),
        PlannerCard(
          color: PlannerColors.lavender,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: PlannerColors.purple),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?.displayName.isNotEmpty == true
                          ? _profile!.displayName
                          : 'Student profile',
                      style: TextStyle(
                        color: PlannerColors.deepPurple,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _profile?.university?.isNotEmpty == true
                          ? _profile!.university!
                          : 'University details not set',
                      style: TextStyle(color: PlannerColors.deepPurple),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeading(title: 'Preferences'),
        RadioGroup<ThemeMode>(
          groupValue: widget.themeMode,
          onChanged: (value) {
            if (value != null) {
              widget.onThemeChanged(value);
              _saveProfilePreferences(theme: value.name);
            }
          },
          child: const Column(
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                title: Text('Light appearance'),
                activeColor: PlannerColors.purple,
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                title: Text('Dark appearance'),
                activeColor: PlannerColors.purple,
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                title: Text('Follow device setting'),
                activeColor: PlannerColors.purple,
              ),
            ],
          ),
        ),
        SwitchListTile(
          value: remindersEnabled,
          onChanged: (value) {
            setState(() => remindersEnabled = value);
            _saveNotificationPreference(value);
          },
          title: const Text('Reminder preferences'),
          subtitle: Text(
            widget.accountService == null
                ? 'Local preference preview'
                : 'Saved to your student profile',
          ),
        ),
        if (widget.accountService == null)
          SwitchListTile(
            value: localOnly,
            onChanged: (value) => setState(() => localOnly = value),
            title: const Text('Keep data on this device'),
            subtitle: const Text(
              'Preview only; no account or sync service is connected',
            ),
          ),
        const SizedBox(height: 12),
        const SectionHeading(title: 'Account & data'),
        _SettingsAction(
          title: 'Edit student profile',
          icon: Icons.school_outlined,
          onTap: () => _push(
            context,
            OnboardingScreen(
              accountService: widget.accountService,
              uid: widget.accountService?.currentIdentity?.uid,
              profile: _profile,
              onSaved: () {
                Navigator.of(context).pop();
                _reloadProfile();
              },
            ),
          ),
        ),
        _SettingsAction(
          title: 'Export data',
          icon: Icons.download_outlined,
          onTap: () => _confirmExport(context),
        ),
        _SettingsAction(
          title: 'Delete account and data',
          icon: Icons.delete_outline,
          onTap: () => _deleteAccount(context),
        ),
        _SettingsAction(
          title: 'Preview loading, offline, and error states',
          icon: Icons.bug_report_outlined,
          onTap: () => _push(context, const PreviewStatesScreen()),
        ),
        _SettingsAction(
          title: 'View welcome screen',
          icon: Icons.waving_hand_outlined,
          onTap: () => _push(
            context,
            WelcomeScreen(
              accountService: widget.accountService,
              onContinueAsGuest: () => Navigator.pop(context),
            ),
          ),
        ),
        _SettingsAction(
          title: 'View launch screen',
          icon: Icons.rocket_launch_outlined,
          onTap: () => _push(context, const SplashScreen()),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _loggingOut ? null : () => _logout(context),
            icon: const Icon(Icons.logout),
            label: Text(
              widget.accountService == null ? 'Log out of preview' : 'Log out',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.accountService == null
              ? 'This preview keeps planner changes in memory; restarting the app resets them.'
              : 'Your profile is stored in Firebase. Planner records are private to your account.',
          style: TextStyle(color: PlannerColors.mutedInk, fontSize: 11),
        ),
      ],
    ),
  );

  Future<void> _saveNotificationPreference(bool enabled) =>
      _saveProfilePreferences(notificationsEnabled: enabled);

  Future<void> _saveProfilePreferences({
    bool? notificationsEnabled,
    String? theme,
  }) async {
    final service = widget.accountService;
    final profile = _profile;
    final uid = service?.currentIdentity?.uid;
    if (service == null || profile == null || uid == null) return;
    try {
      await service.saveProfile(
        uid,
        _profile = profile.copyWith(
          notificationsEnabled: notificationsEnabled,
          theme: theme,
        ),
      );
      if (mounted) setState(() {});
    } on AccountFailure catch (error) {
      if (mounted) showPlannerMessage(context, error.message);
    }
  }

  Future<void> _reloadProfile() async {
    final service = widget.accountService;
    final uid = service?.currentIdentity?.uid;
    if (service == null || uid == null) return;
    try {
      final profile = await service.loadProfile(uid);
      if (mounted) setState(() => _profile = profile);
    } on AccountFailure catch (error) {
      if (mounted) showPlannerMessage(context, error.message);
    }
  }

  Future<void> _logout(BuildContext context) async {
    setState(() => _loggingOut = true);
    try {
      await widget.onLogout();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AccountFailure catch (error) {
      if (context.mounted) showPlannerMessage(context, error.message);
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final service = widget.accountService;
    if (service == null) {
      showPlannerMessage(
        context,
        'No connected account exists to delete in this preview.',
      );
      return;
    }
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account and data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your Firebase profile, planner records, and uploaded attachments.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm your password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Navigator.pop(dialogContext, passwordController.text);
              }
            },
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (password == null || !context.mounted) return;
    try {
      await service.deleteAccount(password: password);
      if (context.mounted) {
        showPlannerMessage(context, 'Your account and data were deleted.');
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on AccountFailure catch (error) {
      if (context.mounted) showPlannerMessage(context, error.message);
    }
  }

  Future<void> _confirmExport(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Export preview data?'),
        content: const Text(
          'This UI preview has no export service. No file will be created.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      showPlannerMessage(context, 'Export is not connected in this preview.');
    }
  }
}

class PreviewStatesScreen extends StatefulWidget {
  const PreviewStatesScreen({super.key});

  @override
  State<PreviewStatesScreen> createState() => _PreviewStatesScreenState();
}

class _PreviewStatesScreenState extends State<PreviewStatesScreen> {
  bool loading = false;
  bool showError = false;

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Preview states',
    subtitle: 'Examples used to verify loading, offline, and error layouts.',
    child: Column(
      children: [
        const PlannerCard(
          color: PlannerColors.lavender,
          child: Row(
            children: [
              Icon(Icons.cloud_off_outlined, color: PlannerColors.deepPurple),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Offline · changes are local to this preview session.',
                  style: TextStyle(color: PlannerColors.deepPurple),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (loading)
          const PlannerCard(
            child: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 14),
                Text('Loading your preview…'),
              ],
            ),
          )
        else if (showError)
          PlannerCard(
            color: const Color(0xFFFFE4E1),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: PlannerColors.error),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Could not load this sample. Your local task list is unchanged.',
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => showError = false),
                  child: const Text('Retry'),
                ),
              ],
            ),
          )
        else
          const EmptyState(
            title: 'Nothing to load right now',
            message: 'Use the controls below to preview other states.',
            icon: Icons.inbox_outlined,
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              onPressed: _simulateLoading,
              child: const Text('Preview loading'),
            ),
            OutlinedButton(
              onPressed: () => setState(() => showError = true),
              child: const Text('Preview error'),
            ),
          ],
        ),
      ],
    ),
  );

  Future<void> _simulateLoading() async {
    setState(() {
      loading = true;
      showError = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => loading = false);
  }
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: PlannerColors.purple),
    title: Text(title, style: const TextStyle(fontSize: 14)),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) => Container(
    width: 170,
    height: 170,
    decoration: BoxDecoration(
      color: PlannerColors.purple,
      borderRadius: BorderRadius.circular(48),
    ),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F95B),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.sentiment_satisfied_alt_rounded,
            color: PlannerColors.deepPurple,
            size: 60,
          ),
        ),
        const Positioned(
          top: 18,
          right: 22,
          child: Icon(Icons.auto_awesome, color: PlannerColors.lime, size: 24),
        ),
        const Positioned(
          bottom: 23,
          left: 25,
          child: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
        ),
      ],
    ),
  );
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
