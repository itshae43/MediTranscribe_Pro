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
      
      // FOR DEMO: Delete entire database and reseed with fresh data
      await dbService.deleteDatabase();
      
      // After delete, the database will be recreated on first access
      // Seed fresh mock data (5 waiting + 5 completed)
      final mocks = _generateMockWaitingList();
      for (var m in mocks) {
        await dbService.insertConsultation(m);
      }
      
      final consultations = await dbService.getAllConsultations();

      state = AsyncValue.data(consultations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  List<Consultation> _generateMockWaitingList() {
    final now = DateTime.now();
    return [
      // ===== 5 WAITING PATIENTS =====
      Consultation(
        id: const Uuid().v4(),
        patientId: 'Mr. Johnson',
        doctorId: 'doctor_001',
        chiefComplaint: 'Pain in his chest and shortness of breath',
        consultationType: 'Urgent Care',
        audioDuration: 0,
        createdAt: now.add(const Duration(minutes: 5)),
        status: 'waiting',
        isEncrypted: false,
      ),
      Consultation(
        id: const Uuid().v4(),
        patientId: 'Sarah Williams',
        doctorId: 'doctor_001',
        chiefComplaint: 'Persistent dry cough and fever for 3 days. Sore throat and body aches.',
        consultationType: 'New Assessment',
        audioDuration: 0,
        createdAt: now.add(const Duration(minutes: 20)),
        status: 'waiting',
        isEncrypted: false,
      ),
      Consultation(
        id: const Uuid().v4(),
        patientId: 'Michael Rodriguez',
        doctorId: 'doctor_001',
        chiefComplaint: 'Left knee pain after falling during soccer practice. Swelling observed.',
        consultationType: 'New Assessment',
        audioDuration: 0,
        createdAt: now.add(const Duration(minutes: 35)),
        status: 'waiting',
        isEncrypted: false,
      ),
      Consultation(
        id: const Uuid().v4(),
        patientId: 'Emma Thompson',
        doctorId: 'doctor_001',
        chiefComplaint: 'Blood pressure follow-up. Recent readings high in mornings (150/95).',
        consultationType: 'Follow-up',
        audioDuration: 0,
        createdAt: now.add(const Duration(minutes: 50)),
        status: 'waiting',
        isEncrypted: false,
      ),
      Consultation(
        id: const Uuid().v4(),
        patientId: 'David Carter',
        doctorId: 'doctor_001',
        chiefComplaint: 'Severe migraine with aura, sensitivity to light. Recurring for 2 weeks.',
        consultationType: 'Follow-up',
        audioDuration: 0,
        createdAt: now.add(const Duration(hours: 1)),
        status: 'waiting',
        isEncrypted: false,
      ),
      
      // ===== 5 COMPLETED PATIENTS WITH FULL TRANSCRIPTS =====
      Consultation(
        id: 'completed_001',
        patientId: 'Jennifer Martinez',
        doctorId: 'doctor_001',
        chiefComplaint: 'Annual physical examination and blood work review',
        consultationType: 'General Checkup',
        audioDuration: 312, // 5m 12s
        createdAt: now.subtract(const Duration(hours: 2)),
        status: 'finalized',
        isEncrypted: true,
        transcript: '''[DOCTOR] Good morning Jennifer, how are you feeling today?
[PATIENT] Good morning Doctor. I'm feeling well overall, just here for my annual checkup.
[DOCTOR] That's great to hear. I've reviewed your blood work results from last week. Let me go through them with you.
[PATIENT] Sure, I've been a bit anxious about those results.
[DOCTOR] No need to worry. Your cholesterol levels have improved significantly since last year. Your LDL is now at 110, down from 145.
[PATIENT] Oh that's wonderful news! I've been trying to eat healthier and exercise more.
[DOCTOR] It's clearly working. Your HDL is also in a good range at 55. Blood sugar levels are normal at 95 mg/dL.
[PATIENT] I was worried about diabetes since it runs in my family.
[DOCTOR] Your levels are well within normal range. However, given your family history, we should continue monitoring annually.
[PATIENT] That makes sense. What about my blood pressure?
[DOCTOR] Your blood pressure today is 120 over 78, which is excellent. Heart rate is 72 beats per minute.
[PATIENT] That's a relief. I've been doing cardio three times a week.
[DOCTOR] Keep up the good work. Your weight is stable at 145 pounds, and your BMI is 23, which is healthy.
[PATIENT] Thank you Doctor. Is there anything else I should be doing?
[DOCTOR] I'd recommend continuing your current lifestyle. Maybe add some vitamin D supplementation since your levels are slightly low.
[PATIENT] How much vitamin D should I take?
[DOCTOR] I'd suggest 2000 IU daily. You can get it over the counter. Also, make sure you're getting enough calcium for bone health.
[PATIENT] I'll pick some up today. Should I come back for another checkup soon?
[DOCTOR] Let's schedule your next annual physical for the same time next year. If you notice any concerning symptoms before then, don't hesitate to call.
[PATIENT] Thank you so much Doctor. I appreciate the thorough review.
[DOCTOR] You're welcome Jennifer. Take care and keep up the healthy habits!''',
        clinicalNotes: {
          'diagnoses': ['Healthy adult', 'Low Vitamin D'],
          'medications': ['Vitamin D3 2000 IU daily', 'Calcium 500mg daily'],
          'followUp': 'Annual physical in 12 months',
        },
      ),
      Consultation(
        id: 'completed_002',
        patientId: 'Robert Chen',
        doctorId: 'doctor_001',
        chiefComplaint: 'Chronic lower back pain for 6 weeks, worsening with sitting',
        consultationType: 'Follow-up',
        audioDuration: 285, // 4m 45s
        createdAt: now.subtract(const Duration(hours: 4)),
        status: 'finalized',
        isEncrypted: true,
        transcript: '''[DOCTOR] Hello Robert, I see you're back for your lower back pain follow-up. How has it been since our last visit?
[PATIENT] Hi Doctor. The pain is still there, especially when I sit for long periods at work. It's gotten a bit worse actually.
[DOCTOR] I'm sorry to hear that. On a scale of 1 to 10, how would you rate the pain now?
[PATIENT] I'd say about a 6 or 7. Sometimes it shoots down my left leg too.
[DOCTOR] That radiating pain is concerning. It could indicate some nerve involvement. Let me examine you.
[PATIENT] Sure Doctor. It really bothers me during work meetings.
[DOCTOR] I can feel some muscle tension in your lower lumbar region. Can you bend forward for me?
[PATIENT] It hurts when I do that. There's a pulling sensation.
[DOCTOR] Based on my examination and your symptoms, I'd like to order an MRI of your lumbar spine to rule out any disc issues.
[PATIENT] Do you think it could be a herniated disc?
[DOCTOR] It's possible. The radiating pain down your leg suggests possible nerve compression. The MRI will give us a clearer picture.
[PATIENT] That sounds serious. What can I do in the meantime?
[DOCTOR] I'll prescribe a muscle relaxant to help with the tension, and continue with the anti-inflammatory medication.
[PATIENT] Should I still do the stretches you recommended last time?
[DOCTOR] Yes, gentle stretching is good, but avoid any exercises that increase your pain. I'm also going to refer you to physical therapy.
[PATIENT] How often would I need to go to physical therapy?
[DOCTOR] Typically two to three times per week for about four to six weeks. The therapist will teach you exercises to strengthen your core.
[PATIENT] Okay Doctor, I'll make sure to follow through with everything.
[DOCTOR] Great. Let's schedule the MRI for this week and I'll see you back in two weeks to review the results.''',
        clinicalNotes: {
          'diagnoses': ['Lumbar radiculopathy', 'Suspected disc herniation L4-L5'],
          'medications': ['Cyclobenzaprine 10mg', 'Ibuprofen 600mg TID'],
          'followUp': 'MRI lumbar spine, Physical therapy referral, Follow-up in 2 weeks',
        },
      ),
      Consultation(
        id: 'completed_003',
        patientId: 'Lisa Anderson',
        doctorId: 'doctor_001',
        chiefComplaint: 'Anxiety and difficulty sleeping for the past month',
        consultationType: 'New Assessment',
        audioDuration: 340, // 5m 40s
        createdAt: now.subtract(const Duration(hours: 6)),
        status: 'finalized',
        isEncrypted: true,
        transcript: '''[DOCTOR] Good afternoon Lisa. What brings you in today?
[PATIENT] Hi Doctor. I've been really struggling with anxiety and I can't sleep properly for the past month.
[DOCTOR] I'm sorry to hear that. Can you tell me more about what you're experiencing?
[PATIENT] I constantly feel worried and on edge. My heart races sometimes and I have trouble concentrating at work.
[DOCTOR] How has this affected your sleep specifically?
[PATIENT] I lie awake for hours thinking about things. Even when I fall asleep, I wake up multiple times during the night.
[DOCTOR] On average, how many hours of sleep are you getting per night?
[PATIENT] Maybe 4 or 5 hours on a good night. Sometimes less.
[DOCTOR] That's significantly less than the recommended 7 to 8 hours. Has anything changed in your life recently that might have triggered this?
[PATIENT] Work has been extremely stressful. We had layoffs and I've been worried about my job security.
[DOCTOR] Work stress is a very common trigger for anxiety. Have you noticed any physical symptoms like headaches or stomach issues?
[PATIENT] Yes, I've been getting tension headaches almost daily and my appetite has decreased.
[DOCTOR] Thank you for sharing that. Have you experienced anxiety like this before?
[PATIENT] Not to this extent. I've always been a bit of a worrier but this feels different.
[DOCTOR] I understand. Based on what you're describing, it sounds like you're experiencing generalized anxiety disorder. This is very treatable.
[PATIENT] What kind of treatment would you recommend?
[DOCTOR] I'd like to start with a combination approach. First, I'll prescribe a low-dose SSRI medication which helps with both anxiety and sleep.
[PATIENT] Are there any side effects I should know about?
[DOCTOR] Some people experience mild nausea or headaches initially, but these usually resolve within a week or two.
[DOCTOR] I'd also recommend seeing a therapist for cognitive behavioral therapy. It's very effective for anxiety.
[PATIENT] I've heard about that. I'm willing to try therapy.
[DOCTOR] Great. I also want you to practice good sleep hygiene - no screens before bed, keep a regular sleep schedule, and avoid caffeine after noon.
[PATIENT] I do drink a lot of coffee. I'll try to cut back.
[DOCTOR] That will help. Let's schedule a follow-up in four weeks to see how you're responding to the medication.''',
        clinicalNotes: {
          'diagnoses': ['Generalized Anxiety Disorder (F41.1)', 'Insomnia secondary to anxiety'],
          'medications': ['Sertraline 25mg daily, increase to 50mg after 1 week'],
          'followUp': 'Referral to therapist for CBT, Follow-up in 4 weeks',
        },
      ),
      Consultation(
        id: 'completed_004',
        patientId: 'James Wilson',
        doctorId: 'doctor_001',
        chiefComplaint: 'Diabetes management and medication adjustment',
        consultationType: 'Follow-up',
        audioDuration: 298, // 4m 58s
        createdAt: now.subtract(const Duration(hours: 8)),
        status: 'finalized',
        isEncrypted: true,
        transcript: '''[DOCTOR] Hello James, good to see you again. Let's review your diabetes management today.
[PATIENT] Hi Doctor. I've been checking my blood sugar regularly like you asked.
[DOCTOR] Excellent. What have your readings been like?
[PATIENT] My fasting glucose has been between 140 and 160. After meals it sometimes goes up to 200.
[DOCTOR] Those numbers are still a bit high. We should aim for fasting glucose under 130 and post-meal under 180.
[PATIENT] I was afraid of that. I've been trying to watch my carbs.
[DOCTOR] Let me check your HbA1c from last week. It's at 7.8%, which is slightly above our target of 7%.
[PATIENT] What does that mean exactly?
[DOCTOR] HbA1c gives us a picture of your average blood sugar over the past three months. 7.8% means we need to make some adjustments.
[PATIENT] Do I need more medication?
[DOCTOR] I'd like to increase your Metformin dose from 500mg to 850mg twice daily. This should help with fasting numbers.
[PATIENT] Will that cause any stomach issues?
[DOCTOR] It might initially. Make sure to take it with meals to minimize any digestive discomfort.
[DOCTOR] I also want to add a medication called Empagliflozin. It works differently and helps protect your kidneys as well.
[PATIENT] How does that one work?
[DOCTOR] It helps your kidneys excrete excess glucose through urine. You might notice you urinate more frequently initially.
[PATIENT] Okay, I can manage that. What about my diet?
[DOCTOR] I'd recommend reducing portion sizes at dinner and avoiding white rice and bread. Choose whole grains instead.
[PATIENT] My wife has been cooking more vegetables lately.
[DOCTOR] That's wonderful. Also try to walk for 30 minutes after your largest meal. It really helps with blood sugar control.
[PATIENT] I can do that. The weather has been nice for walking.
[DOCTOR] Perfect. I want to see you back in 6 weeks to recheck your HbA1c and see how you're doing on the new regimen.
[PATIENT] Thank you Doctor. I'll work harder on my diet and exercise.
[DOCTOR] You're doing well James. Small consistent changes make a big difference over time.''',
        clinicalNotes: {
          'diagnoses': ['Type 2 Diabetes Mellitus - suboptimally controlled', 'HbA1c 7.8%'],
          'medications': ['Metformin 850mg BID', 'Empagliflozin 10mg daily'],
          'followUp': 'Repeat HbA1c in 6 weeks, Nutrition counseling recommended',
        },
      ),
      Consultation(
        id: 'completed_005',
        patientId: 'Patricia Brown',
        doctorId: 'doctor_001',
        chiefComplaint: 'Seasonal allergies and sinus congestion',
        consultationType: 'Follow-up',
        audioDuration: 265, // 4m 25s
        createdAt: now.subtract(const Duration(hours: 10)),
        status: 'finalized',
        isEncrypted: true,
        transcript: '''[DOCTOR] Good morning Patricia. How are your allergies treating you this season?
[PATIENT] Good morning Doctor. They're terrible this year. My nose is constantly stuffed and my eyes are so itchy.
[DOCTOR] Allergy season has been particularly bad this spring. When did your symptoms start?
[PATIENT] About three weeks ago when all the trees started blooming. I've been miserable ever since.
[DOCTOR] What have you been taking to manage the symptoms?
[PATIENT] Over-the-counter Claritin, but it doesn't seem to be helping much anymore.
[DOCTOR] Loratadine can lose effectiveness over time. Let's try a different antihistamine.
[PATIENT] I've also been using nasal spray but it only helps for a few hours.
[DOCTOR] Which nasal spray have you been using?
[PATIENT] The decongestant one from the pharmacy. Afrin I think.
[DOCTOR] Ah, you need to be careful with Afrin. Using it for more than 3 days can cause rebound congestion and make things worse.
[PATIENT] Oh no, I've been using it for two weeks!
[DOCTOR] That explains why your congestion has been so persistent. We need to transition you off of it.
[PATIENT] How do I do that?
[DOCTOR] I'm going to prescribe Flonase, which is a corticosteroid nasal spray. It takes a few days to work but is much safer for long-term use.
[PATIENT] Should I stop the Afrin right away?
[DOCTOR] Yes, stop it today. You may have increased congestion for a few days, but the Flonase will help.
[DOCTOR] I'm also switching your antihistamine to Cetirizine, which may work better for you.
[PATIENT] What about my itchy eyes?
[DOCTOR] I'll prescribe antihistamine eye drops as well. Use them twice daily.
[PATIENT] Thank you Doctor. Is there anything else I can do at home?
[DOCTOR] Yes, shower before bed to rinse pollen from your hair. Keep windows closed and use air conditioning.
[PATIENT] Good tips. I've been sleeping with windows open.
[DOCTOR] That would definitely worsen your symptoms. Also consider getting a HEPA air purifier for your bedroom.
[PATIENT] I'll look into that. Thank you so much Doctor!
[DOCTOR] You're welcome Patricia. Follow up in two weeks if symptoms don't improve.''',
        clinicalNotes: {
          'diagnoses': ['Seasonal Allergic Rhinitis', 'Rhinitis Medicamentosa from Afrin overuse'],
          'medications': ['Fluticasone nasal spray 2 sprays daily', 'Cetirizine 10mg daily', 'Ketotifen eye drops BID'],
          'followUp': 'Follow-up in 2 weeks if no improvement',
        },
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
