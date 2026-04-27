import 'package:flutter/material.dart';

class PrototypeShell extends StatefulWidget {
  const PrototypeShell({super.key});

  @override
  State<PrototypeShell> createState() => _PrototypeShellState();
}

class _PrototypeShellState extends State<PrototypeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _PrototypeHomePage(),
      _PrototypeNeedsPage(),
      _PrototypeMatchPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource-Devta (Prototype)'),
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.priority_high_outlined),
            label: 'Needs',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            label: 'Match',
          ),
        ],
      ),
    );
  }
}

class _PrototypeHomePage extends StatelessWidget {
  const _PrototypeHomePage();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Resource Allocation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prototype mode (no Supabase). Use this to validate UI flow on mobile.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _KpiRow(),
        const SizedBox(height: 12),
        const _SectionCard(
          title: 'Next steps',
          bullets: [
            'Add Supabase keys to enable login + data sync',
            'Connect survey ingestion → priority list',
            'Implement volunteer matching + assignments',
          ],
        ),
      ],
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _KpiCard(label: 'Open needs', value: '12'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _KpiCard(label: 'Volunteers', value: '48'),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _KpiCard(label: 'Matches', value: '9'),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;

  const _KpiCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: t.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(value, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _PrototypeNeedsPage extends StatelessWidget {
  const _PrototypeNeedsPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionCard(
          title: 'Urgent needs (stub)',
          bullets: [
            'Water supply issue — Ward 3',
            'Food distribution — Community center',
            'Medical camp staffing — Clinic zone',
          ],
        ),
      ],
    );
  }
}

class _PrototypeMatchPage extends StatelessWidget {
  const _PrototypeMatchPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _SectionCard(
          title: 'Volunteer matching (stub)',
          bullets: [
            'Match by distance + skills + availability',
            'Show suggested volunteers per task',
            'One-tap assign + notify',
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<String> bullets;

  const _SectionCard({required this.title, required this.bullets});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            for (final b in bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(Icons.check_circle_outline, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(b)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

