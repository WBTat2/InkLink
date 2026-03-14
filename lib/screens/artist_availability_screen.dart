import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/artist_profile_service.dart';

class ArtistAvailabilityScreen extends StatefulWidget {
  const ArtistAvailabilityScreen({super.key});

  @override
  State<ArtistAvailabilityScreen> createState() => _ArtistAvailabilityScreenState();
}

class _ArtistAvailabilityScreenState extends State<ArtistAvailabilityScreen> {
  bool _openForBooking = false;
  final _homeCity = TextEditingController();
  final _travelCity = TextEditingController();
  DateTime? _travelStart;
  DateTime? _travelEnd;

  bool _saving = false;

  @override
  void dispose() {
    _homeCity.dispose();
    _travelCity.dispose();
    super.dispose();
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Select';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelStart ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() => _travelStart = picked);
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final initial = _travelEnd ?? _travelStart ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    setState(() => _travelEnd = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final draft = <String, dynamic>{
      'openForBooking': _openForBooking,
      'homeCity': _homeCity.text.trim(),
      'travelCity': _travelCity.text.trim(),
      'travelStart': _travelStart == null ? null : Timestamp.fromDate(_travelStart!),
      'travelEnd': _travelEnd == null ? null : Timestamp.fromDate(_travelEnd!),
    };

    // Demo mode: updates demo artist doc
    await ArtistProfileService().upsertArtistProfile(draft);

    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Availability / Travel')),
      body: SafeArea(
        child: StreamBuilder(
          stream: ArtistProfileService().watchMyArtistProfile(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data();

            // Load initial values once when data arrives
            if (data != null && _homeCity.text.isEmpty && _travelCity.text.isEmpty) {
              _openForBooking = (data['openForBooking'] ?? false) == true;
              _homeCity.text = (data['homeCity'] ?? '').toString();
              _travelCity.text = (data['travelCity'] ?? '').toString();

              final tsStart = data['travelStart'];
              final tsEnd = data['travelEnd'];
              _travelStart = tsStart is Timestamp ? tsStart.toDate() : null;
              _travelEnd = tsEnd is Timestamp ? tsEnd.toDate() : null;
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _openForBooking,
                    onChanged: (v) => setState(() => _openForBooking = v),
                    title: const Text('Open for Booking'),
                    subtitle: const Text('Show you are accepting new work'),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _homeCity,
                    decoration: const InputDecoration(
                      labelText: 'Home City',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _travelCity,
                    decoration: const InputDecoration(
                      labelText: 'Travel City (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickStart,
                          child: Text('Start: ${_fmt(_travelStart)}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _pickEnd,
                          child: Text('End: ${_fmt(_travelEnd)}'),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Saving...' : 'Save'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}