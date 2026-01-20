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
import 'compliance_screen.dart';
import '../providers/transcript_provider.dart';

/// Home Screen
/// Main dashboard showing recent consultations and quick actions
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultationsAsync = ref.watch(consultationsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Very light grey background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.read(consultationsListProvider.notifier).refresh();
          },
          child: SingleChildScrollView(
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
                
                const SizedBox(height: 24),
                
                // Stats Row
                _buildStatsRow(consultationsAsync)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0),
                
                const SizedBox(height: 32),
                
                // Recent Consultations
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
        // Add settings icon to allow navigation to settings even without AppBar
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

  Widget _buildStartConsultationCard(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _startNewRecording(context, ref),
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
                    'Tap to begin dictation',
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

  Widget _buildStatsRow(AsyncValue<List<Consultation>> consultationsAsync) {
    return consultationsAsync.when(
      data: (consultations) {
        final completed = consultations.length;
        // Mock accuracy and safe status for design matching since we don't have real metrics yet
        
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                value: '$completed',
                label: 'DONE',
                valueColor: const Color(0xFF3B82F6), // Blue
                icon: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                value: '98%',
                label: 'ACC.',
                valueColor: Color(0xFF10B981), // Green
                icon: null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                value: '',
                label: 'SAFE',
                valueColor: Color(0xFF1F2937), // Dark
                icon: Icons.lock,
                iconColor: Color(0xFF3B82F6),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error'),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color valueColor,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon, color: iconColor, size: 28)
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF), // Grey
            ),
          ),
        ],
      ),
    );
  }

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
            if (consultations.isEmpty) {
              return _buildEmptyState();
            }
            // Take top 5 for "Recent"
            final recent = consultations.take(5).toList();
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final consultation = recent[index];
                return _buildConsultationItem(consultation, index);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)
        ),
        child: const Center(child: Text("No recent consultations"))
    );
  }

  Widget _buildConsultationItem(Consultation consultation, int index) {
    // Map status to design terms
    final statusText = consultation.status == 'finalized' ? 'Processed' : 'Processing';
    final statusColor = consultation.status == 'finalized' ? const Color(0xFF10B981) : const Color(0xFFFBBF24);
    
    // Choose icon and background based on index/type to create variety like the design
    final icons = [Icons.favorite, Icons.medical_services, Icons.assignment, Icons.person];
    final iconColors = [const Color(0xFF3B82F6), const Color(0xFFF59E0B), const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
    final bgColors = [const Color(0xFFEFF6FF), const Color(0xFFFFFBEB), const Color(0xFFF5F3FF), const Color(0xFFFDF2F8)];
    
    final iconIndex = index % icons.length;

    // Format display time
    final displayTime = _getFriendlyTime(consultation.createdAt);

    return Container(
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
              color: bgColors[iconIndex],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icons[iconIndex],
              color: iconColors[iconIndex],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Use patient ID as title if no specific title exists in model
                  'Consultation ${consultation.patientId}', 
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
                      'Dr. Sarah', // Hardcoded as per design requirement
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text('•', style: TextStyle(color: Colors.grey[400])),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
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
    );
  }

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

  Future<void> _startNewRecording(BuildContext context, WidgetRef ref) async {
    // Clear previous transcript state to ensure a fresh session
    ref.read(transcriptStateProvider.notifier).clear();

    // Create new consultation
    final consultation = await ref.read(currentConsultationProvider.notifier).createNew(
      patientId: 'patient_${DateTime.now().millisecondsSinceEpoch}',
      doctorId: 'doctor_001',
    );
    
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecordingScreen(consultationId: consultation.id),
        ),
      );
    }
  }
}
