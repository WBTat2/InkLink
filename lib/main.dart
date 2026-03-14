// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app_routes.dart';
import 'theme/app_theme.dart';

import 'screens/role_select_screen.dart';
import 'screens/artist_flow.dart';
import 'screens/profile_hub_screen.dart';
import 'screens/artist_public_profile_screen.dart';
import 'screens/portfolio_builder.dart';
import 'screens/artist_availability_screen.dart';
import 'screens/artist_requests_screen.dart';
import 'screens/request_detail_screen.dart';
import 'screens/client_request_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const InkLinkApp());
}

class InkLinkApp extends StatelessWidget {
  const InkLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: AppRoutes.roleSelect,
      routes: {
        AppRoutes.roleSelect: (_) => const RoleSelectScreen(),
        AppRoutes.artistFlow: (_) => const ArtistFlowScreen(),
        AppRoutes.profileHub: (_) => const ProfileHubScreen(),
        AppRoutes.artistPublicProfile: (_) => const ArtistPublicProfileScreen(),
        AppRoutes.portfolio: (_) => const PortfolioBuilderScreen(),
        AppRoutes.availability: (_) => const ArtistAvailabilityScreen(),
        AppRoutes.requests: (_) => const ArtistRequestsScreen(),
        AppRoutes.requestDetail: (_) => const RequestDetailScreen(),
        AppRoutes.clientRequestForm: (_) => const ClientRequestFormScreen(),
      },
    );
  }
}