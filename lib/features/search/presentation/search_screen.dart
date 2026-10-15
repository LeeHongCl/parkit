import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_destinations.dart';
import '../domain/destination.dart';
import 'providers/search_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<Destination> _results = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _results = [];
      } else {
        _results = mockSearchableDestinations
            .where((d) => d.name.contains(query) || d.address.contains(query))
            .toList();
      }
    });
  }

  void _selectDestination(Destination destination) {
    ref.read(selectedDestinationProvider.notifier).select(destination);
    ref.read(recentSearchesProvider.notifier).add(destination);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchesProvider);
    final showRecent = _controller.text.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '목적지를 검색하세요',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
        ),
      ),
      body: showRecent
          ? _RecentSearchesView(
              recentSearches: recentSearches,
              onSelect: _selectDestination,
              onClear: () => ref.read(recentSearchesProvider.notifier).clear(),
            )
          : _SearchResultsView(results: _results, onSelect: _selectDestination),
    );
  }
}

class _RecentSearchesView extends StatelessWidget {
  final List<Destination> recentSearches;
  final ValueChanged<Destination> onSelect;
  final VoidCallback onClear;

  const _RecentSearchesView({
    required this.recentSearches,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (recentSearches.isEmpty) {
      return const Center(child: Text('최근 검색한 목적지가 없습니다.'));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 검색', style: Theme.of(context).textTheme.titleSmall),
              TextButton(onPressed: onClear, child: const Text('전체 삭제')),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final destination = recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(destination.name),
                subtitle: Text(destination.address),
                onTap: () => onSelect(destination),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  final List<Destination> results;
  final ValueChanged<Destination> onSelect;

  const _SearchResultsView({required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final destination = results[index];
        return ListTile(
          leading: const Icon(Icons.place_outlined),
          title: Text(destination.name),
          subtitle: Text(destination.address),
          onTap: () => onSelect(destination),
        );
      },
    );
  }
}
