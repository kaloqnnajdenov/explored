import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../data/models/explored_area_filter.dart';
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
        final formatted = _formatArea(
          state.areaKm2,
          Localizations.localeOf(context),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(LocaleKeys.explored_area_title.tr()),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      LocaleKeys.explored_area_value
                          .tr(namedArgs: {'value': formatted}),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      LocaleKeys.explored_area_filter_label.tr(),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<ExploredAreaFilterPreset>(
                    isExpanded: true,
                    value: state.filter.preset,
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      widget.viewModel.selectPreset(value);
                    },
                    items: _filterItems(context),
                  ),
                  if (state.filter.preset ==
                      ExploredAreaFilterPreset.custom)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickStartDate(context),
                              child: Text(
                                _dateLabel(
                                  context,
                                  state.filter.customStart,
                                  LocaleKeys.explored_area_filter_select_start,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _pickEndDate(context),
                              child: Text(
                                _dateLabel(
                                  context,
                                  state.filter.customEnd,
                                  LocaleKeys.explored_area_filter_select_end,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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

  int _decimalsForKm2(double km2) => 2;

  List<DropdownMenuItem<ExploredAreaFilterPreset>> _filterItems(
    BuildContext context,
  ) {
    return [
      DropdownMenuItem(
        value: ExploredAreaFilterPreset.allTime,
        child: Text(LocaleKeys.explored_area_filter_all_time.tr()),
      ),
      DropdownMenuItem(
        value: ExploredAreaFilterPreset.last7Days,
        child: Text(LocaleKeys.explored_area_filter_last_7_days.tr()),
      ),
      DropdownMenuItem(
        value: ExploredAreaFilterPreset.last30Days,
        child: Text(LocaleKeys.explored_area_filter_last_30_days.tr()),
      ),
      DropdownMenuItem(
        value: ExploredAreaFilterPreset.thisMonth,
        child: Text(LocaleKeys.explored_area_filter_this_month.tr()),
      ),
      DropdownMenuItem(
        value: ExploredAreaFilterPreset.custom,
        child: Text(LocaleKeys.explored_area_filter_custom.tr()),
      ),
    ];
  }

  String _dateLabel(
    BuildContext context,
    DateTime? value,
    String fallbackKey,
  ) {
    if (value == null) {
      return fallbackKey.tr();
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.yMMMd(locale);
    return formatter.format(value);
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final state = widget.viewModel.state;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: state.filter.customStart ?? now,
    );
    if (picked != null) {
      await widget.viewModel.setCustomStart(picked);
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final state = widget.viewModel.state;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: state.filter.customEnd ?? now,
    );
    if (picked != null) {
      await widget.viewModel.setCustomEnd(picked);
    }
  }
}
