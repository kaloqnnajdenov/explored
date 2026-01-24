import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../translations/locale_keys.g.dart';
import '../view_model/explored_area_view_model.dart';

class ExploredAreaView extends StatefulWidget {
  const ExploredAreaView({
    required this.viewModel,
    super.key,
  });

  final ExploredAreaViewModel viewModel;

  @override
  State<ExploredAreaView> createState() => _ExploredAreaViewState();
}

class _ExploredAreaViewState extends State<ExploredAreaView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;
        final km2 = state.totalAreaM2 / 1000000.0;
        final formatted = _formatArea(
          km2,
          Localizations.localeOf(context),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.explored_area_title.tr()),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                LocaleKeys.explored_area_value
                    .tr(namedArgs: {'value': formatted}),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatArea(double km2, Locale locale) {
    final decimals = _decimalsForKm2(km2);
    final formatter = NumberFormat.decimalPattern(locale.toLanguageTag());
    formatter.minimumFractionDigits = decimals;
    formatter.maximumFractionDigits = decimals;
    return formatter.format(km2);
  }

  int _decimalsForKm2(double km2) {
    return 4;
  }
}
