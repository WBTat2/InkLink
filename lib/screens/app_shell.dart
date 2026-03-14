import 'package:flutter/material.dart';
import 'package:inklink/screens/profile_hub_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  Map<String, dynamic> _args(BuildContext context) {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final data = _args(context);
    final role = (data['role'] ?? 'client').toString();

    final pages = <Widget>[
      // Hub needs role context
      ProfileHubScreen(key: ValueKey('hub_$role')),
      const SearchScreen(),
      const _MessagesStubScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages.map((w) {
          // Only hub needs args—pass via Navigator to keep it simple:
          if (w is ProfileHubScreen) {
            return Navigator(
              onGenerateRoute: (_) => MaterialPageRoute(
                builder: (_) => role: (),
                settings: RouteSettings(arguments: {'role': role}),
              ),
            );
          }
          return w;
        }).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Hub'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Messages'),
        ],
      ),
    );
  }
}

class _MessagesStubScreen extends StatelessWidget {
  const _MessagesStubScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: const Center(
        child: Text('Messaging coming next.'),
      ),
    );
  }
}
