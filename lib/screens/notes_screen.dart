import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/consultation_provider.dart';
import '../models/clinical_note.dart';

/// Notes Screen
/// Displays auto-generated clinical notes with a specific card UI design
/// Features:
/// - Colored vertical status bars on cards
/// - Verified Doctor header
/// - Collapsible/Expandable sections
/// - Specific bottom action bar

class NotesScreen extends ConsumerWidget {
  final String consultationId;

  const NotesScreen({
    super.key,
    required this.consultationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app we would use conversationId to fetch data
    // For now we use the active consultation from provider or fallbacks
    final consultation = ref.watch(currentConsultationProvider);
    
    // Mock Data for the design
    // The design shows specific content, so we'll hardcode some defaults 
    // but try to use dynamic data where possible
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // Light background
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Consultation Notes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF5C6BC0)), // Purple/Blue icon
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Doctor Profile Header
            _buildDoctorHeader(consultation),
            
            const SizedBox(height: 24),
            
            // 2. Chief Complaint Card (Red Bar)
            _buildSectionCard(
              title: 'CHIEF COMPLAINT',
              contentWidget: const Text(
                'Patient reports persistent dry cough for 3 weeks and mild shortness of breath.',
                style: TextStyle(fontSize: 15, height: 1.4, color: Colors.black87, fontWeight: FontWeight.w500),
              ),
              barColor: const Color(0xFFFF5252), // Red accent
            ),
            
            const SizedBox(height: 16),
            
            // 3. Diagnoses Card (Orange Bar)
            _buildSectionCard(
              title: 'DIAGNOSES',
              contentWidget: Column(
                children: [
                   _buildDiagnosisItem('Acute Bronchitis (J20.9)', 'Confirmed via physical exam', Icons.medical_services_outlined, Colors.orange),
                   const SizedBox(height: 12),
                   _buildDiagnosisItem('Seasonal Allergies', 'History of recurrence in Fall', Icons.history, Colors.orange),
                ],
              ),
              barColor: Colors.orange, // Orange accent
            ),

            const SizedBox(height: 16),

            // 4. Medications Card (Blue Bar)
            _buildSectionCard(
              title: 'MEDICATIONS',
              contentWidget: Column(
                children: [
                   _buildMedicationItem('Albuterol Inhaler', '90mcg • 2 puffs q4h prn', Icons.medication),
                   const SizedBox(height: 12),
                   _buildMedicationItem('Zyrtec', '10mg • Daily', Icons.medication_liquid),
                ],
              ),
              barColor: Colors.blueAccent, // Blue accent
            ),

            const SizedBox(height: 16),

            // 5. Follow-up Card (Teal Bar)
            _buildSectionCard(
              title: 'FOLLOW-UP',
              contentWidget: Row(
                children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     child: const Icon(Icons.calendar_month, color: Colors.teal),
                   ),
                   const SizedBox(width: 8),
                   const Expanded(
                     child: Text(
                      'Return to clinic in 2 weeks if symptoms do not improve.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.3),
                     ),
                   )
                ],
              ),
              barColor: Colors.teal, // Teal accent
            ),

            const SizedBox(height: 24),

            // 6. Full Transcript Collapsible
            _buildTranscriptCollapse(),

            const SizedBox(height: 24),

            // 7. Bottom Actions
            _buildBottomActions(context),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorHeader(dynamic consultation) {
    // Dates/Times
    final now = DateTime.now();
    final dateStr = DateFormat('MMM dd, yyyy').format(now);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar with verified badge
        Stack(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026702d'), // Male doctor avatar
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, size: 16, color: Colors.green),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        // Name and Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               const Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                    Text(
                      'John Doe*', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    // Finalized badge
                    // We can use a Container instead of built-in Chip to match design perfectly
                 ],
               ),
               const SizedBox(height: 4),
               Row(
                 children: [
                   Text(dateStr, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 6),
                     child: Text('•', style: TextStyle(color: Colors.grey.shade400)),
                   ),
                   Icon(Icons.access_time_filled, size: 14, color: Colors.grey.shade600),
                   const SizedBox(width: 4),
                   Text('2m 14s', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                 ],
               ),
            ],
          ),
        ),
        // Finalized Chip (aligned right)
        Container(
           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
           decoration: BoxDecoration(
             color: Colors.green.shade50,
             borderRadius: BorderRadius.circular(20),
           ),
           child: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               Text('FINALIZED', style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
               const SizedBox(width: 4),
               Icon(Icons.check_circle, size: 12, color: Colors.green.shade700),
             ],
           ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget contentWidget,
    required Color barColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
           BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored Bar
            Container(width: 4, color: barColor),
            
            // Warning/Icon strip logic? The design replaces the bar with the section color
            // Design shows: A thin colored vertical strip on the far left.
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row: Title + Edit
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title, 
                          style: TextStyle(
                             color: Colors.grey.shade600, 
                             fontSize: 11, 
                             fontWeight: FontWeight.bold,
                             letterSpacing: 0.5,
                          )
                        ),
                        Text(
                           'Edit',
                           style: TextStyle(
                             color: const Color(0xFF5C6BC0),
                             fontSize: 12,
                             fontWeight: FontWeight.w600,
                           ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    contentWidget,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisItem(String title, String subtitle, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Icon(icon, color: color, size: 20),
         const SizedBox(width: 12),
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
             ],
           ),
         )
      ],
    );
  }

  Widget _buildMedicationItem(String name, String dosage, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(8),
             decoration: const BoxDecoration(
               color: Color(0xFFE8EAF6), // Light Indigo
               shape: BoxShape.circle,
             ),
             child: const Icon(Icons.medication, color: Color(0xFF3949AB), size: 16),
           ),
           const SizedBox(width: 12),
           Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(dosage, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildTranscriptCollapse() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
         leading: Container(
           padding: const EdgeInsets.all(8),
           decoration: BoxDecoration(
             color: Colors.grey.shade100,
             borderRadius: BorderRadius.circular(8),
           ),
           child: const Icon(Icons.description, color: Colors.grey, size: 20),
         ),
         title: const Text('Full Transcript', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
         subtitle: Text('View source audio text', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
         children: const [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Doctor: How are you feeling today?\nPatient: I have had a dry cough for 3 weeks...\n(Transcript text goes here)',
                style: TextStyle(color: Colors.grey),
              ),
            ),
         ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3949AB), // Dark Blue/Indigo
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Notes', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935), // Red
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('Export PDF', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
               // Navigate back to home
               // Since we are deep in nav likely, we pop to root or specific route
               Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              foregroundColor: const Color(0xFF3949AB),
            ),
            icon: const Icon(Icons.home, size: 20),
            label: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
