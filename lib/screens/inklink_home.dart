import 'package:flutter/material.dart';
import '../data/artist_repo.dart';
import '../data/artist_draft.dart';

class InkLinkHome extends StatefulWidget {
  const InkLinkHome({super.key});

  @override
  State<InkLinkHome> createState() => _InkLinkHomeState();
}

class _InkLinkHomeState extends State<InkLinkHome> {
  Future<void> _openArtistSetup() async {
    // send current draft (if any) into Artist Setup
    final current = ArtistRepo.loadDraft().toMap();

    final result = await Navigator.pushNamed(
      context,
      '/artistFlow',
      arguments: current,
    );

    // If ArtistFlow returns a draft map, store it
    if (result is Map<String, dynamic>) {
      final draft = ArtistDraft.fromMap(result);
      ArtistRepo.saveDraft(draft);
      setState(() {});
    }
  }

  void _discard() {
    ArtistRepo.clearDraft();
    setState(() {});
  }

  @override
  Widget build(BuildContext pathCtx) {
    final hasDraft = ArtistRepo.hasDraft();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                AppBrand.appName,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                hasDraft
                    ? 'Draft in progress'
                    : 'Build your artist profile and portfolio.',
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _openArtistSetup,
                child: Text(hasDraft ? 'Continue Artist Setup' : 'Start Artist Setup'),
              ),

              if (hasDraft) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _discard,
                  child: const Text('Discard Draft'),
                ),
              ],

              const Spacer(),
              const Center(child: Text('Mode B · UI-only')),
            ],
          ),
        ),
      ),
    );
  }
}
