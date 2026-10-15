import 'package:flutter/material.dart';

import '../../domain/parking_lot.dart';
import '../../domain/parking_type.dart';

class ParkingListItem extends StatelessWidget {
  final ParkingLot parkingLot;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ParkingListItem({
    super.key,
    required this.parkingLot,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor: parkingLot.parkingType == ParkingType.public
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.tertiaryContainer,
          child: Text(
            parkingLot.parkingType.label.substring(0, 1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(parkingLot.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parkingLot.address, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: [
                _availabilityChip(theme),
                if (parkingLot.isFree) _compactChip(theme, '무료', theme.colorScheme.secondaryContainer),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
          color: isFavorite ? theme.colorScheme.error : null,
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }

  Widget _availabilityChip(ThemeData theme) {
    if (!parkingLot.hasRealtimeAvailability) {
      return _compactChip(theme, '가용 정보 없음', theme.colorScheme.surfaceContainerHighest);
    }
    final available = parkingLot.availableSpaces!;
    final isAvailable = available > 0;
    return _compactChip(
      theme,
      isAvailable ? '잔여 $available면' : '만차',
      isAvailable ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
    );
  }

  Widget _compactChip(ThemeData theme, String label, Color backgroundColor) {
    return Chip(
      label: Text(label, style: theme.textTheme.labelSmall),
      backgroundColor: backgroundColor,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
