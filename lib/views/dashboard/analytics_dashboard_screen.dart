import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/report_providers.dart';
import '../../widgets/stat_graph.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsStreamProvider);

    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          title: Text('Analytics dashboard'),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: reportsAsync.when(
            data: (reports) {
              final last14 = reports
                  .where((r) => r.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 14))))
                  .toList();
              last14.sort((a, b) => a.createdAt.compareTo(b.createdAt));

              final points = <FlSpot>[];
              for (var i = 0; i < last14.length; i++) {
                points.add(FlSpot(i.toDouble(), last14[i].severityScore.toDouble()));
              }

              final hotspotCounts = <String, int>{};
              for (final r in reports) {
                final tag = (r.majorProblemTag ?? 'Uncategorized').trim();
                hotspotCounts[tag] = (hotspotCounts[tag] ?? 0) + 1;
              }
              final top = hotspotCounts.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return SliverList(
                delegate: SliverChildListDelegate(
                  [
                    StatGraph(
                      title: 'Severity trend (last 14 days)',
                      subtitle: 'Higher severity indicates urgent needs.',
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: points,
                              isCurved: true,
                              dotData: const FlDotData(show: false),
                              barWidth: 3,
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StatGraph(
                      title: 'Major Problem hotspots',
                      subtitle: 'Top reported categories (proxy for hotspots).',
                      child: Column(
                        children: [
                          for (final e in top.take(5))
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(child: Text(e.key)),
                                  Text('${e.value}'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (e, _) => SliverToBoxAdapter(child: Text(e.toString())),
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

