import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app_state/view_model/app_state_view_model.dart';
import '../../gpx_import/view/widgets/gpx_import_processing_overlay.dart';
import '../../gpx_import/view_model/gpx_import_view_model.dart';
import '../../map/view_model/map_view_model.dart';
import '../../region_catalog/data/models/region_pack_node.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../../../ui/core/widgets/app_back_button.dart';
import '../../../ui/core/widgets/coming_soon.dart';
import '../../../ui/core/widgets/hex_mascot.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({
    required this.appStateViewModel,
    required this.mapViewModel,
    required this.gpxImportViewModel,
    super.key,
  });

  final AppStateViewModel appStateViewModel;
  final MapViewModel mapViewModel;
  final GpxImportViewModel gpxImportViewModel;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int? _lastGpxFeedbackId;
  int? _lastExportFeedbackId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.appStateViewModel.ensureDownloadedPacksLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.appStateViewModel,
        widget.mapViewModel,
        widget.gpxImportViewModel,
      ]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.slate50,
          body: Stack(
            children: [
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Row(
                          children: [
                            AppBackButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                  return;
                                }
                                context.go('/');
                              },
                            ),
                            const SizedBox(width: 12),
                            Text(
                              LocaleKeys.settings_title.tr(),
                              style: const TextStyle(
                                color: AppColors.slate900,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.list(
                        children: [
                          _buildProfileCard(),
                          const SizedBox(height: 16),
                          _buildRegionPacksCard(context),
                          const SizedBox(height: 16),
                          _buildDataStorageCard(context),
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                              LocaleKeys.settings_version_text.tr(),
                              style: const TextStyle(
                                color: AppColors.slate400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GpxImportProcessingOverlay(viewModel: widget.gpxImportViewModel),
              _buildGpxFeedbackListener(),
              _buildExportFeedbackListener(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.emerald50,
            ),
            child: const Center(
              child: HexMascot(pose: HexMascotPose.idle, size: 120),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.settings_profile_name.tr(),
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                LocaleKeys.settings_profile_subtitle.tr(),
                style: const TextStyle(color: AppColors.slate500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegionPacksCard(BuildContext context) {
    final downloadedPacks = widget.appStateViewModel.downloadedPacks;
    final isLoadingDownloadedPacks =
        widget.appStateViewModel.isLoadingDownloadedPacks ||
        widget.appStateViewModel.hasPendingDownloadedPackRefs;
    final packsByCountry = <String, List<RegionPackNode>>{};
    for (final pack in downloadedPacks) {
      final country = widget.appStateViewModel.countryFor(pack.id);
      final groupLabel = country?.name ?? pack.name;
      (packsByCountry[groupLabel] ??= <RegionPackNode>[]).add(pack);
    }
    final sortedCountries = packsByCountry.keys.toList(growable: false)..sort();

    return _CardSection(
      title: LocaleKeys.settings_region_packs_title.tr(),
      child: downloadedPacks.isEmpty
          ? isLoadingDownloadedPacks
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Text(
                      LocaleKeys.settings_region_packs_empty.tr(),
                      style: const TextStyle(color: AppColors.slate500),
                    ),
                  )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (
                  var countryIndex = 0;
                  countryIndex < sortedCountries.length;
                  countryIndex++
                ) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                    child: Text(
                      sortedCountries[countryIndex],
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  for (
                    var packIndex = 0;
                    packIndex <
                        packsByCountry[sortedCountries[countryIndex]]!.length;
                    packIndex++
                  ) ...[
                    _RegionPackRow(
                      pack:
                          packsByCountry[sortedCountries[countryIndex]]![packIndex],
                      countryName: sortedCountries[countryIndex],
                      onDelete: () => showComingSoonSnackBar(context),
                    ),
                    if (packIndex !=
                        packsByCountry[sortedCountries[countryIndex]]!.length -
                            1)
                      const Divider(height: 1, color: AppColors.slate100),
                  ],
                  if (countryIndex != sortedCountries.length - 1)
                    const Divider(height: 1, color: AppColors.slate100),
                ],
              ],
            ),
    );
  }

  Widget _buildDataStorageCard(BuildContext context) {
    return _CardSection(
      title: LocaleKeys.settings_data_storage_title.tr(),
      child: Column(
        children: [
          _SettingsActionRow(
            icon: Icons.edit_outlined,
            label: LocaleKeys.settings_manual_edit_mode.tr(),
            onTap: () => context.go('/map'),
          ),
          const Divider(height: 1, color: AppColors.slate100),
          _SettingsActionRow(
            icon: Icons.admin_panel_settings_outlined,
            label: LocaleKeys.settings_permissions.tr(),
            onTap: () => context.go('/settings/permissions'),
          ),
          const Divider(height: 1, color: AppColors.slate100),
          _SettingsActionRow(
            icon: Icons.upload_outlined,
            label: LocaleKeys.settings_import_gpx.tr(),
            onTap: _handleImportGpx,
          ),
          const Divider(height: 1, color: AppColors.slate100),
          _SettingsActionRow(
            icon: Icons.file_upload_outlined,
            label: LocaleKeys.settings_export_csv.tr(),
            onTap: _showExportActionsSheet,
          ),
        ],
      ),
    );
  }

  Future<void> _handleImportGpx() async {
    await widget.gpxImportViewModel.importGpx();
  }

  Future<void> _showExportActionsSheet() async {
    final action = await showModalBottomSheet<_ExportAction>(
      context: context,
      builder: (context) {
        final cancelLabel = MaterialLocalizations.of(context).cancelButtonLabel;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  LocaleKeys.settings_export_csv.tr(),
                  style: const TextStyle(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.ios_share_outlined),
                title: Text(LocaleKeys.menu_export.tr()),
                onTap: () => Navigator.of(context).pop(_ExportAction.export),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: Text(LocaleKeys.menu_download.tr()),
                onTap: () => Navigator.of(context).pop(_ExportAction.download),
              ),
              ListTile(
                title: Text(
                  cancelLabel,
                  style: const TextStyle(color: AppColors.slate500),
                ),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );

    if (action == null) {
      return;
    }

    switch (action) {
      case _ExportAction.export:
        await widget.mapViewModel.exportHistory();
        break;
      case _ExportAction.download:
        await widget.mapViewModel.downloadHistory();
        break;
    }
  }

  Widget _buildGpxFeedbackListener() {
    return AnimatedBuilder(
      animation: widget.gpxImportViewModel,
      builder: (context, _) {
        final feedback = widget.gpxImportViewModel.state.feedback;
        if (feedback == null || feedback.id == _lastGpxFeedbackId) {
          return const SizedBox.shrink();
        }
        _lastGpxFeedbackId = feedback.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                feedback.messageKey.tr(namedArgs: feedback.namedArgs ?? {}),
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: feedback.isError
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          );
        });
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildExportFeedbackListener() {
    return AnimatedBuilder(
      animation: widget.mapViewModel,
      builder: (context, _) {
        final feedback = widget.mapViewModel.state.exportFeedback;
        if (feedback == null || feedback.id == _lastExportFeedbackId) {
          return const SizedBox.shrink();
        }
        _lastExportFeedbackId = feedback.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(feedback.messageKey.tr()),
              behavior: SnackBarBehavior.floating,
              backgroundColor: feedback.isError
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
          );
        });
        return const SizedBox.shrink();
      },
    );
  }
}

enum _ExportAction { export, download }

class _CardSection extends StatelessWidget {
  const _CardSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.slate900,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _RegionPackRow extends StatelessWidget {
  const _RegionPackRow({
    required this.pack,
    required this.countryName,
    required this.onDelete,
  });

  final RegionPackNode pack;
  final String countryName;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final name = pack.name == countryName
        ? pack.name
        : pack.displayPath.replaceFirst('$countryName / ', '');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.slate900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.rose500),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.slate600),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}
