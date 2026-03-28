import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:explored/features/exploration/data/repositories/entity_repository.dart';
import 'package:explored/features/exploration/data/repositories/pack_management_repository.dart';
import 'package:explored/features/exploration/data/repositories/progress_repository.dart';
import 'package:explored/features/exploration/data/repositories/selection_repository.dart';
import 'package:explored/features/exploration/data/repositories/totals_repository.dart';
import 'package:explored/features/exploration/data/services/bundled_pack_asset_service.dart';
import 'package:explored/features/exploration/data/services/exploration_database.dart';
import 'package:explored/features/exploration/data/services/legacy_selection_service.dart';
import 'package:explored/features/exploration/data/services/local_user_prefs_service.dart';
import 'package:explored/features/exploration/data/services/pack_import_service.dart';
import 'package:explored/features/progress_home/view_model/progress_view_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('real bundled region packs', () {
    test(
      'progress view model loads real bundled data without empty state',
      () async {
        final context = await _buildRuntimeContext();
        addTearDown(context.dispose);

        final viewModel = ProgressViewModel(
          entityRepository: context.entityRepository,
          progressRepository: context.progressRepository,
          selectionRepository: context.selectionRepository,
        );

        await viewModel.refresh();

        expect(viewModel.error, isNull);
        expect(viewModel.selectedProgress, isNotNull);
        expect(viewModel.selectedEntity?.name, isNotEmpty);
        expect(viewModel.children, isNotEmpty);
        expect(
          await context.selectionRepository.getSelectedCountrySlug(),
          isNotNull,
        );
      },
    );

    test(
      'switching countries keeps only one static country pack loaded',
      () async {
        final context = await _buildRuntimeContext();
        addTearDown(context.dispose);

        await context.packManagementRepository.importCountryPack('albania');
        var loadedCountries = await context.database.explorationDao
            .fetchCountries();
        expect(loadedCountries, hasLength(1));
        expect(loadedCountries.single.countrySlug, 'albania');

        await context.selectionRepository.setSelectedEntityId(
          loadedCountries.single.entityId,
        );
        await context.packManagementRepository.importCountryPack('croatia');

        loadedCountries = await context.database.explorationDao
            .fetchCountries();
        expect(loadedCountries, hasLength(1));
        expect(loadedCountries.single.countrySlug, 'croatia');

        await context.selectionRepository.setSelectedEntityId(
          loadedCountries.single.entityId,
        );
        expect(
          await context.selectionRepository.getSelectedCountrySlug(),
          'croatia',
        );
      },
    );
  });
}

Future<_RuntimeContext> _buildRuntimeContext() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final preferences = await SharedPreferences.getInstance();
  final database = ExplorationDatabase(executor: NativeDatabase.memory());
  final localUserPrefsService = LocalUserPrefsService(preferences: preferences);
  final assetService = BundleBundledPackAssetService();
  final packImportService = PackImportService(
    assetService: assetService,
    explorationDao: database.explorationDao,
  );
  final entityRepository = DefaultEntityRepository(
    packImportService: packImportService,
    explorationDao: database.explorationDao,
  );
  final selectionRepository = DefaultSelectionRepository(
    explorationDao: database.explorationDao,
    entityRepository: entityRepository,
    localUserPrefsService: localUserPrefsService,
  );
  final totalsRepository = DefaultTotalsRepository(
    explorationDao: database.explorationDao,
  );
  final progressRepository = DefaultProgressRepository(
    entityRepository: entityRepository,
    totalsRepository: totalsRepository,
    explorationDao: database.explorationDao,
    localUserPrefsService: localUserPrefsService,
  );
  final packManagementRepository = DefaultPackManagementRepository(
    packImportService: packImportService,
    explorationDao: database.explorationDao,
    legacySelectionService: LegacySelectionService(preferences: preferences),
    localUserPrefsService: localUserPrefsService,
  );

  await packManagementRepository.bootstrapBundledCountryPacks();

  return _RuntimeContext(
    database: database,
    entityRepository: entityRepository,
    selectionRepository: selectionRepository,
    progressRepository: progressRepository,
    packManagementRepository: packManagementRepository,
  );
}

class _RuntimeContext {
  const _RuntimeContext({
    required this.database,
    required this.entityRepository,
    required this.selectionRepository,
    required this.progressRepository,
    required this.packManagementRepository,
  });

  final ExplorationDatabase database;
  final EntityRepository entityRepository;
  final SelectionRepository selectionRepository;
  final ProgressRepository progressRepository;
  final PackManagementRepository packManagementRepository;

  Future<void> dispose() {
    return database.close();
  }
}
