import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/consultation_provider.dart';
import '../models/consultation.dart';
import 'recording_screen.dart';
import 'archive_screen.dart';
import 'settings_screen.dart';
import 'notes_screen.dart';
import '../providers/transcript_provider.dart';

/// Home Screen
/// Main dashboard showing waiting patients and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultationsAsync = ref.watch(consultationsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
             await ref.read(consultationsListProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Header
                _buildHeader(context),
                
                const SizedBox(height: 24),
                
                // Start New Consultation Card
                _buildStartConsultationCard(context, ref)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Consulting Queue / Waiting List
                _buildWaitingConsultationsSection(context, ref, consultationsAsync)
                   .animate()
                   .fadeIn(delay: 200.ms, duration: 400.ms)
                   .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),
                
                // Recent / Processed Consultations
                _buildRecentConsultationsSection(context, consultationsAsync)
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Morning,',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Dr. Sarah Mitchell',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
          icon: const Icon(Icons.settings, color: Colors.grey),
        ),
      ],
    );
  }

  // --- 1. Start Consultation Action ---
  Widget _buildStartConsultationCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showPatientSelectionSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981), // Emerald Green
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start New Consultation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to select a patient from the queue',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Waiting List Section ---
  Widget _buildWaitingConsultationsSection(
    BuildContext context, 
    WidgetRef ref,
    AsyncValue<List<Consultation>> consultationsAsync
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                children: [
                  TextSpan(text: 'Waiting '),
                  TextSpan(text: 'Queue', style: TextStyle(color: Color(0xFF3B82F6))), // Blue highlight
                ],
              ),
            ),
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
               decoration: BoxDecoration(
                 color: Colors.blue.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(12),
               ),
               child: const Text('Next Up', style: TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        consultationsAsync.when(
          data: (consultations) {
            final waiting = consultations.where((c) => c.status == 'waiting').toList();
            
            if (waiting.isEmpty) {
              return _buildEmptyState('No patients waiting.');
            }
            
            return SizedBox(
              height: 140, // Height for horizontal cards
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: waiting.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _buildWaitingCard(context, ref, waiting[index]);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildWaitingCard(BuildContext context, WidgetRef ref, Consultation consultation) {
    // Show time as "10:30 AM" or similar based on created/scheduled time
    final timeStr = DateFormat('jm').format(consultation.createdAt);

    return InkWell(
      onTap: () => _showPatientDetailsStatus(context, ref, consultation),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.withOpacity(0.1)),
          boxShadow: [
             BoxShadow(
               color: Colors.blue.withOpacity(0.05),
               blurRadius: 10,
               offset: const Offset(0, 4),
             ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                   decoration: BoxDecoration(
                     color: Colors.grey.shade100,
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(timeStr, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                   consultation.patientId,
                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                   maxLines: 1, 
                   overflow: TextOverflow.ellipsis
                 ),
                 const SizedBox(height: 4),
                 Text(
                   consultation.chiefComplaint ?? 'No details provided',
                   style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                   maxLines: 2,
                   overflow: TextOverflow.ellipsis,
                 ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. Recent Section ---
  Widget _buildRecentConsultationsSection(
    BuildContext context,
    AsyncValue<List<Consultation>> consultationsAsync,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Consultations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ArchiveScreen()),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        consultationsAsync.when(
          data: (consultations) {
            // Filter out 'waiting' status, we only want processed/drafts here
            final recent = consultations
                .where((c) => c.status != 'waiting')
                .take(5)
                .toList();

            if (recent.isEmpty) {
              return _buildEmptyState('No completed consultations yet.');
            }
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildConsultationItem(context, recent[index], index);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState(String msg) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)
        ),
        child: Center(child: Text(msg, style: TextStyle(color: Colors.grey.shade400)))
    );
  }

  Widget _buildConsultationItem(BuildContext context, Consultation consultation, int index) {
    final statusText = consultation.status == 'finalized' ? 'Processed' : 'Draft';
    final statusColor = consultation.status == 'finalized' ? const Color(0xFF10B981) : const Color(0xFFFBBF24);
    
    // Format display time
    final displayTime = _getFriendlyTime(consultation.createdAt);

    return InkWell(
      onTap: () {
         // Open Notes for this consultation
         Navigator.push(
           context,
           MaterialPageRoute(builder: (_) => NotesScreen(consultationId: consultation.id)),
         );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined, color: Colors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consultation.patientId, // Patient Name
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text('•', style: TextStyle(color: Colors.grey[400])),
                      ),
                      Expanded(
                        child: Text(
                          consultation.chiefComplaint ?? 'Consultation Notes',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayTime,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---
  String _getFriendlyTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (date == today) {
      return DateFormat('hh:mm a').format(dateTime);
    } else if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  // --- Logic: Show Patient Selection ---
  void _showPatientSelectionSheet(BuildContext context, WidgetRef ref) {
      final consultationsAsync = ref.read(consultationsListProvider);
      
      consultationsAsync.whenData((consultations) {
          final waiting = consultations.where((c) => c.status == 'waiting').toList();
          
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) => Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          const Text('Select Patient', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (waiting.isEmpty)
                             const Padding(
                               padding: EdgeInsets.symmetric(vertical: 20),
                               child: Text('No waiting patients. You can start a new unassigned consultation.'),
                             ),
                          ...waiting.map((c) => ListTile(
                              leading: const CircleAvatar(backgroundColor: Color(0xFFE0E7FF), child: Icon(Icons.person, color: Color(0xFF3949AB))),
                              title: Text(c.patientId, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(c.chiefComplaint ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                  Navigator.pop(ctx);
                                  _startRecordingForPatient(context, ref, c);
                              },
                          )),
                          const Divider(height: 32),
                          SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                  onPressed: () {
                                      Navigator.pop(ctx);
                                      _startRecordingForPatient(context, ref, null); // Manual entry
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade100,
                                      foregroundColor: Colors.black87,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text('New Walk-in Patient'),
                              ),
                          ),
                      ],
                  ),
              )
          );
      });
  }

  // --- Logic: Show Details for Waiting List Item ---
  void _showPatientDetailsStatus(BuildContext context, WidgetRef ref, Consultation c) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                   CircleAvatar(
                     backgroundColor: Colors.blue.shade50,
                     child: Text(c.patientId[0], style: TextStyle(color: Colors.blue.shade700)),
                   ),
                   const SizedBox(width: 12),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(c.patientId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                         Text(c.consultationType?.toUpperCase() ?? 'GENERAL', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, letterSpacing: 1)),
                       ],
                     ),
                   ),
                ],
              ),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      _detailRow('Status', 'Waiting In Queue', color: Colors.orange.shade700),
                      const SizedBox(height: 12),
                      _detailRow('Type', c.consultationType ?? 'Follow-up'),
                      const SizedBox(height: 12),
                      const Text('Chief Complaint:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(c.chiefComplaint ?? 'No details provided', style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(height: 12),
                      _detailRow('Scheduled', DateFormat('jm').format(c.createdAt)),
                  ],
              ),
              actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx), 
                    child: const Text('Close', style: TextStyle(color: Colors.grey))
                  ),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                          Navigator.pop(ctx);
                          // Trigger navigation after dialog closes
                          _startRecordingForPatient(context, ref, c);
                      }, 
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Call Patient')
                  ),
              ],
          )
      );
  }

  Widget _detailRow(String label, String value, {Color? color}) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              SizedBox(
                width: 80,
                child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
              ),
              Expanded(
                child: Text(
                  value, 
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    color: color ?? Colors.black87
                  )
                ),
              ),
          ],
      );
  }

  Future<void> _startRecordingForPatient(BuildContext context, WidgetRef ref, Consultation? existing) async {
    // Clear previous transcript
    ref.read(transcriptStateProvider.notifier).clear();

    Consultation activeConsultation;

    if (existing != null) {
        // Use the existing waiting consultation
        // Update its status to 'draft' or 'in-progress' logic if we had it
        // Ideally we keep ID but maybe update "createdAt" to actual start time or separate 'startedAt'
        activeConsultation = existing; // For now just invoke it
        ref.read(currentConsultationProvider.notifier).setConsultation(existing);
    } else {
        // Create completely new
        activeConsultation = await ref.read(currentConsultationProvider.notifier).createNew(
          patientId: 'Walk-in ${DateFormat('Hm').format(DateTime.now())}',
          doctorId: 'doctor_001',
          status: 'draft',
        );
    }
    
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecordingScreen(consultationId: activeConsultation.id),
        ),
      );
    }
  }
}
