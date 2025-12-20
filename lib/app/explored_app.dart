import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/map/view/map_view.dart';
import '../features/map/view_model/map_view_model.dart';

/// Root app wiring dependencies and theming; hosts the map as the entry screen.
class ExploredApp extends StatelessWidget {
  const ExploredApp({
    required this.mapViewModel,
    required this.appTitle,
    super.key,
  });

  final MapViewModel mapViewModel;
  final String appTitle;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapViewModel>.value(value: mapViewModel),
      ],
      child: MaterialApp(
        title: appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
          useMaterial3: true,
        ),
        home: MapView(viewModel: mapViewModel),
      ),
    );
  }
}
