import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/report_providers.dart';

enum FieldType { text, number, select }

class SurveyField {
  final String id;
  final String label;
  final FieldType type;
  final List<String> options;

  const SurveyField({
    required this.id,
    required this.label,
    required this.type,
    this.options = const [],
  });
}

class SurveyArchitectScreen extends ConsumerStatefulWidget {
  const SurveyArchitectScreen({super.key});

  @override
  ConsumerState<SurveyArchitectScreen> createState() => _SurveyArchitectScreenState();
}

class _SurveyArchitectScreenState extends ConsumerState<SurveyArchitectScreen> {
  final _title = TextEditingController(text: 'Community Report');
  final _severity = ValueNotifier<int>(5);
  final _majorTag = TextEditingController(text: 'Water');

  final _newFieldLabel = TextEditingController();
  FieldType _newFieldType = FieldType.text;
  final _newFieldOptions = TextEditingController();

  final _uuid = const Uuid();
  final List<SurveyField> _fields = [];
  final Map<String, dynamic> _answers = {};
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _majorTag.dispose();
    _newFieldLabel.dispose();
    _newFieldOptions.dispose();
    _severity.dispose();
    super.dispose();
  }

  void _addField() {
    final label = _newFieldLabel.text.trim();
    if (label.isEmpty) return;
    final options = _newFieldType == FieldType.select
        ? _newFieldOptions.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : const <String>[];

    setState(() {
      _fields.add(
        SurveyField(
          id: _uuid.v4(),
          label: label,
          type: _newFieldType,
          options: options,
        ),
      );
      _newFieldLabel.clear();
      _newFieldOptions.clear();
      _newFieldType = FieldType.text;
    });
  }

  Future<void> _submit() async {
    final auth = ref.read(authProvider);
    final uid = auth.session?.user.id;
    if (uid == null) return;

    setState(() => _busy = true);
    try {
      final pos = ref.read(locationProvider).valueOrNull;
      await ref.read(reportsRepositoryProvider).create(
            createdBy: uid,
            title: _title.text.trim().isEmpty ? 'Report' : _title.text.trim(),
            payload: {
              'fields': [
                for (final f in _fields)
                  {
                    'id': f.id,
                    'label': f.label,
                    'type': f.type.name,
                    'options': f.options,
                  }
              ],
              'answers': _answers,
            },
            severityScore: _severity.value,
            majorProblemTag: _majorTag.text.trim().isEmpty ? null : _majorTag.text.trim(),
            lat: pos?.latitude,
            lng: pos?.longitude,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted')),
        );
        setState(() => _answers.clear());
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pos = ref.watch(locationProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey architect'),
        actions: [
          TextButton(
            onPressed: _busy ? null : _submit,
            child: _busy ? const Text('Saving...') : const Text('Submit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Report title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _majorTag,
                    decoration: const InputDecoration(
                      labelText: 'Major problem tag',
                      hintText: 'e.g., Water, Sanitation, Roads',
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: _severity,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Severity score: $value'),
                          Slider(
                            value: value.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: '$value',
                            onChanged: (v) => _severity.value = v.round(),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pos == null
                        ? 'GPS: not available (grant location permission)'
                        : 'GPS: ${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Build fields', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _newFieldLabel,
                    decoration: const InputDecoration(labelText: 'Field label'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<FieldType>(
                    value: _newFieldType,
                    decoration: const InputDecoration(labelText: 'Field type'),
                    items: const [
                      DropdownMenuItem(value: FieldType.text, child: Text('Text')),
                      DropdownMenuItem(value: FieldType.number, child: Text('Number')),
                      DropdownMenuItem(value: FieldType.select, child: Text('Select')),
                    ],
                    onChanged: (v) => setState(() => _newFieldType = v ?? FieldType.text),
                  ),
                  const SizedBox(height: 12),
                  if (_newFieldType == FieldType.select)
                    TextField(
                      controller: _newFieldOptions,
                      decoration: const InputDecoration(
                        labelText: 'Options (comma-separated)',
                        hintText: 'e.g., Low, Medium, High',
                      ),
                    ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _addField,
                      icon: const Icon(Icons.add),
                      label: const Text('Add field'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Fill report', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final f in _fields) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            f.label,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() {
                            _fields.removeWhere((x) => x.id == f.id);
                            _answers.remove(f.id);
                          }),
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Remove field',
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    _fieldInput(f),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (_fields.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Add a few fields to start building a survey.'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldInput(SurveyField f) {
    switch (f.type) {
      case FieldType.text:
        return TextField(
          decoration: const InputDecoration(hintText: 'Enter text'),
          onChanged: (v) => _answers[f.id] = v,
        );
      case FieldType.number:
        return TextField(
          decoration: const InputDecoration(hintText: 'Enter number'),
          keyboardType: TextInputType.number,
          onChanged: (v) => _answers[f.id] = num.tryParse(v),
        );
      case FieldType.select:
        return DropdownButtonFormField<String>(
          value: (_answers[f.id] as String?),
          decoration: const InputDecoration(hintText: 'Choose'),
          items: [
            for (final o in f.options) DropdownMenuItem(value: o, child: Text(o)),
          ],
          onChanged: (v) => _answers[f.id] = v,
        );
    }
  }
}

