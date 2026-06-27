import 'package:flutter/material.dart';

import '../../../core/mock/mock_data.dart';
import '../../../shared/widgets/apr_entry_card.dart';

class StudentAprScreen extends StatelessWidget {
  const StudentAprScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = MockData.aprEntries;
    return Scaffold(
      appBar: AppBar(title: const Text('Academic Progress Report')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => AprEntryCard(entry: entries[index]),
      ),
    );
  }
}
