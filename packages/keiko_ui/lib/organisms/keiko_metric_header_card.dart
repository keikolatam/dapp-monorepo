import 'package:flutter/material.dart';

import '../atoms/keiko_percent_badge.dart';
import '../molecules/keiko_progress_meter.dart';

/// Organism — header card combining identity (title/subtitle) with a key
/// metric: a [KeikoPercentBadge] next to a [KeikoProgressMeter].
///
/// Purely presentational — data arrives by props so the shared package
/// never depends on app domain types.
class KeikoMetricHeaderCard extends StatelessWidget {
  const KeikoMetricHeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.progressLabel,
    this.progressCaption,
  });

  final String title;
  final String subtitle;

  /// Metric in `0..100`; also drives the progress bar (`percent / 100`).
  final int percent;
  final String progressLabel;
  final String? progressCaption;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: text.titleLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: text.bodyMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                KeikoPercentBadge(value: percent),
                const SizedBox(width: 16),
                Expanded(
                  child: KeikoProgressMeter(
                    label: progressLabel,
                    value: percent / 100,
                    caption: progressCaption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
