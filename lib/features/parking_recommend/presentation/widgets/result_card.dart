import 'package:flutter/material.dart';

import '../../data/models/recommend_item.dart';
import '../../domain/format.dart';

class ResultCard extends StatelessWidget {
  final RecommendItem item;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDetail;

  const ResultCard({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: selected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: item.rank == 1
                        ? Colors.green
                        : theme.colorScheme.error,
                    child: Text(
                      '${item.rank}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(onPressed: onDetail, child: const Text('자세히 보기')),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.directions_walk, size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Text(formatDistance(item.distanceM)),
                  const SizedBox(width: 16),
                  Icon(Icons.payments_outlined, size: 16, color: theme.colorScheme.secondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(formatEstimatedFee(item))),
                ],
              ),
              if (item.reasons.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.reasons
                      .map((reason) => Chip(
                            label: Text(reason, style: theme.textTheme.labelSmall),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
