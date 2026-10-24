import 'package:flutter/material.dart';

import '../data/account_service.dart';
import '../data/planner_store.dart';
import '../data/student_profile.dart';
import '../features/account/account_screens.dart';
import '../features/academics/academic_screens.dart';
import '../features/life/life_screens.dart';
import '../features/planner/planner_screens.dart';
import '../features/today/today_screen.dart';
import '../features/vault/vault_screens.dart';
import '../ui/planner_design.dart';

class MyPlannerApp extends StatefulWidget {
  const MyPlannerApp({this.accountService, this.taskPersistence, super.key});

  final AccountService? accountService;
  final TaskPersistence? taskPersistence;

  @override
  State<MyPlannerApp> createState() => _MyPlannerAppState();
}

class _MyPlannerAppState extends State<MyPlannerApp> {
  PlannerStore store = PlannerStore();
  PlannerStore? _accountStore;
  String? _accountStoreUid;
  Stream<AccountIdentity?>? _authChanges;
  String? _loadedThemeUid;
  ThemeMode themeMode = ThemeMode.light;
  bool showWelcome = false;
  bool guestMode = false;

  @override
  void initState() {
    super.initState();
    _authChanges = widget.accountService?.authStateChanges();
  }

  @override
  void dispose() {
    store.dispose();
    _accountStore?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'My Little Planner',
    themeMode: themeMode,
    theme: _buildTheme(Brightness.light),
    darkTheme: _buildTheme(Brightness.dark),
    home: _home(),
  );

  Widget _home() {
    final accountService = widget.accountService;
    if (accountService == null) {
      return showWelcome
          ? WelcomeScreen(onContinueAsGuest: _continueToPlanner)
          : PlannerShell(
              store: store,
              themeMode: themeMode,
              onThemeChanged: (value) => setState(() => themeMode = value),
              onLogout: () async => _showWelcome(),
            );
    }
    return StreamBuilder<AccountIdentity?>(
      stream: _authChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.hasError) {
          return _accountError(
            'Could not check your sign-in session. Check your connection and retry.',
          );
        }
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final identity = authSnapshot.data;
        if (identity == null) {
          if (guestMode) {
            return PlannerShell(
              store: store,
              themeMode: themeMode,
              accountService: accountService,
              onThemeChanged: (value) => setState(() => themeMode = value),
              onLogout: () async => _leaveGuestPreview(),
            );
          }
          return WelcomeScreen(
            accountService: accountService,
            onContinueAsGuest: _continueToPlanner,
          );
        }
        return FutureBuilder<StudentProfile?>(
          key: ValueKey(identity.uid),
          future: accountService.loadProfile(identity.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.hasError) {
              return _accountError(
                profileSnapshot.error is AccountFailure
                    ? (profileSnapshot.error! as AccountFailure).message
                    : 'Could not load your profile. Please try again.',
              );
            }
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final profile = profileSnapshot.data;
            if (profile == null || !profile.onboardingComplete) {
              return OnboardingScreen(
                accountService: accountService,
                uid: identity.uid,
                onSaved: () => setState(() {}),
                profile:
                    profile ??
                    StudentProfile(displayName: '', email: identity.email),
              );
            }
            if (_loadedThemeUid != identity.uid) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _loadedThemeUid != identity.uid) {
                  setState(() {
                    _loadedThemeUid = identity.uid;
                    themeMode = _themeMode(profile.theme);
                  });
                }
              });
            }
            return PlannerShell(
              store: _storeFor(identity.uid),
              themeMode: themeMode,
              profile: profile,
              accountService: accountService,
              onThemeChanged: (value) => setState(() {
                themeMode = value;
              }),
              onLogout: _signOut,
            );
          },
        );
      },
    );
  }

  Widget _accountError(String message) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() {}),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    ),
  );

  PlannerStore _storeFor(String uid) {
    if (_accountStoreUid != uid) {
      _accountStore?.dispose();
      _accountStore = PlannerStore(
        includePreviewData: false,
        persistence: widget.taskPersistence,
      );
      _accountStoreUid = uid;
    }
    return _accountStore!;
  }

  ThemeMode _themeMode(String theme) => switch (theme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  ThemeData _buildTheme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF17151D)
          : PlannerColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: PlannerColors.purple,
        brightness: brightness,
        surface: dark ? const Color(0xFF25222D) : PlannerColors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF17151D) : PlannerColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF25222D) : PlannerColors.surface,
        indicatorColor: PlannerColors.lavender,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF25222D) : PlannerColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      fontFamily: 'Roboto',
    );
  }

  void _continueToPlanner() => setState(() {
    showWelcome = false;
    guestMode = true;
  });

  void _leaveGuestPreview() => setState(() => guestMode = false);

  Future<void> _signOut() async {
    await widget.accountService!.signOut();
    if (mounted) setState(() => guestMode = false);
  }

  void _showWelcome() {
    setState(() {
      store.dispose();
      store = PlannerStore();
      showWelcome = true;
    });
  }
}

class PlannerShell extends StatefulWidget {
  const PlannerShell({
    required this.store,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onLogout,
    this.profile,
    this.accountService,
    super.key,
  });

  final PlannerStore store;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final Future<void> Function() onLogout;
  final StudentProfile? profile;
  final AccountService? accountService;

  @override
  State<PlannerShell> createState() => _PlannerShellState();
}

class _PlannerShellState extends State<PlannerShell> {
  int selectedIndex = 0;

  static const destinations = [
    (label: 'Today', icon: Icons.wb_sunny_rounded),
    (label: 'Academics', icon: Icons.menu_book_rounded),
    (label: 'Planner', icon: Icons.calendar_month_rounded),
    (label: 'Vault', icon: Icons.auto_stories_rounded),
    (label: 'My Life', icon: Icons.favorite_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(
        store: widget.store,
        onProfile: () => _openSettings(context),
        displayName: widget.profile?.displayName,
      ),
      AcademicOverviewScreen(store: widget.store),
      PlannerHomeScreen(store: widget.store),
      const VaultScreen(),
      MyLifeScreen(onSettings: () => _openSettings(context)),
    ];
    final isWide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: _selectTab,
                    labelType: NavigationRailLabelType.all,
                    backgroundColor: PlannerColors.surface,
                    indicatorColor: PlannerColors.lavender,
                    destinations: [
                      for (final destination in destinations)
                        NavigationRailDestination(
                          icon: Icon(destination.icon),
                          selectedIcon: Icon(
                            destination.icon,
                            color: PlannerColors.purple,
                          ),
                          label: Text(destination.label),
                        ),
                    ],
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: IconButton(
                          tooltip: 'Profile and settings',
                          onPressed: () => _openSettings(context),
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 980),
                        child: IndexedStack(
                          index: selectedIndex,
                          children: pages,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : IndexedStack(index: selectedIndex, children: pages),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              backgroundColor: Theme.of(context)
                  .navigationBarTheme
                  .backgroundColor,
              indicatorColor: PlannerColors.lavender,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              onDestinationSelected: _selectTab,
              destinations: [
                for (final destination in destinations)
                  NavigationDestination(
                    key: ValueKey('nav-${destination.label}'),
                    icon: Icon(destination.icon),
                    selectedIcon: Icon(
                      destination.icon,
                      color: PlannerColors.purple,
                    ),
                    label: destination.label,
                  ),
              ],
            ),
    );
  }

  void _selectTab(int index) => setState(() => selectedIndex = index);

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileSettingsScreen(
          themeMode: widget.themeMode,
          onThemeChanged: widget.onThemeChanged,
          onLogout: widget.onLogout,
          profile: widget.profile,
          accountService: widget.accountService,
        ),
      ),
    );
  }
}
