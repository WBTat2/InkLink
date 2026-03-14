import 'package:flutter/material.dart';
import '../models/ink_role.dart';
import 'search_base_screen.dart';

class SearchOwnerScreen extends StatelessWidget {
  const SearchOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SearchBaseScreen(viewerRole: InkRole.owner);
  }
}
