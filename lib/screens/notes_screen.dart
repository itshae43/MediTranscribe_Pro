import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/consultation_provider.dart';
import '../models/clinical_note.dart';

/// Notes Screen
/// Displays auto-generated clinical notes from transcription

class NotesScreen extends ConsumerWidget {
  final String consultationId;

  const NotesScreen({
    super.key,
    required this.consultationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultation = ref.watch(currentConsultationProvider);

    // Mock clinical notes (in production, these come from backend)
    final mockNote = ClinicalNote(
      consultationId: consultationId,
      chiefComplaint: 'Patient presents with persistent headaches for the past 2 weeks, accompanied by mild dizziness.',
      historyOfPresentIllness: 'The patient reports experiencing daily headaches, particularly in the morning. Pain is described as throbbing, rated 6/10 in intensity. No recent head trauma. Patient has been taking over-the-counter pain relievers with partial relief.',
      diagnoses: [
        'Tension-type headache (G44.2)',
        'Possible hypertension - to be ruled out',
      ],
      medications: [
        'Ibuprofen 400mg - as needed for pain',
        'Consider starting Propranolol 10mg if headaches persist',
      ],
      procedures: [
        'Blood pressure monitoring for 1 week',
        'Complete Blood Count (CBC)',
        'Basic Metabolic Panel',
      ],
      assessment: 'Patient appears well overall. Vital signs within normal limits except for slightly elevated BP (140/90). Neurological examination unremarkable. Most likely tension-type headache with possible contribution from stress and inadequate sleep.',
      followUp: 'Return in 2 weeks for blood pressure review and assessment of headache frequency. If symptoms worsen or new symptoms develop, return sooner.',
      extractedEntities: {
        'symptoms': ['headache', 'dizziness', 'throbbing pain'],
        'vitals': {'bp': '140/90', 'hr': '72'},
        'medications_mentioned': ['ibuprofen', 'propranolol'],
      },
      generatedAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('📋 Clinical Notes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareNotes(context),
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPDF(context),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Banner
            _buildSuccessBanner()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 20),
            
            // Consultation Info Card
            _buildInfoCard(consultation)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            
            const SizedBox(height: 20),
            
            // Chief Complaint
            _buildNoteSection(
              'Chief Complaint',
              mockNote.chiefComplaint,
              Icons.report_problem_outlined,
              Colors.orange,
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
            
            const SizedBox(height: 16),
            
            // History of Present Illness
            _buildNoteSection(
              'History of Present Illness',
              mockNote.historyOfPresentIllness,
              Icons.history,
              Colors.blue,
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            
            const SizedBox(height: 16),
            
            // Diagnoses
            _buildListSection(
              'Diagnoses',
              mockNote.diagnoses,
              Icons.medical_information,
              Colors.purple,
            ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            
            const SizedBox(height: 16),
            
            // Medications
            _buildListSection(
              'Medications',
              mockNote.medications,
              Icons.medication,
              Colors.green,
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            
            const SizedBox(height: 16),
            
            // Procedures/Tests
            _buildListSection(
              'Procedures & Tests',
              mockNote.procedures,
              Icons.science,
              Colors.teal,
            ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
            
            const SizedBox(height: 16),
            
            // Assessment
            _buildNoteSection(
              'Assessment',
              mockNote.assessment,
              Icons.assessment,
              Colors.indigo,
            ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
            
            const SizedBox(height: 16),
            
            // Follow-up
            _buildNoteSection(
              'Follow-up',
              mockNote.followUp,
              Icons.calendar_today,
              Colors.red,
            ).animate().fadeIn(delay: 900.ms, duration: 400.ms),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(context)
                .animate()
                .fadeIn(delay: 1000.ms, duration: 400.ms),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.white, size: 32),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes Generated Successfully!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Clinical notes have been auto-generated from your transcription.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(consultation) {
    final date = consultation?.createdAt ?? DateTime.now();
    final duration = consultation?.audioDuration ?? 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildInfoItem(
              'Date',
              '${date.day}/${date.month}/${date.year}',
              Icons.calendar_today,
            ),
            const SizedBox(width: 24),
            _buildInfoItem(
              'Duration',
              '${duration ~/ 60}m ${duration % 60}s',
              Icons.timer,
            ),
            const SizedBox(width: 24),
            _buildInfoItem(
              'Status',
              'Finalized',
              Icons.check_circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _editNotes(context),
                icon: const Icon(Icons.edit),
                label: const Text('Edit Notes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _exportPDF(context),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Back to Home'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _editNotes(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality coming soon...')),
    );
  }

  void _exportPDF(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating PDF export...')),
    );
  }

  void _shareNotes(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon...')),
    );
  }
}
