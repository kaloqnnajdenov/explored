import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../translations/locale_keys.g.dart';
import '../data/models/manual_explore_delete_summary.dart';
import '../data/models/manual_explore_mode.dart';
import '../data/models/manual_explore_view_state.dart';
import '../view_model/manual_explore_view_model.dart';

class ManualExploreView extends StatefulWidget {
  const ManualExploreView({
    required this.viewModel,
    super.key,
  });

  final ManualExploreViewModel viewModel;

  @override
  State<ManualExploreView> createState() => _ManualExploreViewState();
}

class _ManualExploreViewState extends State<ManualExploreView> {
  late final MapController _mapController;
  final Set<int> _activePointers = <int>{};
  Offset? _lastPaintPosition;
  bool _isPainting = false;
  static const double _paintSampleThreshold = 12.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
              _buildMap(state),
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: SafeArea(
                  child: _ControlPanel(
                    state: state,
                    viewModel: widget.viewModel,
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: SafeArea(
                  child: _ActionBar(
                    state: state,
                    viewModel: widget.viewModel,
                  ),
                ),
              ),
              if (state.isSaving)
                const Positioned.fill(
                  child: AbsorbPointer(
                    child: ColoredBox(
                      color: Color.fromRGBO(0, 0, 0, 0.2),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap(ManualExploreViewState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite &&
                constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        final minZoom = _minZoomForHeight(height);
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerUp,
          onPointerCancel: _handlePointerCancel,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: state.center,
              initialZoom: state.zoom,
              minZoom: minZoom,
              interactionOptions: InteractionOptions(
                flags: _interactionFlags(),
              ),
              onPositionChanged: (camera, _) {
                widget.viewModel.updateMapZoom(camera.zoom);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: state.tileSource.urlTemplate,
                subdomains: state.tileSource.subdomains,
                userAgentPackageName: state.tileSource.userAgentPackageName,
                tileProvider: state.tileSource.tileProvider,
              ),
              TileLayer(
                tileProvider: widget.viewModel.overlayTileProvider,
                tileSize: state.overlayTileSize.size.toDouble(),
                maxNativeZoom: 19,
                keepBuffer: 2,
                panBuffer: 1,
                tileDisplay: const TileDisplay.instantaneous(opacity: 1),
                reset: widget.viewModel.overlayResetStream,
              ),
              if (state.addPolygons.isNotEmpty)
                PolygonLayer(
                  polygons: _buildPolygons(
                    state.addPolygons,
                    color: Colors.green.withValues(alpha: 0.35),
                    borderColor: Colors.green.shade700,
                  ),
                ),
              if (state.deletePolygons.isNotEmpty)
                PolygonLayer(
                  polygons: _buildPolygons(
                    state.deletePolygons,
                    color: Colors.red.withValues(alpha: 0.35),
                    borderColor: Colors.red.shade700,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Polygon> _buildPolygons(
    List<List<LatLng>> rings, {
    required Color color,
    required Color borderColor,
  }) {
    return [
      for (final ring in rings)
        Polygon(
          points: ring,
          color: color,
          borderColor: borderColor,
          borderStrokeWidth: 1.5,
        ),
    ];
  }

  int _interactionFlags() {
    return InteractiveFlag.pinchZoom |
        InteractiveFlag.pinchMove |
        InteractiveFlag.rotate;
  }

  double _minZoomForHeight(double height) {
    if (height <= 0) {
      return 0;
    }

    final zoom = const Epsg3857().zoom(height);
    if (!zoom.isFinite) {
      return 0;
    }

    return zoom < 0 ? 0 : zoom;
  }

  ManualExploreViewState get _state => widget.viewModel.state;

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers.add(event.pointer);
    if (_activePointers.length > 1) {
      _cancelPaint();
      return;
    }
    _isPainting = true;
    _lastPaintPosition = event.localPosition;
    widget.viewModel.beginPaintStroke();
    _addPaintSample(event.localPosition);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isPainting) {
      return;
    }
    if (_activePointers.length > 1) {
      _cancelPaint();
      return;
    }
    final last = _lastPaintPosition;
    if (last == null) {
      _lastPaintPosition = event.localPosition;
      _addPaintSample(event.localPosition);
      return;
    }
    if ((event.localPosition - last).distance >= _paintSampleThreshold) {
      _lastPaintPosition = event.localPosition;
      _addPaintSample(event.localPosition);
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.isNotEmpty) {
      return;
    }
    if (_isPainting) {
      widget.viewModel.endPaintStroke();
    }
    _isPainting = false;
    _lastPaintPosition = null;
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _activePointers.remove(event.pointer);
    _cancelPaint();
  }

  void _cancelPaint() {
    if (_isPainting) {
      widget.viewModel.cancelPaintStroke();
    }
    _isPainting = false;
    _lastPaintPosition = null;
  }

  void _addPaintSample(Offset position) {
    MapCamera camera;
    try {
      camera = _mapController.camera;
    } catch (_) {
      return;
    }
    final point = Point<double>(position.dx, position.dy);
    final latLng = camera.pointToLatLng(point);
    widget.viewModel.addPaintSample(latLng);
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.state, required this.viewModel});

  final ManualExploreViewState state;
  final ManualExploreViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCollapsed = state.isControlPanelCollapsed;
    final toggleIcon = IconButton(
      tooltip: (isCollapsed
              ? LocaleKeys.manual_explore_controls_expand
              : LocaleKeys.manual_explore_controls_collapse)
          .tr(),
      onPressed: viewModel.toggleControlPanelCollapsed,
      icon: Icon(isCollapsed ? Icons.expand_more : Icons.expand_less),
    );
    return Card(
      elevation: 2,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: isCollapsed
            ? Row(
                children: [
                  Expanded(
                    child: _ModeToggle(
                      mode: state.mode,
                      viewModel: viewModel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  toggleIcon,
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.manual_explore_mode_label.tr(),
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      toggleIcon,
                    ],
                  ),
                  const SizedBox(height: 8),
                  _ModeToggle(
                    mode: state.mode,
                    viewModel: viewModel,
                  ),
                  const SizedBox(height: 12),
                  _ApplyDateRow(
                    applyDateTime: state.applyDateTimeLocal,
                    viewModel: viewModel,
                  ),
                ],
              ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.viewModel,
  });

  final ManualExploreMode mode;
  final ManualExploreViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ManualExploreMode>(
      segments: [
        ButtonSegment(
          value: ManualExploreMode.add,
          label: Text(LocaleKeys.manual_explore_mode_add.tr()),
        ),
        ButtonSegment(
          value: ManualExploreMode.delete,
          label: Text(LocaleKeys.manual_explore_mode_delete.tr()),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (selection) {
        if (selection.isEmpty) {
          return;
        }
        viewModel.setMode(selection.first);
      },
    );
  }
}

class _ApplyDateRow extends StatelessWidget {
  const _ApplyDateRow({
    required this.applyDateTime,
    required this.viewModel,
  });

  final DateTime? applyDateTime;
  final ManualExploreViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _pickDateTime(context, viewModel),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(_applyDateLabel(context)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: viewModel.resetApplyDateToNow,
          child: Text(LocaleKeys.manual_explore_apply_date_now.tr()),
        ),
      ],
    );
  }

  String _applyDateLabel(BuildContext context) {
    final prefix = LocaleKeys.manual_explore_apply_date_label.tr();
    final value = applyDateTime;
    if (value == null) {
      return '$prefix: ${LocaleKeys.manual_explore_apply_date_now.tr()}';
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = DateFormat.yMMMd(locale).add_jm();
    return '$prefix: ${formatter.format(value)}';
  }

  Future<void> _pickDateTime(
    BuildContext context,
    ManualExploreViewModel viewModel,
  ) async {
    final now = DateTime.now();
    final initial = applyDateTime ?? now;
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDate: initial,
    );
    if (date == null) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    final resolved = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? initial.hour,
      time?.minute ?? initial.minute,
    );
    viewModel.setApplyDateTime(resolved);
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.state,
    required this.viewModel,
  });

  final ManualExploreViewState state;
  final ManualExploreViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final controlsEnabled = !state.isSaving;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton(
              onPressed:
                  !controlsEnabled || !state.canUndo ? null : viewModel.undo,
              child: Text(LocaleKeys.manual_explore_undo.tr()),
            ),
            OutlinedButton(
              onPressed:
                  !controlsEnabled || !state.canRedo ? null : viewModel.redo,
              child: Text(LocaleKeys.manual_explore_redo.tr()),
            ),
            OutlinedButton(
              onPressed: !controlsEnabled
                  ? null
                  : () => _handleDiscard(context, viewModel, state),
              child: Text(LocaleKeys.manual_explore_discard.tr()),
            ),
            FilledButton(
              onPressed: !controlsEnabled || !state.hasChanges
                  ? null
                  : () => _handleSave(context, viewModel, state),
              child: Text(LocaleKeys.manual_explore_save.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDiscard(
    BuildContext context,
    ManualExploreViewModel viewModel,
    ManualExploreViewState state,
  ) async {
    if (state.hasChanges) {
      final shouldDiscard = await _confirmDiscard(context);
      if (!shouldDiscard) {
        return;
      }
      viewModel.resetSession();
    }
    if (!context.mounted) {
      return;
    }
    Navigator.of(context).maybePop();
  }

  Future<void> _handleSave(
    BuildContext context,
    ManualExploreViewModel viewModel,
    ManualExploreViewState state,
  ) async {
    if (!state.hasChanges) {
      return;
    }
    final summary = await viewModel.fetchDeleteSummary();
    if (!context.mounted) {
      return;
    }
    if (summary.hasDeletes) {
      final confirmed = await _confirmDelete(context, summary);
      if (!confirmed) {
        return;
      }
    }
    final success = await viewModel.saveEdits();
    if (!context.mounted) {
      return;
    }
    if (success) {
      Navigator.of(context).maybePop();
    }
  }

  Future<bool> _confirmDiscard(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(LocaleKeys.manual_explore_discard_title.tr()),
        content: Text(LocaleKeys.manual_explore_discard_message.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocaleKeys.manual_explore_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LocaleKeys.manual_explore_discard.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<bool> _confirmDelete(
    BuildContext context,
    ManualExploreDeleteSummary summary,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(LocaleKeys.manual_explore_delete_confirm_title.tr()),
        content: Text(
          LocaleKeys.manual_explore_delete_confirm_message.tr(
            namedArgs: {
              'cells': summary.cellCount.toString(),
              'points': summary.sampleCount.toString(),
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocaleKeys.manual_explore_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LocaleKeys.manual_explore_save.tr()),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
