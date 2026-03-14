import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({super.key});

  static const String argRequestId = 'requestId';

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  bool _working = false;

  Future<void> _setStatus(String requestId, String status) async {
    if (_working) return;
    setState(() => _working = true);

    try {
      await FirebaseFirestore.instance
          .collection('tattoo_requests')
          .doc(requestId)
          .update({'status': status});

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
      setState(() => _working = false);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'declined':
        return Colors.redAccent;
      default:
        return Colors.white54;
    }
  }

  String _formatCreatedAt(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final requestId = (args?[RequestDetailScreen.argRequestId] ?? '').toString();

    if (requestId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Missing requestId')),
      );
    }

    final docRef =
        FirebaseFirestore.instance.collection('tattoo_requests').doc(requestId);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Detail')),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: docRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() ?? {};

            final clientName = (data['clientName'] ?? 'Client').toString();
            final status = (data['status'] ?? 'new').toString();

            final idea = (data['description'] ?? data['idea'] ?? '').toString();
            final placement = (data['placement'] ?? '').toString();
            final size = (data['size'] ?? '').toString();
            final style = (data['style'] ?? '').toString();
            final category = (data['category'] ?? '').toString();
            final cleanSlate = data['cleanSlate'];
            final budget = data['budget'];
            final availability = (data['availability'] ?? '').toString();
            final extraNotes = (data['extraNotes'] ?? '').toString();
            final refs = List<String>.from(data['referenceImageUrls'] ?? []);
            final created = data['createdAt'] as Timestamp?;

            final createdText = _formatCreatedAt(created);
            final statusColor = _statusColor(status);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clientName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: statusColor.withOpacity(0.15),
                      border: Border.all(color: statusColor.withOpacity(0.45)),
                    ),
                    child: Text(
                      'Status: ${status.toUpperCase()}',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (createdText.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Submitted $createdText',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],

                  const SizedBox(height: 20),

                  _sectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _line('Description', idea),
                        _line('Placement', placement),
                        _line('Size', size),
                        _line('Style', style),
                        _line('Category', category),
                        _line(
                          'Clean Slate',
                          cleanSlate == null
                              ? ''
                              : (cleanSlate == true ? 'Yes' : 'No'),
                        ),
                        _line('Budget', budget == null ? '' : '\$$budget'),
                        _line('Availability', availability),
                        _line('Extra Notes', extraNotes),
                      ],
                    ),
                  ),

                  if (refs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _sectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reference Images',
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: refs.map((url) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url,
                                  width: 110,
                                  height: 110,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      width: 110,
                                      height: 110,
                                      color: Colors.white10,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.broken_image_outlined,
                                        color: Colors.white54,
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  if (status == 'new')
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _working
                                ? null
                                : () => _setStatus(requestId, 'declined'),
                            child: Text(_working ? 'Working…' : 'Decline'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _working
                                ? null
                                : () => _setStatus(requestId, 'accepted'),
                            child: Text(_working ? 'Working…' : 'Accept'),
                          ),
                        ),
                      ],
                    ),

                  if (status == 'accepted')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _working
                            ? null
                            : () => _setStatus(requestId, 'completed'),
                        child: Text(_working ? 'Working…' : 'Mark Completed'),
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

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  Widget _line(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}