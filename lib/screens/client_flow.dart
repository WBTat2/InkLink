import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../widgets/coil_progress.dart';
import '../storage/draft_store.dart';

class ClientFlowScreen extends StatefulWidget {
  const ClientFlowScreen({super.key});

  @override
  State<ClientFlowScreen> createState() => _ClientFlowScreenState();
}

class _ClientFlowScreenState extends State<ClientFlowScreen> {
  int _step = 0;
  bool _hydrated = false;

  final _displayName = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _bio = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<String> _allStyles = const [
    'Black & Grey',
    'Traditional',
    'Neo-Traditional',
    'Realism',
    'Fine Line',
    'Illustrative',
    'Lettering',
    'Japanese',
    'Color',
    'Micro Tattoos',
    'Cover-ups',
  ];

  final Set<String> _selectedStyles = {};
  String? _profileImagePath;

  Map<String, dynamic> _buildDraft() {
    return {
      'role': 'client',
      'displayName': _displayName.text.trim(),
      'city': _city.text.trim(),
      'state': _state.text.trim(),
      'bio': _bio.text.trim(),
      'styles': _selectedStyles.toList(),
      'step': _step,
      'profileImagePath': _profileImagePath,
    };
  }

  void _applyDraft(Map<String, dynamic> draft) {
    _displayName.text = (draft['displayName'] ?? '').toString();
    _city.text = (draft['city'] ?? '').toString();
    _state.text = (draft['state'] ?? '').toString();
    _bio.text = (draft['bio'] ?? '').toString();

    final stylesRaw = draft['styles'];
    final styles = (stylesRaw is List) ? stylesRaw : <dynamic>[];
    _selectedStyles
      ..clear()
      ..addAll(styles.map((e) => e.toString()));

    final stepVal = draft['step'];
    final int stepInt =
        (stepVal is int) ? stepVal : int.tryParse('$stepVal') ?? 0;
    _step = stepInt.clamp(0, 3);

    final path = (draft['profileImagePath'] ?? '').toString().trim();
    _profileImagePath = path.isEmpty ? null : path;
  }

  Future<void> _loadDraftFromDisk() async {
    final draft = await DraftStore.load(role: 'client');
    if (!mounted || draft == null) return;
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

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;

    // Force role so drafts don’t get mislabeled
    final fixedArgs = Map<String, dynamic>.from(args);
    fixedArgs['role'] = 'client';

    setState(() => _applyDraft(fixedArgs));
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
        return 'Location';
      case 2:
        return 'Styles';
      case 3:
        return 'Bio';
      default:
        return 'Client Setup';
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
      '/clientHub',
      arguments: {
        ..._buildDraft(),
        'role': 'client',
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
                        ? const Icon(Icons.person,
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
        return _card(Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _allStyles.map((style) {
            final selected = _selectedStyles.contains(style);
            return FilterChip(
              label: Text(style),
              selected: selected,
              onSelected: (v) async {
                setState(() {
                  v ? _selectedStyles.add(style) : _selectedStyles.remove(style);
                });
                await _saveDraft();
              },
            );
          }).toList(),
        ));

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
  Widget build(BuildContext pathCtx) {
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
