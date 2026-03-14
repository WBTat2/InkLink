import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/session_controller.dart';
import 'client_flow.dart';
import 'owner_flow.dart';
import 'artist_flow.dart';

class HubDecider extends StatelessWidget {
  const HubDecider({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();

    if (session.isClient) return const ClientFlowScreen();
    if (session.isOwner) return const OwnerFlowScreen();
    return const ArtistFlowScreen();
  }
}
