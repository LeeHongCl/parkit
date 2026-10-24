import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../data/models/lat_lng_point.dart';
import '../../data/models/recommend_item.dart';
import '../../data/models/road_nearby_result.dart';

/// 지도 패키지(google_maps_flutter)에 의존하는 코드는 이 파일에만 둔다.
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
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  bool _isBuildingMarkers = false;

  @override
  void initState() {
    super.initState();
    _rebuildMarkers();
  }

  @override
  void didUpdateWidget(covariant ParkingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.selectedId != widget.selectedId ||
        oldWidget.roadResult != widget.roadResult ||
        oldWidget.center != widget.center) {
      _rebuildMarkers();
    }
    if (oldWidget.selectedId != widget.selectedId && widget.selectedId != null) {
      _animateToSelected();
    }
  }

  Future<void> _rebuildMarkers() async {
    if (_isBuildingMarkers) return;
    _isBuildingMarkers = true;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('search-center'),
        position: LatLng(widget.center.lat, widget.center.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        zIndexInt: 1,
        infoWindow: const InfoWindow(title: '검색 중심'),
      ),
    };

    for (final item in widget.items) {
      final selected = widget.selectedId == item.id;
      final color = item.rank == 1 ? Colors.green : Colors.red;
      final icon = await _numberedMarkerIcon(rank: item.rank, color: color, selected: selected);
      markers.add(
        Marker(
          markerId: MarkerId('parking-${item.id}'),
          position: LatLng(item.location.lat, item.location.lng),
          icon: icon,
          zIndexInt: selected ? 10 : 2,
          infoWindow: InfoWindow(title: '${item.rank}위 · ${item.name}'),
          onTap: () => widget.onSelectItem(item.id),
        ),
      );
    }

    final roadResult = widget.roadResult;
    if (roadResult != null) {
      for (var i = 0; i < roadResult.cameras.length; i++) {
        final camera = roadResult.cameras[i];
        markers.add(
          Marker(
            markerId: MarkerId('camera-$i'),
            position: LatLng(camera.lat, camera.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            zIndexInt: 0,
            infoWindow: InfoWindow(title: camera.place ?? camera.roadName ?? '단속카메라'),
          ),
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _markers = markers;
      _isBuildingMarkers = false;
    });
  }

  Future<void> _animateToSelected() async {
    final controller = _controller;
    if (controller == null) return;
    final item = widget.items.where((e) => e.id == widget.selectedId).firstOrNull;
    if (item == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLng(LatLng(item.location.lat, item.location.lng)),
    );
  }

  Future<BitmapDescriptor> _numberedMarkerIcon({
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
    return BitmapDescriptor.bytes(bytes, width: size, height: size);
  }

  Set<Circle> _buildCircles() {
    final circles = <Circle>{
      Circle(
        circleId: const CircleId('search-radius'),
        center: LatLng(widget.center.lat, widget.center.lng),
        radius: widget.radiusMeters.toDouble(),
        strokeWidth: 1,
        strokeColor: Colors.blueAccent,
        fillColor: Colors.blueAccent.withValues(alpha: 0.08),
      ),
    };

    final roadResult = widget.roadResult;
    if (roadResult != null) {
      for (var i = 0; i < roadResult.spots.length; i++) {
        final spot = roadResult.spots[i];
        circles.add(
          Circle(
            circleId: CircleId('spot-$i'),
            center: LatLng(spot.lat, spot.lng),
            radius: 10,
            strokeWidth: 0,
            fillColor: Colors.orange.withValues(alpha: 0.6),
          ),
        );
      }
    }

    return circles;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.center.lat, widget.center.lng),
          zoom: 14,
        ),
        onMapCreated: (controller) => _controller = controller,
        onTap: (position) => widget.onTapMap(LatLngPoint(lat: position.latitude, lng: position.longitude)),
        markers: _markers,
        circles: _buildCircles(),
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
