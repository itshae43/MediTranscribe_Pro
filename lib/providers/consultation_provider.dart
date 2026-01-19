import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/consultation.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import 'package:uuid/uuid.dart';

/// Consultation Provider
/// Manages consultation state using Riverpod

// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Current consultation state
final currentConsultationProvider = StateNotifierProvider<CurrentConsultationNotifier, Consultation?>((ref) {
  return CurrentConsultationNotifier(ref);
});

// All consultations list
final consultationsListProvider = StateNotifierProvider<ConsultationsListNotifier, AsyncValue<List<Consultation>>>((ref) {
  return ConsultationsListNotifier(ref);
});

/// Current Consultation Notifier
class CurrentConsultationNotifier extends StateNotifier<Consultation?> {
  final Ref _ref;
  
  CurrentConsultationNotifier(this._ref) : super(null);
  
  /// Create new consultation
  Future<Consultation> createNew({
    required String patientId,
    required String doctorId,
  }) async {
    final consultation = Consultation(
      id: const Uuid().v4(),
      patientId: patientId,
      doctorId: doctorId,
      audioDuration: 0,
      createdAt: DateTime.now(),
      status: 'draft',
      isEncrypted: false,
    );
    
    // Save to local database
    final dbService = _ref.read(databaseServiceProvider);
    await dbService.insertConsultation(consultation);
    
    state = consultation;
    return consultation;
  }
  
  /// Update transcript
  void updateTranscript(String transcript) {
    if (state != null) {
      state = state!.copyWith(transcript: transcript);
    }
  }
  
  /// Update audio duration
  void updateDuration(int seconds) {
    if (state != null) {
      state = state!.copyWith(audioDuration: seconds);
    }
  }
  
  /// Update clinical notes
  void updateClinicalNotes(Map<String, dynamic> notes) {
    if (state != null) {
      state = state!.copyWith(clinicalNotes: notes);
    }
  }
  
  /// Finalize consultation
  Future<bool> finalize() async {
    if (state == null) return false;
    
    final updated = state!.copyWith(
      status: 'finalized',
      isEncrypted: true,
    );
    
    // Update in database
    final dbService = _ref.read(databaseServiceProvider);
    await dbService.updateConsultation(updated);
    
    state = updated;
    return true;
  }
  
  /// Save current state
  Future<void> save() async {
    if (state != null) {
      final dbService = _ref.read(databaseServiceProvider);
      await dbService.updateConsultation(state!);
    }
  }
  
  /// Load consultation by ID
  Future<void> load(String id) async {
    final dbService = _ref.read(databaseServiceProvider);
    state = await dbService.getConsultation(id);
  }
  
  /// Clear current consultation
  void clear() {
    state = null;
  }
}

/// Consultations List Notifier
class ConsultationsListNotifier extends StateNotifier<AsyncValue<List<Consultation>>> {
  final Ref _ref;
  
  ConsultationsListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadAll();
  }
  
  /// Load all consultations
  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    
    try {
      final dbService = _ref.read(databaseServiceProvider);
      final consultations = await dbService.getAllConsultations();
      state = AsyncValue.data(consultations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  /// Refresh list
  Future<void> refresh() async {
    await loadAll();
  }
  
  /// Add consultation to list
  void add(Consultation consultation) {
    state.whenData((list) {
      state = AsyncValue.data([consultation, ...list]);
    });
  }
  
  /// Remove consultation from list
  Future<void> remove(String id) async {
    final dbService = _ref.read(databaseServiceProvider);
    await dbService.deleteConsultation(id);
    
    state.whenData((list) {
      state = AsyncValue.data(list.where((c) => c.id != id).toList());
    });
  }
  
  /// Get draft consultations
  List<Consultation> getDrafts() {
    return state.valueOrNull?.where((c) => c.status == 'draft').toList() ?? [];
  }
  
  /// Get finalized consultations  
  List<Consultation> getFinalized() {
    return state.valueOrNull?.where((c) => c.status == 'finalized').toList() ?? [];
  }
}

/// Consultation status provider
final consultationStatusProvider = Provider.family<String, String>((ref, id) {
  final consultations = ref.watch(consultationsListProvider);
  return consultations.valueOrNull?.firstWhere((c) => c.id == id).status ?? 'unknown';
});
