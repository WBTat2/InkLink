// lib/screens/artist_flow.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../services/artist_profile_service.dart';
import '../widgets/tattoo_machine_progress.dart';

class ArtistFlowScreen extends StatefulWidget {
  const ArtistFlowScreen({super.key});

  @override
  State<ArtistFlowScreen> createState() => _ArtistFlowScreenState();
}

class _ArtistFlowScreenState extends State<ArtistFlowScreen> {
  int _step = 0;
  bool _saving = false;

  // Controllers
  final _displayName = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _bio = TextEditingController();

  final _scrollCtrl = ScrollController();

  // Styles
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

  // Profile image
  String? _profileImagePath;

  // Social links
  final List<String> _platforms = const [
    'Instagram',
    'Facebook',
    'TikTok',
    'Snapchat',
    'X (Twitter)',
    'YouTube',
    'Website',
    'Other',
  ];
  String _selectedPlatform = 'Instagram';
  final _socialController = TextEditingController();
  final List<Map<String, String>> _socialLinks = [];

  @override
  void dispose() {
    _displayName.dispose();
    _city.dispose();
    _state.dispose();
    _bio.dispose();
    _socialController.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  bool _basicsValid() => _displayName.text.trim().isNotEmpty;

  Map<String, dynamic> _buildDraft() {
    return {
      'role': 'artist',
      'displayName': _displayName.text.trim(),
      'city': _city.text.trim(),
      'state': _state.text.trim(),
      'bio': _bio.text.trim(),
      'styles': _selectedStyles.toList(),
      'profileImagePath': _profileImagePath,
      'socialLinks': _socialLinks,
      'step': _step,
    };
  }

  // Demo mode: no disk draft saving yet
  Future<void> _saveDraft() async {
    // no-op for now
  }

  // ---------- UI logic ----------
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
        return 'Artist Setup';
    }
  }

  bool _canGoNext() {
    if (_step == 0) return _basicsValid();
    return true;
  }

  Future<void> _pickProfileImage() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Images',
          extensions: ['png', 'jpg', 'jpeg', 'heic'],
        ),
      ],
    );
    if (file == null) return;

    setState(() => _profileImagePath = file.path);
  }

  String _socialHint() {
    switch (_selectedPlatform) {
      case 'Instagram':
      case 'TikTok':
      case 'Snapchat':
      case 'X (Twitter)':
        return '@username';
      case 'Facebook':
        return 'profile link or username';
      case 'YouTube':
        return 'channel link';
      case 'Website':
        return 'https://your-site.com';
      default:
        return 'Handle or URL';
    }
  }

  TextInputType _socialKeyboard() {
    switch (_selectedPlatform) {
      case 'Website':
      case 'YouTube':
      case 'Facebook':
        return TextInputType.url;
      default:
        return TextInputType.text;
    }
  }

  void _addSocial() {
    final value = _socialController.text.trim();
    if (value.isEmpty) return;

    final exists = _socialLinks.any((m) =>
        m['platform'] == _selectedPlatform && m['value'] == value);
    if (exists) return;

    setState(() {
      _socialLinks.add({'platform': _selectedPlatform, 'value': value});
      _socialController.clear();
    });
  }

  void _removeSocial(int index) {
    setState(() => _socialLinks.removeAt(index));
  }

  void _backPressed() {
    if (_step > 0) {
      setState(() => _step--);
      return;
    }
    Navigator.pop(context);
  }

  Future<void> _next() async {
    await _saveDraft();

    // Step 0 guard: Display Name required
    if (_step == 0 && !_basicsValid()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a display name first.')),
      );
      return;
    }

    // Keep stepping through the wizard
    if (_step < 3) {
      setState(() => _step++);
      return;
    }

    // Step 3 = FINISH -> Save to Firestore (demo)
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final draft = _buildDraft();
      await ArtistProfileService().upsertDemoArtistProfile(draft);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved artist profile (demo).')),
      );

      Navigator.pushNamed(
        context,
        '/profileHub',
        arguments: draft,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- Widgets ----------
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

  Widget _progressHeader() {
    const totalSteps = 4;
    final currentStep = _step + 1;
    final progress = currentStep / totalSteps;

    return _card(
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // BIG MACHINE ON LEFT
          SizedBox(
            width: 200,
            child: TattooMachineProgress(
              progress: progress,
              height: 105,
            ),
          ),

          const SizedBox(width: 12),

          // PROGRESS TEXT ON RIGHT
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Progress: $currentStep / $totalSteps',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialList() {
    if (_socialLinks.isEmpty) {
      return const Text(
        'No social links added yet.',
        style: TextStyle(color: Colors.white54),
      );
    }

    return Column(
      children: List.generate(_socialLinks.length, (i) {
        final item = _socialLinks[i];
        final platform = item['platform'] ?? '';
        final value = item['value'] ?? '';

        return Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$platform: $value',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _removeSocial(i),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _card(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Profile Picture (optional)',
                style: TextStyle(color: Colors.white70),
              ),
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
                      child: Text(
                        _profileImagePath == null
                            ? 'Choose Profile Picture'
                            : 'Change Picture',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _displayName,
                decoration: const InputDecoration(labelText: 'Display Name'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 18),
              const Text(
                'Social Links',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 10),

              // Social row (NO OVERFLOW)
              Row(
                children: [
                  DropdownButton<String>(
                    value: _selectedPlatform,
                    dropdownColor: const Color(0xFF12121A),
                    items: _platforms
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _selectedPlatform = val);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _socialController,
                      keyboardType: _socialKeyboard(),
                      decoration: InputDecoration(hintText: _socialHint()),
                      onSubmitted: (_) => _addSocial(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addSocial,
                    icon: const Icon(Icons.add_circle),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              _socialList(),
            ],
          ),
        );

      case 1:
        return _card(
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _city,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _state,
                  decoration: const InputDecoration(labelText: 'State'),
                ),
              ),
            ],
          ),
        );

      case 2:
        return _card(
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allStyles.map((style) {
              final selected = _selectedStyles.contains(style);
              return FilterChip(
                label: Text(style),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    v ? _selectedStyles.add(style) : _selectedStyles.remove(style);
                  });
                },
              );
            }).toList(),
          ),
        );

      case 3:
        return _card(
          TextFormField(
            controller: _bio,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Bio'),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextEnabled = !_saving && _canGoNext();

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
              _progressHeader(),
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
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: nextEnabled ? _next : null,
                  child: Text(
                    _saving ? 'Saving…' : (_step == 3 ? 'Finish' : 'Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}