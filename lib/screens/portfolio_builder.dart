import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/portfolio_service.dart';
import '../models/portfolio_item.dart';
import '../services/artist_profile_service.dart';

class PortfolioBuilderScreen extends StatefulWidget {
  const PortfolioBuilderScreen({super.key});

  @override
  State<PortfolioBuilderScreen> createState() => _PortfolioBuilderScreenState();
}

class _PortfolioBuilderScreenState extends State<PortfolioBuilderScreen> {
  final List<_PortfolioDraftItem> _items = [];
  final service = PortfolioService();

  @override
  void initState() {
    super.initState();
    _loadPortfolio();
  }

  Future<void> _loadPortfolio() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('portfolio')
        .where('artistId', isEqualTo: ArtistProfileService.demoUid)
        .get();

    final items = snapshot.docs.map((doc) {
      final d = doc.data();

      return _PortfolioDraftItem(
        id: doc.id,
        imageUrl: d['imageUrl'] ?? '',
      )
        ..title = d['title'] ?? ''
        ..caption = d['caption'] ?? ''
        ..style = d['style']
        ..placement = d['placement']
        ..healed = d['healed'] ?? false
        ..coverUp = d['coverUp'] ?? false;
    }).toList();

    setState(() {
      _items.clear();
      _items.addAll(items);
    });
  }

  final List<String> _styles = const [
    'Black & Grey',
    'Color',
    'Fine Line',
    'Traditional',
    'Neo-Traditional',
    'Realism',
    'Illustrative',
    'Lettering',
    'Japanese',
  ];

  final List<String> _placements = const [
    'Forearm',
    'Upper Arm',
    'Hand',
    'Chest',
    'Back',
    'Ribs',
    'Leg',
    'Thigh',
    'Calf',
    'Neck',
  ];

  void _addItem() {
    setState(() {
      _items.insert(
        0,
        _PortfolioDraftItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl:
              'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/600/600',
        ),
      );
    });
  }

  void _removeItem(String id) {
    setState(() => _items.removeWhere((x) => x.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio Builder'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Proof, not clout.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Portfolio items are local drafts for now.',
          ),
          const SizedBox(height: 16),

          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.photo_library_outlined, size: 42),
                  const SizedBox(height: 10),
                  const Text('No portfolio items yet'),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _addItem,
                    child: const Text('Add first item'),
                  ),
                ],
              ),
            )
          else
            ..._items.map((item) => _PortfolioCard(
                  item: item,
                  styles: _styles,
                  placements: _placements,
                  onDelete: () => _removeItem(item.id),
                )),

          const SizedBox(height: 20),


          FilledButton.icon(
            onPressed: _items.isEmpty
                ? null
                : () async {
                    final items = _items.map((i) {
                      return PortfolioItem(
                        id: i.id,
                        artistId: ArtistProfileService.demoUid,
                        imageUrl: i.imageUrl,
                        title: i.title,
                        caption: i.caption,
                        style: i.style,
                        placement: i.placement,
                        healed: i.healed,
                        coverUp: i.coverUp,
                      );
                    }).toList();

                    await service.savePortfolioItems(
                      ArtistProfileService.demoUid,
                      items,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Portfolio saved.')),
                    );
                  },
            icon: const Icon(Icons.save),
            label: const Text('Save Portfolio'),
          )
        ],
      ),
    );
  }
}

class _PortfolioCard extends StatefulWidget {
  final _PortfolioDraftItem item;
  final List<String> styles;
  final List<String> placements;
  final VoidCallback onDelete;

  const _PortfolioCard({
    required this.item,
    required this.styles,
    required this.placements,
    required this.onDelete,
  });

  @override
  State<_PortfolioCard> createState() => _PortfolioCardState();
}

class _PortfolioCardState extends State<_PortfolioCard> {
  late TextEditingController _titleCtrl;
  late TextEditingController _captionCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _captionCtrl = TextEditingController(text: widget.item.caption);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.white10,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => item.title = v,
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _captionCtrl,
              decoration: const InputDecoration(
                labelText: 'Caption / Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (v) => item.caption = v,
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: item.style,
              decoration: const InputDecoration(
                labelText: 'Style',
                border: OutlineInputBorder(),
              ),
              items: widget.styles
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) {
                setState(() => item.style = v);
              },
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: item.placement,
              decoration: const InputDecoration(
                labelText: 'Placement',
                border: OutlineInputBorder(),
              ),
              items: widget.placements
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) {
                setState(() => item.placement = v);
              },
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    value: item.healed,
                    title: const Text('Healed'),
                    onChanged: (v) {
                      setState(() => item.healed = v);
                    },
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    value: item.coverUp,
                    title: const Text('Cover-up'),
                    onChanged: (v) {
                      setState(() => item.coverUp = v);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Text(
                  'ID: ${item.id}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _PortfolioDraftItem {
  final String id;
  final String imageUrl;

  String title = '';
  String caption = '';
  String? style;
  String? placement;
  bool healed = false;
  bool coverUp = false;

  _PortfolioDraftItem({
    required this.id,
    required this.imageUrl,
  });
}