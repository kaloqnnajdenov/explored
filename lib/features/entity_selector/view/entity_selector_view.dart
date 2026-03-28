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
                          icon: const Icon(Icons.close, color: AppColors.slate400),
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
                          _EntitySection(
                            title: LocaleKeys.entity_selector_countries.tr(),
                            entities: widget.viewModel.countries,
                            selectedId: widget.viewModel.selectedCountryId,
                            onTap: (entity) {
                              widget.viewModel.selectCountry(entity.entityId);
                            },
                          ),
                          if (widget.viewModel.selectedCountryId != null) ...[
                            const SizedBox(height: 16),
                            _EntitySection(
                              title: LocaleKeys.entity_selector_regions.tr(),
                              entities: widget.viewModel.regions,
                              selectedId: widget.viewModel.selectedRegionId,
                              emptyText: LocaleKeys.entity_selector_regions_empty
                                  .tr(),
                              onTap: (entity) {
                                widget.viewModel.selectRegion(entity.entityId);
                              },
                            ),
                            const SizedBox(height: 16),
                            _EntitySection(
                              title: LocaleKeys.entity_selector_cities.tr(),
                              entities: widget.viewModel.cities,
                              selectedId: widget.viewModel.selectedCityId,
                              emptyText: LocaleKeys.entity_selector_cities_empty
                                  .tr(),
                              onTap: (entity) {
                                widget.viewModel.selectCity(entity.entityId);
                              },
                            ),
                          ],
                          if (widget.viewModel.selectedCityId != null) ...[
                            const SizedBox(height: 16),
                            _EntitySection(
                              title: LocaleKeys.entity_selector_city_centers.tr(),
                              entities: widget.viewModel.cityCenters,
                              selectedId: widget.viewModel.selectedCityCenterId,
                              emptyText: LocaleKeys
                                  .entity_selector_city_centers_empty
                                  .tr(),
                              onTap: (entity) {
                                widget.viewModel.selectCityCenter(entity.entityId);
                              },
                            ),
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
                          onPressed: widget.viewModel.selectedCountryId == null
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

class _EntitySection extends StatelessWidget {
  const _EntitySection({
    required this.title,
    required this.entities,
    required this.selectedId,
    required this.onTap,
    this.emptyText,
  });

  final String title;
  final List<Entity> entities;
  final String? selectedId;
  final String? emptyText;
  final ValueChanged<Entity> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.slate500,
          ),
        ),
        const SizedBox(height: 8),
        if (entities.isEmpty && emptyText != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate100),
            ),
            child: Text(
              emptyText!,
              style: const TextStyle(color: AppColors.slate500),
            ),
          )
        else
          Column(
            children: [
              for (final entity in entities) ...[
                _EntityTile(
                  entity: entity,
                  isSelected: selectedId == entity.entityId,
                  onTap: () => onTap(entity),
                ),
                if (entity != entities.last) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }
}

class _EntityTile extends StatelessWidget {
  const _EntityTile({
    required this.entity,
    required this.isSelected,
    required this.onTap,
  });

  final Entity entity;
  final bool isSelected;
  final VoidCallback onTap;

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
                  color: isSelected ? AppColors.emerald700 : AppColors.indigo600,
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
                const Icon(
                  Icons.check_circle,
                  color: AppColors.emerald600,
                  size: 18,
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
