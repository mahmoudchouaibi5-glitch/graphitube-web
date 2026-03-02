import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for salon types
enum SalonType { lShape, uShape, rectOpen1, rectOpen2, custom }

// 1. State Model
class SalonOrderState {
  final SalonType? selectedSalonType;

  SalonOrderState({this.selectedSalonType});

  SalonOrderState copyWith({SalonType? salonType}) {
    return SalonOrderState(selectedSalonType: salonType ?? this.selectedSalonType);
  }
}

// 2. State Notifier
class SalonOrderNotifier extends StateNotifier<SalonOrderState> {
  SalonOrderNotifier() : super(SalonOrderState());

  void setSalonType(SalonType type) {
    state = state.copyWith(salonType: type);
  }
}

// 3. Provider
final salonOrderProvider = StateNotifierProvider<SalonOrderNotifier, SalonOrderState>((ref) {
  return SalonOrderNotifier();
});
