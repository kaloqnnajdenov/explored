class ExploredAreaViewState {
  const ExploredAreaViewState({
    required this.totalAreaM2,
    required this.cellCount,
    required this.isLoading,
    this.error,
  });

  factory ExploredAreaViewState.initial() {
    return const ExploredAreaViewState(
      totalAreaM2: 0,
      cellCount: 0,
      isLoading: true,
    );
  }

  final double totalAreaM2;
  final int cellCount;
  final bool isLoading;
  final Object? error;

  ExploredAreaViewState copyWith({
    double? totalAreaM2,
    int? cellCount,
    bool? isLoading,
    Object? error,
    bool clearError = false,
  }) {
    return ExploredAreaViewState(
      totalAreaM2: totalAreaM2 ?? this.totalAreaM2,
      cellCount: cellCount ?? this.cellCount,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
