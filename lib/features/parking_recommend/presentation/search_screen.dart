import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/daegu_landmarks.dart';
import 'providers/parking_recommend_providers.dart';

/// 백엔드 /search API는 앱에서 쓰지 않으므로(명세 2장), 대구 내 지점 이름을
/// 로컬에서 필터링하는 방식으로 목적지를 고른다. 선택하면 검색 중심만 옮기고,
/// 추천 요청은 홈 화면에서 "추천 받기"를 눌러야 실행된다(지도 탭/빠른 이동과 동일).
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<DaeguLandmark> _results = daeguSearchableLandmarks;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    setState(() {
      final trimmed = query.trim();
      _results = trimmed.isEmpty
          ? daeguSearchableLandmarks
          : daeguSearchableLandmarks.where((l) => l.name.contains(trimmed)).toList();
    });
  }

  void _select(DaeguLandmark landmark) {
    ref.read(searchCenterProvider.notifier).set(landmark.point);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '대구 내 목적지를 검색하세요',
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
        ),
      ),
      body: _results.isEmpty
          ? const Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final landmark = _results[index];
                return ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(landmark.name),
                  onTap: () => _select(landmark),
                );
              },
            ),
    );
  }
}
