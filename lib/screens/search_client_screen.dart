import 'package:flutter/material.dart';
import '../models/ink_role.dart';
import 'search_base_screen.dart';

class SearchClientScreen extends StatelessWidget {
  const SearchClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchBaseScreen(viewerRole: InkRole.client);
  }
}
