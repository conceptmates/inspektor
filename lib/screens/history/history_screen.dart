import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/inspection_lists_controller.dart';
import '../inspection/widgets/inspection_list.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyControllerProvider);
    final notifier = ref.read(historyControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Inspection History')),
      body: InspectionList(
        state: state,
        onRefresh: notifier.refresh,
        onLoadMore: notifier.loadMore,
        emptyMessage: 'No inspection history.',
      ),
    );
  }
}
