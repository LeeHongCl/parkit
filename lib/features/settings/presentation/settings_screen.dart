import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../recommendation/domain/recommendation_type.dart';
import 'providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultType = ref.watch(defaultRecommendationTypeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('기본 추천 유형', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          RadioGroup<RecommendationType>(
            groupValue: defaultType,
            onChanged: (value) {
              if (value != null) {
                ref.read(defaultRecommendationTypeProvider.notifier).update(value);
              }
            },
            child: Column(
              children: RecommendationType.values
                  .map(
                    (type) => RadioListTile<RecommendationType>(
                      title: Text(type.label),
                      subtitle: Text(type.description),
                      value: type,
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.location_on_outlined),
            title: Text('위치 권한 안내'),
            subtitle: Text('주변 주차장 검색을 위해 위치 권한이 필요합니다.'),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('앱 정보'),
            subtitle: Text('PARKIT v0.1.0 (MVP 목업)'),
          ),
        ],
      ),
    );
  }
}
