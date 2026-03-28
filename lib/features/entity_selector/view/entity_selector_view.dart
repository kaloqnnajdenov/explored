import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/entity.dart';
import '../../../domain/entities/entity_type.dart';
import '../../../translations/locale_keys.g.dart';
import '../../../ui/core/app_colors.dart';
import '../view_model/entity_selector_view_model.dart';

class EntitySelectorView extends StatefulWidget {
  const EntitySelectorView({required this.viewModel, super.key});

  final EntitySelectorViewModel viewModel;

  @override
  State<EntitySelectorView> createState() => _EntitySelectorViewState();
}

class _EntitySelectorViewState extends State<EntitySelectorView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.loadCountries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (context, _) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            LocaleKeys.entity_selector_title.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.slate400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.viewModel.isLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          Text(
                            LocaleKeys.entity_selector_countries.tr(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final country in widget.viewModel.countries) ...[
                            _EntityTreeNode(
                              entity: country,
                              depth: 0,
                              viewModel: widget.viewModel,
                            ),
                            if (country != widget.viewModel.countries.last)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: widget.viewModel.selectedEntityId == null
                              ? null
                              : () async {
                                  await widget.viewModel.confirmSelection();
                                  if (!context.mounted) {
                                    return;
                                  }
                                  Navigator.of(context).pop(true);
                                },
                          child: Text(LocaleKeys.entity_selector_confirm.tr()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _EntityTreeNode extends StatelessWidget {
  const _EntityTreeNode({
    required this.entity,
    required this.depth,
    required this.viewModel,
  });

  final Entity entity;
  final int depth;
  final EntitySelectorViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final children = viewModel.childrenFor(entity.entityId);
    final isExpanded = viewModel.isExpanded(entity.entityId);
    final isLoadingChildren = viewModel.isLoadingChildren(entity.entityId);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 20.0),
          child: _EntityTile(
            entity: entity,
            isSelected: viewModel.selectedEntityId == entity.entityId,
            canExpand: viewModel.canExpand(entity),
            isExpanded: isExpanded,
            isLoadingChildren: isLoadingChildren,
            onTap: () => viewModel.selectEntity(entity.entityId),
            onToggleExpanded: () => viewModel.toggleExpanded(entity.entityId),
          ),
        ),
        if (isExpanded && children.isNotEmpty) ...[
          const SizedBox(height: 8),
          Column(
            children: [
              for (final child in children) ...[
                _EntityTreeNode(
                  entity: child,
                  depth: depth + 1,
                  viewModel: viewModel,
                ),
                if (child != children.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _EntityTile extends StatelessWidget {
  const _EntityTile({
    required this.entity,
    required this.isSelected,
    required this.canExpand,
    required this.isExpanded,
    required this.isLoadingChildren,
    required this.onTap,
    required this.onToggleExpanded,
  });

  final Entity entity;
  final bool isSelected;
  final bool canExpand;
  final bool isExpanded;
  final bool isLoadingChildren;
  final VoidCallback onTap;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey<String>('entity-selector-${entity.entityId}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.emerald600 : AppColors.slate200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.emerald100 : AppColors.indigo50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForType(entity.type),
                  color: isSelected
                      ? AppColors.emerald700
                      : AppColors.indigo600,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.name,
                      style: const TextStyle(
                        color: AppColors.slate900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _labelForType(entity.type).tr(),
                      style: const TextStyle(
                        color: AppColors.slate500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: AppColors.emerald600,
                    size: 18,
                  ),
                ),
              if (isLoadingChildren)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (canExpand)
                IconButton(
                  key: ValueKey<String>(
                    'entity-selector-expand-${entity.entityId}',
                  ),
                  onPressed: onToggleExpanded,
                  splashRadius: 18,
                  icon: Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: AppColors.slate400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(EntityType type) {
    switch (type) {
      case EntityType.country:
        return Icons.public;
      case EntityType.region:
        return Icons.terrain;
      case EntityType.city:
        return Icons.location_city;
      case EntityType.cityCenter:
        return Icons.place;
    }
  }

  String _labelForType(EntityType type) {
    switch (type) {
      case EntityType.country:
        return LocaleKeys.entity_type_country;
      case EntityType.region:
        return LocaleKeys.entity_type_region;
      case EntityType.city:
        return LocaleKeys.entity_type_city;
      case EntityType.cityCenter:
        return LocaleKeys.entity_type_city_center;
    }
  }
}
