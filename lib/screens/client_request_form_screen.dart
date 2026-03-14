import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../services/artist_profile_service.dart';
import '../theme/app_theme.dart';

class ClientRequestFormScreen extends StatefulWidget {
  const ClientRequestFormScreen({super.key});

  @override
  State<ClientRequestFormScreen> createState() => _ClientRequestFormScreenState();
}

class _ClientRequestFormScreenState extends State<ClientRequestFormScreen> {
  int _step = 0;
  bool _submitting = false;
  bool _uploadingImage = false;

  // Step 1
  final _clientNameCtrl = TextEditingController();

  // Step 2
  String? _selectedSide;
  String? _selectedBodyPart;
  String? _selectedSize;
  String? _selectedStyle;
  String? _selectedCategory;
  bool? _cleanSlate;

  // Step 3
  final _descriptionCtrl = TextEditingController();
  final _extraNotesCtrl = TextEditingController();
  String? _selectedAvailability;
  final _budgetCtrl = TextEditingController();

  // Step 4
  final ImagePicker _picker = ImagePicker();
  final List<String> _referenceImageUrls = [];

  final List<String> _sides = const [
    'Left',
    'Right',
    'Center',
    'Front',
    'Back',
    'Full',
  ];

  final List<String> _bodyParts = const [
    'Forearm',
    'Upper Arm',
    'Shoulder',
    'Hand',
    'Fingers',
    'Chest',
    'Ribs',
    'Stomach',
    'Back',
    'Neck',
    'Thigh',
    'Calf',
    'Shin',
    'Foot',
    'Head',
  ];

  final List<String> _sizes = const [
    'Palm size',
    'Hand size',
    'Half sleeve',
    'Full sleeve',
    'Small',
    'Medium',
    'Large',
    'Custom / Unsure',
  ];

  final List<String> _styles = const [
    'Black & Grey',
    'Color',
    'Fine Line',
    'Traditional',
    'Neo-Traditional',
    'Realism',
    'Illustrative',
    'Lettering',
    'Japanese',
    'Cover-up',
    'Unsure',
  ];

  final List<String> _categories = const [
    'Custom piece',
    'Flash',
    'Cover-up',
    'Rework',
    'Matching tattoo',
    'Sleeve project',
    'Memorial',
    'Unsure',
  ];

  final List<String> _availabilityOptions = const [
    'ASAP',
    'Within 1 month',
    'Within 2 months',
    'No rush',
  ];

  @override
  void dispose() {
    _clientNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _extraNotesCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  bool _canGoNext() {
    switch (_step) {
      case 0:
        return _clientNameCtrl.text.trim().isNotEmpty;
      case 1:
        return _selectedSide != null &&
            _selectedBodyPart != null &&
            _selectedSize != null &&
            _selectedStyle != null &&
            _selectedCategory != null &&
            _cleanSlate != null;
      case 2:
        return _descriptionCtrl.text.trim().isNotEmpty &&
            _selectedAvailability != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  String _stepTitle() {
    switch (_step) {
      case 0:
        return 'Client';
      case 1:
        return 'Tattoo Details';
      case 2:
        return 'Description';
      case 3:
        return 'References';
      default:
        return 'Request Form';
    }
  }

  String _buildPlacement() {
    final side = _selectedSide ?? '';
    final bodyPart = _selectedBodyPart ?? '';
    if (side.isEmpty && bodyPart.isEmpty) return '';
    if (side.isEmpty) return bodyPart;
    if (bodyPart.isEmpty) return side;
    return '$side $bodyPart';
  }

  int? _parseBudget() {
    final raw = _budgetCtrl.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  Future<void> _pickAndUploadImage() async {
    if (_uploadingImage) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _uploadingImage = true);

    try {
      final file = File(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = FirebaseStorage.instance
          .ref()
          .child('tattoo_requests')
          .child(fileName);

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      if (!mounted) return;
      setState(() {
        _referenceImageUrls.add(file.path);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _uploadingImage = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final clientName = _clientNameCtrl.text.trim();
    final placement = _buildPlacement();
    final size = _selectedSize ?? '';
    final style = _selectedStyle ?? '';
    final category = _selectedCategory ?? '';
    final description = _descriptionCtrl.text.trim();
    final extraNotes = _extraNotesCtrl.text.trim();
    final availability = _selectedAvailability ?? '';
    final budget = _parseBudget();

    if (clientName.isEmpty ||
        placement.isEmpty ||
        size.isEmpty ||
        style.isEmpty ||
        category.isEmpty ||
        description.isEmpty ||
        availability.isEmpty ||
        _cleanSlate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill out the required fields first.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await FirebaseFirestore.instance.collection('tattoo_requests').add({
        'artistId': ArtistProfileService.demoUid,
        'clientId': 'demo_client',
        'clientName': clientName,
        'status': 'new',
        'createdAt': FieldValue.serverTimestamp(),
        'placement': placement,
        'size': size,
        'style': style,
        'category': category,
        'cleanSlate': _cleanSlate,
        'description': description,
        'extraNotes': extraNotes,
        'budget': budget,
        'availability': availability,
        'referenceImageUrls': _referenceImageUrls,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted.')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submit failed: $e')),
      );
      setState(() => _submitting = false);
    }
  }

  void _next() {
    if (!_canGoNext()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish this step first.')),
      );
      return;
    }

    if (_step < 3) {
      setState(() => _step++);
      return;
    }

    _submit();
  }

  void _back() {
    if (_step == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _step--);
  }

  void _removeReferenceUrl(int index) {
    setState(() => _referenceImageUrls.removeAt(index));
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tattoo Request',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Step $currentStep of $totalSteps • ${_stepTitle()}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.inkRed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: AppTheme.card,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _stepClient() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who is this request for?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Keeping this light for now since the full profile will hold the rest.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _clientNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Client Name',
              hintText: 'Enter name',
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _stepTattooDetails() {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dropdownField(
                  label: 'Side',
                  value: _selectedSide,
                  items: _sides,
                  onChanged: (v) => setState(() => _selectedSide = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdownField(
                  label: 'Body Part',
                  value: _selectedBodyPart,
                  items: _bodyParts,
                  onChanged: (v) => setState(() => _selectedBodyPart = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _dropdownField(
                  label: 'Size',
                  value: _selectedSize,
                  items: _sizes,
                  onChanged: (v) => setState(() => _selectedSize = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdownField(
                  label: 'Style',
                  value: _selectedStyle,
                  items: _styles,
                  onChanged: (v) => setState(() => _selectedStyle = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _dropdownField(
            label: 'Category',
            value: _selectedCategory,
            items: _categories,
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Clean slate?',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('Yes')),
                  selected: _cleanSlate == true,
                  onSelected: (_) => setState(() => _cleanSlate = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('No')),
                  selected: _cleanSlate == false,
                  onSelected: (_) => setState(() => _cleanSlate = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_selectedSide != null || _selectedBodyPart != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Placement: ${_buildPlacement()}',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepDescription() {
    return _card(
      child: Column(
        children: [
          TextField(
            controller: _descriptionCtrl,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Tattoo Description',
              hintText: 'Describe the tattoo idea clearly',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _extraNotesCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Extra Notes / Special Requests',
              hintText: 'Matching tattoo, cover-up notes, specifics, etc.',
            ),
          ),
          const SizedBox(height: 16),
          _dropdownField(
            label: 'When are you looking to be tattooed?',
            value: _selectedAvailability,
            items: _availabilityOptions,
            onChanged: (v) => setState(() => _selectedAvailability = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _budgetCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Budget (optional)',
              hintText: 'Example: 300',
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepReferences() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reference Images',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload references for the tattoo idea.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _uploadingImage ? null : _pickAndUploadImage,
            icon: const Icon(Icons.photo),
            label: Text(_uploadingImage
                ? 'Uploading...'
                : 'Upload Reference Image'),
          ),

          const SizedBox(height: 16),

          if (_referenceImageUrls.isEmpty)
            const Text(
              'No reference images uploaded yet.',
              style: TextStyle(color: Colors.white54),
            ),

          if (_referenceImageUrls.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(_referenceImageUrls.length, (index) {
                final url = _referenceImageUrls[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(url),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeReferenceUrl(index),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black,
                          child: Icon(Icons.close, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),

          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),

          Text(
            'Review',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          _reviewLine('Client', _clientNameCtrl.text.trim()),
          _reviewLine('Placement', _buildPlacement()),
          _reviewLine('Size', _selectedSize ?? ''),
          _reviewLine('Style', _selectedStyle ?? ''),
          _reviewLine('Category', _selectedCategory ?? ''),
          _reviewLine(
            'Clean Slate',
            _cleanSlate == null ? '' : (_cleanSlate! ? 'Yes' : 'No'),
          ),
          _reviewLine('Availability', _selectedAvailability ?? ''),
          _reviewLine(
            'Budget',
            _parseBudget() == null ? '' : '\$${_parseBudget()}',
          ),
          _reviewLine('Description', _descriptionCtrl.text.trim()),
          _reviewLine('Extra Notes', _extraNotesCtrl.text.trim()),
          _reviewLine('References', _referenceImageUrls.length.toString()),
        ],
      ),
    );
  }

  Widget _reviewLine(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _stepClient();
      case 1:
        return _stepTattooDetails();
      case 2:
        return _stepDescription();
      case 3:
        return _stepReferences();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canGoNext = !_submitting && !_uploadingImage && _canGoNext();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Request'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (_submitting || _uploadingImage) ? null : _back,
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
                child: SingleChildScrollView(
                  child: _stepBody(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: (_submitting || _uploadingImage) ? null : _back,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: canGoNext ? _next : null,
                        child: Text(
                          _submitting
                              ? 'Submitting...'
                              : (_step == 3 ? 'Submit Request' : 'Next'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}