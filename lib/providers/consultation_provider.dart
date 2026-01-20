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
    String? chiefComplaint,
    String status = 'draft',
  }) async {
    final consultation = Consultation(
      id: const Uuid().v4(),
      patientId: patientId,
      doctorId: doctorId,
      chiefComplaint: chiefComplaint,
      audioDuration: 0,
      createdAt: DateTime.now(),
      status: status,
      isEncrypted: false,
    );
    
    // Save to local database
    final dbService = _ref.read(databaseServiceProvider);
    await dbService.insertConsultation(consultation);

    // Also add to list provider
    _ref.read(consultationsListProvider.notifier).add(consultation);
    
    state = consultation;
    return consultation;
  }

  /// Set the current consultation
  void setConsultation(Consultation c) {
    state = c;
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
    
    // Update in list
    _ref.read(consultationsListProvider.notifier).update(updated);

    state = updated;
    return true;
  }
  
  /// Save current state
  Future<void> save() async {
    if (state != null) {
      final dbService = _ref.read(databaseServiceProvider);
      await dbService.updateConsultation(state!);
      _ref.read(consultationsListProvider.notifier).update(state!);
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
  
  /// Load all consultations and seed mock waiting data if empty
  Future<void> loadAll() async {
    state = const AsyncValue.loading();
    
    try {
      final dbService = _ref.read(databaseServiceProvider);
      var consultations = await dbService.getAllConsultations();
      
      // If no consultations, or none are waiting, seed some waiting ones for the demo
      if (consultations.isEmpty || !consultations.any((c) => c.status == 'waiting')) {
         final mocks = _generateMockWaitingList();
         for (var m in mocks) {
           await dbService.insertConsultation(m);
         }
         consultations = await dbService.getAllConsultations();
      }

      state = AsyncValue.data(consultations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  List<Consultation> _generateMockWaitingList() {
    final now = DateTime.now();
    return [
      Consultation(
        id: const Uuid().v4(),
        patientId: 'David Carter',
        doctorId: 'doctor_001',
        chiefComplaint: 'Severe migraine with aura, sensitivity to light. Recurring episode.',
        consultationType: 'Follow-up',
        audioDuration: 0,
        createdAt: now.add(const Duration(minutes: 15)),
        status: 'waiting',
        isEncrypted: false,
      ),
      Consultation(
        id: const Uuid().v4(),
        patientId: 'Emma Thompson',
        doctorId: 'doctor_001',
        chiefComplaint: 'BP Review. Recent readings high in mornings.',
        consultationType: 'Follow-up',
        audioDuration: 0,
        createdAt: now.add(const Duration(minutes: 45)),
        status: 'waiting',
        isEncrypted: false,
      ),
      Consultation(
        id: const Uuid().v4(),
        patientId: 'Michael Rodriguez',
        doctorId: 'doctor_001',
        chiefComplaint: 'Left knee pain after falling during soccer practice.',
        consultationType: 'New Assessment',
        audioDuration: 0,
        createdAt: now.add(const Duration(hours: 1, minutes: 15)),
        status: 'waiting',
        isEncrypted: false,
      ),
      Consultation(
        id: const Uuid().v4(),
        patientId: 'Sarah Conner',
        doctorId: 'doctor_001',
        chiefComplaint: 'Persistent dry cough and fever for 3 days.',
        consultationType: 'Urgent Care',
        audioDuration: 0,
        createdAt: now.add(const Duration(hours: 2)),
        status: 'waiting',
        isEncrypted: false,
      ),
    ];
  }

  /// Refresh list
  Future<void> refresh() async {
    await loadAll();
  }
  
  /// Add consultation to list
  void add(Consultation consultation) {
    state.whenData((list) {
      if (!list.any((element) => element.id == consultation.id)) {
        state = AsyncValue.data([consultation, ...list]);
      }
    });
  }
  
  /// Update consultation in list
  void update(Consultation consultation) {
    state.whenData((list) {
      final index = list.indexWhere((c) => c.id == consultation.id);
      if (index != -1) {
        final newList = List<Consultation>.from(list);
        newList[index] = consultation;
        state = AsyncValue.data(newList);
      } else {
        add(consultation);
      }
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
}

/// Consultation status provider
final consultationStatusProvider = Provider.family<String, String>((ref, id) {
  final consultations = ref.watch(consultationsListProvider);
  return consultations.valueOrNull?.firstWhere((c) => c.id == id).status ?? 'unknown';
});
