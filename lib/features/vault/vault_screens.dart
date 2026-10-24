import 'package:flutter/material.dart';

import '../../ui/planner_design.dart';
import '../planner/planner_screens.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final searchController = TextEditingController();
  String filter = 'All';
  bool favoritesOnly = false;
  final Set<String> favoriteIds = {'design-notes', 'hci-cards'};
  final List<_VaultItem> createdItems = [];

  static const _items = [
    _VaultItem(
      'design-notes',
      'Design thinking notes',
      'Note · Design studio',
      'Notes',
    ),
    _VaultItem(
      'research-file',
      'Research reflection draft',
      'Document · Research methods',
      'Files',
    ),
    _VaultItem(
      'hci-cards',
      'Interaction principles',
      'Flashcards · HCI',
      'Flashcards',
    ),
    _VaultItem(
      'reading-links',
      'Course reading list',
      'Resource · Design studio',
      'Resources',
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = searchController.text.trim().toLowerCase();
    final filtered = [..._items, ...createdItems].where((item) {
      return (filter == 'All' || item.type == filter) &&
          (!favoritesOnly || favoriteIds.contains(item.id)) &&
          ('${item.title} ${item.detail}'.toLowerCase().contains(query));
    }).toList();

    return PlannerPage(
      title: 'Academic Vault',
      subtitle: 'Your subject materials, collected in one place.',
      actions: [
        IconButton(
          tooltip: 'Add a note',
          onPressed: () => _createNote(context),
          icon: const Icon(Icons.note_add_outlined),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PreviewBanner(),
          const SizedBox(height: 14),
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search notes and resources',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        searchController.clear();
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
            spacing: 7,
            children: [
              for (final option in [
                'All',
                'Notes',
                'Files',
                'Flashcards',
                'Resources',
              ])
                FilterChip(
                  label: Text(option),
                  selected: filter == option,
                  onSelected: (_) => setState(() => filter = option),
                ),
              FilterChip(
                label: const Text('Favorites'),
                selected: favoritesOnly,
                onSelected: (_) =>
                    setState(() => favoritesOnly = !favoritesOnly),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            EmptyState(
              title: 'No materials found',
              message: query.isEmpty
                  ? 'Add a note or file to start your Vault.'
                  : 'Try another search or content filter.',
              icon: Icons.auto_stories_outlined,
              actionLabel: 'Create a note',
              onAction: () => _createNote(context),
            )
          else
            for (final item in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  tileColor: PlannerColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: item.type == 'Files'
                        ? PlannerColors.blush
                        : PlannerColors.lavender,
                    child: Icon(
                      _iconFor(item.type),
                      color: PlannerColors.deepPurple,
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(item.detail),
                  trailing: IconButton(
                    tooltip: favoriteIds.contains(item.id)
                        ? 'Remove favorite'
                        : 'Add to favorites',
                    onPressed: () => setState(() {
                      if (!favoriteIds.add(item.id)) {
                        favoriteIds.remove(item.id);
                      }
                    }),
                    icon: Icon(
                      favoriteIds.contains(item.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favoriteIds.contains(item.id)
                          ? PlannerColors.purple
                          : null,
                    ),
                  ),
                  onTap: () => _openItem(context, item),
                ),
              ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _push(context, const CopilotScreen()),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Ask the study copilot'),
          ),
        ],
      ),
    );
  }

  void _openItem(BuildContext context, _VaultItem item) {
    switch (item.type) {
      case 'Notes':
        _push(context, const NoteViewerScreen());
      case 'Files':
        _push(context, const FileViewerScreen());
      case 'Flashcards':
        _push(context, const FlashcardsScreen());
      default:
        _push(context, const ResourceDetailScreen());
    }
  }

  Future<void> _createNote(BuildContext context) async {
    final title = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const NoteEditorScreen()),
    );
    if (title == null || !mounted || !context.mounted) return;
    setState(() {
      createdItems.insert(
        0,
        _VaultItem(
          'note-${DateTime.now().microsecondsSinceEpoch}',
          title,
          'Note · This device preview',
          'Notes',
        ),
      );
    });
    showPlannerMessage(context, 'Note added to this session.');
  }

  IconData _iconFor(String type) => switch (type) {
    'Files' => Icons.picture_as_pdf_outlined,
    'Flashcards' => Icons.style_outlined,
    'Resources' => Icons.link_rounded,
    _ => Icons.note_alt_outlined,
  };
}

class _VaultItem {
  const _VaultItem(this.id, this.title, this.detail, this.type);

  final String id;
  final String title;
  final String detail;
  final String type;
}

class NoteViewerScreen extends StatelessWidget {
  const NoteViewerScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Design thinking notes',
    subtitle: 'Subject: Design studio · Preview content',
    actions: [
      IconButton(
        tooltip: 'Edit note',
        onPressed: () => _push(context, const NoteEditorScreen()),
        icon: const Icon(Icons.edit_outlined),
      ),
    ],
    child: const PlannerCard(
      child: Text(
        'Add your own lecture notes here. This example is placeholder content to demonstrate the reading layout; it is not an uploaded class document.',
        style: TextStyle(color: PlannerColors.ink, height: 1.55),
      ),
    ),
  );
}

class FileViewerScreen extends StatelessWidget {
  const FileViewerScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'File preview',
    subtitle: 'No file is attached in this preview.',
    child: const EmptyState(
      title: 'Choose a document to preview',
      message: 'PDF and document previews will appear here after you add a supported file.',
      icon: Icons.picture_as_pdf_outlined,
    ),
  );
}

class ResourceDetailScreen extends StatelessWidget {
  const ResourceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'Course reading list',
    subtitle: 'Resource links are added by you.',
    child: EmptyState(
      title: 'No source links yet',
      message:
          'Save a course or library link to keep it with your study materials.',
      icon: Icons.link_rounded,
      actionLabel: 'Add a link',
      onAction: () => _addLink(context),
    ),
  );

  Future<void> _addLink(BuildContext context) async {
    final controller = TextEditingController();
    final link = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a resource link'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(labelText: 'Title or URL'),
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
    if (!context.mounted || link == null) return;
    showPlannerMessage(context, 'Resource saved for this preview.');
  }
}

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PlannerPage(
    title: 'New note',
    subtitle: 'Add a note to your study collection.',
    child: Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Note title',
              filled: true,
              fillColor: PlannerColors.surface,
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Add a title' : null,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: bodyController,
            minLines: 7,
            maxLines: 14,
            decoration: const InputDecoration(
              labelText: 'Write your note',
              alignLabelWithHint: true,
              filled: true,
              fillColor: PlannerColors.surface,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context, titleController.text.trim());
              },
              child: const Text('Save note'),
            ),
          ),
        ],
      ),
    ),
  );
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int index = 0;
  bool showingAnswer = false;

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
  Widget build(BuildContext context) => PlannerPage(
    title: 'Flashcards',
    subtitle: 'Tap the card to reveal the answer.',
    child: Column(
      children: [
        PlannerCard(
          color: showingAnswer ? PlannerColors.lavender : PlannerColors.blush,
          onTap: () => setState(() => showingAnswer = !showingAnswer),
          child: SizedBox(
            width: double.infinity,
            height: 220,
            child: Center(
              child: Text(
                showingAnswer ? cards[index].$2 : cards[index].$1,
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
        const SizedBox(height: 10),
        Text('${index + 1} of ${cards.length} · preview cards'),
        const SizedBox(height: 10),
        FilledButton.tonal(
          onPressed: () => setState(() {
            index = (index + 1) % cards.length;
            showingAnswer = false;
          }),
          child: const Text('Next card'),
        ),
      ],
    ),
  );
}

void _push(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}
