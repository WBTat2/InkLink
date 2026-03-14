import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../widgets/coil_progress.dart';
import '../storage/draft_store.dart';

class OwnerFlowScreen extends StatefulWidget {
  const OwnerFlowScreen({super.key});

  @override
  State<OwnerFlowScreen> createState() => _OwnerFlowScreenState();
}

class _OwnerFlowScreenState extends State<OwnerFlowScreen> {
  int _step = 0;
  bool _hydrated = false;

  final _displayName = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _bio = TextEditingController();

  // Owner-specific “type” chips (shop/convention/etc.)
  final List<String> _allOwnerTypes = const [
    'Shop Owner',
    'Convention Organizer',
    'Studio Manager',
    'Guest Spot Host',
  ];

  final Set<String> _selectedTypes = {};
  String? _profileImagePath;

  final ScrollController _scrollCtrl = ScrollController();

  Map<String, dynamic> _buildDraft() {
    return {
      'role': 'owner',
      'displayName': _displayName.text.trim(),
      'city': _city.text.trim(),
      'state': _state.text.trim(),
      'bio': _bio.text.trim(),
      'ownerTypes': _selectedTypes.toList(),
      'step': _step,
      'profileImagePath': _profileImagePath,
    };
  }

  void _applyDraft(Map<String, dynamic> draft) {
    _displayName.text = (draft['displayName'] ?? '').toString();
    _city.text = (draft['city'] ?? '').toString();
    _state.text = (draft['state'] ?? '').toString();
    _bio.text = (draft['bio'] ?? '').toString();

    final typesRaw = draft['ownerTypes'];
    final types = (typesRaw is List) ? typesRaw : <dynamic>[];
    _selectedTypes
      ..clear()
      ..addAll(types.map((e) => e.toString()));

    final stepVal = draft['step'];
    final int stepInt = (stepVal is int) ? stepVal : int.tryParse('$stepVal') ?? 0;
    _step = stepInt.clamp(0, 3);

    final path = (draft['profileImagePath'] ?? '').toString().trim();
    _profileImagePath = path.isEmpty ? null : path;
  }

  Future<void> _loadDraftFromDisk() async {
    final draft = await DraftStore.load();
    if (!mounted || draft == null) return;

    // Only hydrate if it’s an owner draft (prevents cross-role pollution)
    if ((draft['role'] ?? '').toString() != 'owner') return;

    setState(() => _applyDraft(draft));
  }

  Future<void> _saveDraft() async => DraftStore.save(_buildDraft());

  Future<void> _pickProfileImage() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'Images', extensions: ['png', 'jpg', 'jpeg', 'heic']),
      ],
    );
    if (file == null) return;

    setState(() => _profileImagePath = file.path);
    await _saveDraft();
  }

  @override
  void initState() {
    super.initState();
    _loadDraftFromDisk();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;
    _hydrated = true;

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    // allow hub "Edit Profile" to hydrate owner again
    if ((args['role'] ?? '').toString() != 'owner') return;
    setState(() => _applyDraft(args));
  }

  @override
  void dispose() {
    _displayName.dispose();
    _city.dispose();
    _state.dispose();
    _bio.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _stepTitle() {
    switch (_step) {
      case 0:
        return 'Basics';
      case 1:
        return 'Home Base';
      case 2:
        return 'Type';
      case 3:
        return 'Bio';
      default:
        return 'Owner Setup';
    }
  }

  bool _basicsValid() => _displayName.text.trim().isNotEmpty;

  void _backPressed() async {
    if (_step > 0) {
      setState(() => _step--);
      await _saveDraft();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _next() async {
    await _saveDraft();

    if (_step == 0 && !_basicsValid()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a display name first.')),
      );
      return;
    }

    if (_step < 3) {
      setState(() => _step++);
      return;
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/ownerHub',
      arguments: {
        ..._buildDraft(),
        'role': 'owner',
      },
    );
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Profile Picture (optional)',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                      image: _profileImagePath == null
                          ? null
                          : DecorationImage(
                              image: FileImage(File(_profileImagePath!)),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: _profileImagePath == null
                        ? const Icon(Icons.storefront,
                            color: Colors.white54, size: 34)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickProfileImage,
                      child: Text(_profileImagePath == null
                          ? 'Choose Profile Picture'
                          : 'Change Picture'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayName,
                decoration: const InputDecoration(labelText: 'Display Name'),
                onChanged: (_) => _saveDraft(),
              ),
            ],
          ),
        );

      case 1:
        return _card(Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _city,
                decoration: const InputDecoration(labelText: 'City'),
                onChanged: (_) => _saveDraft(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _state,
                decoration: const InputDecoration(labelText: 'State'),
                onChanged: (_) => _saveDraft(),
              ),
            ),
          ],
        ));

      case 2:
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('What are you here as?',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _allOwnerTypes.map((t) {
                  final selected = _selectedTypes.contains(t);
                  return FilterChip(
                    label: Text(t),
                    selected: selected,
                    onSelected: (v) async {
                      setState(() {
                        v ? _selectedTypes.add(t) : _selectedTypes.remove(t);
                      });
                      await _saveDraft();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );

      case 3:
        return _card(TextFormField(
          controller: _bio,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Bio'),
          onChanged: (_) => _saveDraft(),
        ));

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _backPressed,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CoilProgress(step: _step),
              const SizedBox(height: 16),
              Expanded(
                child: Scrollbar(
                  controller: _scrollCtrl,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _stepBody(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _next,
                child: Text(_step == 3 ? 'Finish' : 'Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
