import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultWeights = ref.watch(defaultWeightsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('기본 추천 중요도', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '추천 요청을 새로 시작할 때 사용할 기본 중요도입니다. 홈 화면 슬라이더로도 바로 조정할 수 있어요.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('요금 중요도', style: theme.textTheme.labelLarge),
                Slider(
                  value: defaultWeights.fee,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: defaultWeights.fee.toStringAsFixed(1),
                  onChanged: (value) => ref.read(defaultWeightsProvider.notifier).setFee(value),
                ),
                Text('거리 중요도', style: theme.textTheme.labelLarge),
                Slider(
                  value: defaultWeights.distance,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: defaultWeights.distance.toStringAsFixed(1),
                  onChanged: (value) =>
                      ref.read(defaultWeightsProvider.notifier).setDistance(value),
                ),
                Text('전기차 충전 중요도', style: theme.textTheme.labelLarge),
                Slider(
                  value: defaultWeights.ev,
                  min: 0,
                  max: 1,
                  divisions: 10,
                  label: defaultWeights.ev.toStringAsFixed(1),
                  onChanged: (value) => ref.read(defaultWeightsProvider.notifier).setEv(value),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('위치 권한 안내'),
            subtitle: const Text(
              '현재 위치 버튼으로 내 주변 주차장을 바로 찾으려면 위치 권한이 필요합니다. '
              '서비스 지역은 대구(군위군 제외)로 한정됩니다.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: OutlinedButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text('앱 위치 권한 설정 열기'),
            ),
          ),
          const Divider(height: 32),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('앱 정보'),
            subtitle: Text(
              'PARKIT v0.2.0\n대구 지역 주차장 추천 서비스 (FastAPI 백엔드 연동)',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}
