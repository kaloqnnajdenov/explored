import 'explored_area_filter.dart';

class ExploredAreaViewState {
  const ExploredAreaViewState({
    required this.areaKm2,
    required this.filter,
    required this.isLoading,
    this.error,
  });

  factory ExploredAreaViewState.initial() {
    return ExploredAreaViewState(
      areaKm2: 0,
      filter: ExploredAreaFilter.allTime(),
      isLoading: true,
    );
  }

  final double areaKm2;
  final ExploredAreaFilter filter;
  final bool isLoading;
  final Object? error;

  ExploredAreaViewState copyWith({
    double? areaKm2,
    ExploredAreaFilter? filter,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return ExploredAreaViewState(
      areaKm2: areaKm2 ?? this.areaKm2,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
