import 'package:flutter/material.dart';
import '../services/artist_profile_service.dart';
import '../app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/tattoo_machine_progress.dart';
import '../theme/app_theme.dart';

class ProfileHubScreen extends StatelessWidget {
  const ProfileHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Artist Home'),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: ArtistProfileService().watchMyArtistProfile(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data();
            final name = data?['displayName'] ?? 'Artist';

            int score = 0;

              if ((data?['displayName'] ?? '').toString().isNotEmpty) score++;
              if ((data?['bio'] ?? '').toString().isNotEmpty) score++;
              if ((data?['styles'] ?? []).isNotEmpty) score++;
              if ((data?['profileImagePath'] ?? '').toString().isNotEmpty) score++;

              final percent = (score / 4 * 100).toInt();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundColor: AppTheme.inkRed,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              name,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TattooMachineProgress(
                          progress: score / 4,
                          height: 60,
                        ),

                        const SizedBox(height: 6),

                        Text(
                          '$percent% Profile Complete',
                          style: TextStyle(color: AppTheme.inkRed.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),

                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('tattoo_requests')
                        .where('artistId', isEqualTo: ArtistProfileService.demoUid)
                        .where('status', isEqualTo: 'new')
                        .snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const SizedBox.shrink();
                      final count = snap.data!.docs.length;
                      if (count == 0) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.requests),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Text('🔥 $count new request(s) waiting'),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.artistFlow),
                    child: const Text('Edit Profile'),
                  ),

                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.artistPublicProfile),
                    child: const Text('View Public Profile'),
                  ),

                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.portfolio),
                    child: const Text('Portfolio'),
                  ),

                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.availability),
                    child: const Text('Availability / Travel'),
                  ),
                  
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.requests),
                    child: const Text('Requests (Gatekeeper)'),  
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.clientRequestForm),
                    child: const Text('Open Client Request Form'),
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