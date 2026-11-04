import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../../data/models/lat_lng_point.dart';
import '../../data/models/recommend_item.dart';
import '../../data/models/road_nearby_result.dart';

/// 지도 패키지(flutter_naver_map)에 의존하는 코드는 이 파일에만 둔다.
/// 다른 화면/위젯은 이 위젯을 통해서만 지도 기능을 사용한다.
class ParkingMap extends StatefulWidget {
  final LatLngPoint center;
  final int radiusMeters;
  final List<RecommendItem> items;
  final int? selectedId;
  final RoadNearbyResult? roadResult;
  final double height;
  final ValueChanged<LatLngPoint> onTapMap;
  final ValueChanged<int> onSelectItem;

  const ParkingMap({
    super.key,
    required this.center,
    required this.radiusMeters,
    required this.items,
    required this.selectedId,
    required this.roadResult,
    required this.height,
    required this.onTapMap,
    required this.onSelectItem,
  });

  @override
  State<ParkingMap> createState() => _ParkingMapState();
}

class _ParkingMapState extends State<ParkingMap> {
  NaverMapController? _controller;
  bool _isSyncing = false;
  bool _pendingResync = false;

  @override
  void didUpdateWidget(covariant ParkingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.selectedId != widget.selectedId ||
        oldWidget.roadResult != widget.roadResult ||
        oldWidget.center != widget.center ||
        oldWidget.radiusMeters != widget.radiusMeters) {
      _syncOverlays();
    }
    if (oldWidget.selectedId != widget.selectedId && widget.selectedId != null) {
      _animateToSelected();
    }
  }

  Future<void> _syncOverlays() async {
    final controller = _controller;
    if (controller == null) return;

    if (_isSyncing) {
      _pendingResync = true;
      return;
    }
    _isSyncing = true;

    final overlays = <NAddableOverlay>{
      NCircleOverlay(
        id: 'search-radius',
        center: NLatLng(widget.center.lat, widget.center.lng),
        radius: widget.radiusMeters.toDouble(),
        color: Colors.blueAccent.withValues(alpha: 0.08),
        outlineColor: Colors.blueAccent,
        outlineWidth: 1,
      ),
      NMarker(
        id: 'search-center',
        position: NLatLng(widget.center.lat, widget.center.lng),
        iconTintColor: Colors.blue,
        caption: const NOverlayCaption(text: '검색 중심'),
      ),
    };

    for (final item in widget.items) {
      final selected = widget.selectedId == item.id;
      final color = item.rank == 1 ? Colors.green : Colors.red;
      final icon = await _numberedMarkerIcon(rank: item.rank, color: color, selected: selected);
      final marker = NMarker(
        id: 'parking-${item.id}',
        position: NLatLng(item.location.lat, item.location.lng),
        icon: icon,
        caption: NOverlayCaption(text: item.name),
      );
      marker.setOnTapListener((_) => widget.onSelectItem(item.id));
      overlays.add(marker);
    }

    final roadResult = widget.roadResult;
    if (roadResult != null) {
      for (var i = 0; i < roadResult.cameras.length; i++) {
        final camera = roadResult.cameras[i];
        overlays.add(NMarker(
          id: 'camera-$i',
          position: NLatLng(camera.lat, camera.lng),
          iconTintColor: Colors.purple,
          caption: NOverlayCaption(text: camera.place ?? camera.roadName ?? '단속카메라'),
        ));
      }
      for (var i = 0; i < roadResult.spots.length; i++) {
        final spot = roadResult.spots[i];
        overlays.add(NCircleOverlay(
          id: 'spot-$i',
          center: NLatLng(spot.lat, spot.lng),
          radius: 10,
          color: Colors.orange.withValues(alpha: 0.6),
          outlineWidth: 0,
        ));
      }
    }

    if (!mounted) {
      _isSyncing = false;
      return;
    }

    await controller.clearOverlays();
    await controller.addOverlayAll(overlays);

    _isSyncing = false;
    if (_pendingResync) {
      _pendingResync = false;
      await _syncOverlays();
    }
  }

  Future<void> _animateToSelected() async {
    final controller = _controller;
    if (controller == null) return;
    final item = widget.items.where((e) => e.id == widget.selectedId).firstOrNull;
    if (item == null) return;
    await controller.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: NLatLng(item.location.lat, item.location.lng)),
    );
  }

  Future<NOverlayImage> _numberedMarkerIcon({
    required int rank,
    required Color color,
    required bool selected,
  }) async {
    final size = selected ? 64.0 : 52.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - (selected ? 4 : 2);

    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected ? 4 : 2,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$rank',
        style: TextStyle(
          color: Colors.white,
          fontSize: selected ? 22 : 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    return NOverlayImage.fromByteArray(bytes, cacheKey: 'rank-$rank-$selected');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(widget.center.lat, widget.center.lng),
            zoom: 14,
          ),
        ),
        onMapReady: (controller) {
          _controller = controller;
          _syncOverlays();
        },
        onMapTapped: (point, latLng) =>
            widget.onTapMap(LatLngPoint(lat: latLng.latitude, lng: latLng.longitude)),
      ),
    );
  }
}
