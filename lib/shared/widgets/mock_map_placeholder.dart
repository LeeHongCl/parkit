import 'package:flutter/material.dart';

import '../../features/parking/domain/parking_lot.dart';

/// 실제 지도 SDK(Kakao/Naver) 연동 전까지 사용하는 자리표시 위젯.
/// 좌표를 영역 내 상대 위치로 정규화해 마커만 흉내낸다 (실제 지도 투영이 아님).
class MockMapPlaceholder extends StatelessWidget {
  final List<ParkingLot> parkingLots;
  final VoidCallback? onTap;

  const MockMapPlaceholder({super.key, required this.parkingLots, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 220,
          color: theme.colorScheme.surfaceContainerHighest,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPainter(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  ..._buildMarkers(context, constraints.biggest),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _buildLabel(theme, '지도 미리보기 (지도 SDK 연동 예정)'),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Icon(Icons.my_location, color: theme.colorScheme.primary),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: theme.textTheme.labelSmall),
    );
  }

  List<Widget> _buildMarkers(BuildContext context, Size size) {
    if (parkingLots.isEmpty) return const [];

    final lats = parkingLots.map((l) => l.latitude).toList();
    final lngs = parkingLots.map((l) => l.longitude).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    final latRange = (maxLat - minLat) < 0.0005 ? 0.0005 : (maxLat - minLat);
    final lngRange = (maxLng - minLng) < 0.0005 ? 0.0005 : (maxLng - minLng);

    const inset = 32.0;
    final usableWidth = size.width - inset * 2;
    final usableHeight = size.height - inset * 2;

    return parkingLots.map((lot) {
      final normalizedX = (lot.longitude - minLng) / lngRange;
      final normalizedY = 1 - ((lot.latitude - minLat) / latRange);
      return Positioned(
        left: inset + normalizedX * usableWidth - 11,
        top: inset + normalizedY * usableHeight - 11,
        child: Icon(
          Icons.local_parking,
          color: lot.isFree ? Colors.green : Theme.of(context).colorScheme.error,
          size: 22,
        ),
      );
    }).toList();
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => false;
}
