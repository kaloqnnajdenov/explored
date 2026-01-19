import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../view_model/gpx_import_view_model.dart';

class GpxImportProcessingOverlay extends StatelessWidget {
  const GpxImportProcessingOverlay({
    required this.viewModel,
    super.key,
  });

  final GpxImportViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final state = viewModel.state;
        if (!state.isProcessing) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            const ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
            Center(
              child: Card(
                elevation: 6,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.statusKey.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: state.progress),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
