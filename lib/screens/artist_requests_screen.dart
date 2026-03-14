import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/artist_profile_service.dart';
import '../app_routes.dart';
import 'request_detail_screen.dart';

class ArtistRequestsScreen extends StatefulWidget {
  const ArtistRequestsScreen({super.key});

  @override
  State<ArtistRequestsScreen> createState() => _ArtistRequestsScreenState();
}

class _ArtistRequestsScreenState extends State<ArtistRequestsScreen> {
  String _status = 'new';

  Future<void> _createTestRequest() async {
    final db = FirebaseFirestore.instance;
    final artistId = ArtistProfileService.demoUid;

    await db.collection('tattoo_requests').add({
      'artistId': artistId,
      'status': 'new',
      'createdAt': FieldValue.serverTimestamp(),
      'clientName': 'Test Client',
      'idea': 'Black & grey rose on forearm',
      'placement': 'Forearm',
      'size': '4 inches',
      'budget': 250,
      'availability': 'Weekends',
    });
  }

  @override
  Widget build(BuildContext context) {
    final artistId = ArtistProfileService.demoUid;

    // Avoid composite index by NOT ordering for now.
    final query = FirebaseFirestore.instance
        .collection('tattoo_requests')
        .where('artistId', isEqualTo: artistId)
        .where('status', isEqualTo: _status);

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'new', label: Text('New')),
                ButtonSegment(value: 'accepted', label: Text('Accepted')),
                ButtonSegment(value: 'completed', label: Text('Completed')),
                ButtonSegment(value: 'declined', label: Text('Declined')),
              ],
                selected: {_status},
                onSelectionChanged: (s) => setState(() => _status = s.first),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('No ${_status == 'new' ? 'new' : _status} requests.'),
                            const SizedBox(height: 12),
                            if (_status == 'new')
                              ElevatedButton(
                                onPressed: _createTestRequest,
                                child: const Text('Create Test Request'),
                              ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final d = docs[i].data();
                      final clientName = (d['clientName'] ?? 'Client').toString();
                      final idea = (d['description'] ?? d['idea'] ?? '').toString();

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: ListTile(
                          title: Text(clientName),
                          subtitle: Text(idea.isEmpty ? 'No details' : idea),
                          trailing: Text(
                            _status.toUpperCase(),
                            style: const TextStyle(color: Colors.white54),
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.requestDetail,
                              arguments: {
                                RequestDetailScreen.argRequestId: docs[i].id
                              },
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _status == 'new'
          ? FloatingActionButton(
              onPressed: _createTestRequest,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}