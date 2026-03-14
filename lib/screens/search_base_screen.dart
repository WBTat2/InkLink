import 'package:flutter/material.dart';

import '../models/ink_profile.dart';
import '../models/ink_role.dart';
import '../repositories/profile_repository.dart';

class SearchBaseScreen extends StatefulWidget {
  final InkRole viewerRole;
  const SearchBaseScreen({super.key, required this.viewerRole});

  @override
  State<SearchBaseScreen> createState() => _SearchBaseScreenState();
}

class _SearchBaseScreenState extends State<SearchBaseScreen> {
  final _repo = ProfileRepository();

  final _queryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  InkRole? _roleFilter;
  final Set<String> _styleFilters = {};

  late List<InkProfile> _results;

  InkRole get viewerRole => widget.viewerRole;

  static const List<String> _allStyles = [
    'Black & Grey',
    'Traditional',
    'Neo-Traditional',
    'Realism',
    'Fine Line',
    'Illustrative',
    'Lettering',
    'Japanese',
    'Color',
    'Micro Tattoos',
    'Cover-ups',
  ];

  @override
  void initState() {
    super.initState();
    _results = _repo.search(viewerRole: viewerRole);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _runSearch() {
    setState(() {
      _results = _repo.search(
        viewerRole: viewerRole,
        query: _queryCtrl.text,
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        role: _roleFilter,
        styles: _styleFilters,
      );
    });
  }

  void _clear() {
    setState(() {
      _queryCtrl.clear();
      _cityCtrl.clear();
      _roleFilter = null;
      _styleFilters.clear();
      _results = _repo.search(viewerRole: viewerRole);
    });
  }

  String _title() {
    switch (viewerRole) {
      case InkRole.client:
        return 'Find Artists / Studios';
      case InkRole.owner:
        return 'Search (Owner)';
      case InkRole.artist:
        return 'Search (Artist)';
      default:
        return 'Search';
    }
  }

  List<DropdownMenuItem<InkRole?>> _roleItems() {
    final allowed = _repo.allowedRolesForViewer(viewerRole).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return [
      const DropdownMenuItem<InkRole?>(
        value: null,
        child: Text('All allowed'),
      ),
      ...allowed.map(
        (r) => DropdownMenuItem<InkRole?>(
          value: r,
          child: Text(r.name),
        ),
      ),
    ];
  }

  Widget _filtersCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Scope locked: ${viewerRole.name}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _queryCtrl,
            decoration: const InputDecoration(
              labelText: 'Search',
              hintText: 'name, shop, bio, style…',
            ),
            onChanged: (_) => _runSearch(),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _cityCtrl,
            decoration: const InputDecoration(
              labelText: 'City',
              hintText: 'e.g. Dallas',
            ),
            onChanged: (_) => _runSearch(),
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<InkRole?>(
            value: _roleFilter,
            items: _roleItems(),
            decoration: const InputDecoration(labelText: 'Role filter'),
            onChanged: (v) {
              setState(() => _roleFilter = v);
              _runSearch();
            },
          ),
          const SizedBox(height: 12),

          const Text('Styles', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _allStyles.map((style) {
              final selected = _styleFilters.contains(style);
              return FilterChip(
                label: Text(style),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    v ? _styleFilters.add(style) : _styleFilters.remove(style);
                  });
                  _runSearch();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clear,
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _runSearch,
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProfile(InkProfile p) {
    Navigator.pushNamed(
      context,
      '/profileView',
      arguments: {
        'id': p.id,
        'viewerRole': viewerRole.name, // optional, safe
      },
    );
  }

  Widget _resultTile(InkProfile p) {
    final subtitleBits = <String>[];
    if ((p.shopName ?? '').trim().isNotEmpty) subtitleBits.add(p.shopName!.trim());
    if (p.city.trim().isNotEmpty) subtitleBits.add(p.city.trim());
    final subtitle = subtitleBits.join(' • ');

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          p.displayName.isNotEmpty ? p.displayName[0].toUpperCase() : '?',
        ),
      ),
      title: Text(p.displayName),
      subtitle: Text(
        '${p.role.name}${subtitle.isEmpty ? '' : ' • $subtitle'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openProfile(p),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title())),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _filtersCard(),
              const SizedBox(height: 14),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Results: ${_results.length}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: _results.isEmpty
                    ? const Center(child: Text('No matches.'))
                    : ListView.separated(
                        itemCount: _results.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Colors.white12),
                        itemBuilder: (_, i) => _resultTile(_results[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
