import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/consultation_provider.dart';
import '../models/consultation.dart';
import 'recording_screen.dart';
import 'archive_screen.dart';
import 'settings_screen.dart';
import 'compliance_screen.dart';

/// Home Screen
/// Main dashboard showing recent consultations and quick actions

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consultationsAsync = ref.watch(consultationsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('🏥 MediTranscribe Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.security),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ComplianceScreen()),
            ),
            tooltip: 'Compliance',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(consultationsListProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats Card
              _buildQuickStatsCard(context, consultationsAsync)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActionsSection(context, ref)
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 24),
              
              // Recent Consultations
              _buildRecentConsultationsSection(context, consultationsAsync)
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewRecording(context, ref),
        icon: const Icon(Icons.mic),
        label: const Text('New Recording'),
        backgroundColor: AppTheme.primaryColor,
      )
          .animate()
          .fadeIn(delay: 600.ms, duration: 400.ms)
          .scale(),
    );
  }

  Widget _buildQuickStatsCard(
    BuildContext context,
    AsyncValue<List<Consultation>> consultationsAsync,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            consultationsAsync.when(
              data: (consultations) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    'Total',
                    consultations.length.toString(),
                    Icons.folder,
                    Colors.blue,
                  ),
                  _buildStatItem(
                    'Drafts',
                    consultations.where((c) => c.status == 'draft').length.toString(),
                    Icons.edit_note,
                    Colors.orange,
                  ),
                  _buildStatItem(
                    'Finalized',
                    consultations.where((c) => c.status == 'finalized').length.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'New Recording',
                Icons.mic,
                AppTheme.recordingActive,
                () => _startNewRecording(context, ref),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'View Archive',
                Icons.archive,
                AppTheme.primaryColor,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentConsultationsSection(
    BuildContext context,
    AsyncValue<List<Consultation>> consultationsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Consultations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
        const SizedBox(height: 12),
        consultationsAsync.when(
          data: (consultations) {
            if (consultations.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: consultations.take(5).length,
              itemBuilder: (context, index) {
                final consultation = consultations[index];
                return _buildConsultationCard(context, consultation);
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => Center(
            child: Text('Error loading consultations: $e'),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No consultations yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "New Recording" to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultationCard(BuildContext context, Consultation consultation) {
    final statusColor = _getStatusColor(consultation.status);
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            consultation.status == 'finalized' ? Icons.check_circle : Icons.edit_note,
            color: statusColor,
          ),
        ),
        title: Text(
          'Patient: ${consultation.patientId}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Duration: ${consultation.formattedDuration}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              _formatDate(consultation.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            consultation.status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        onTap: () {
          // Navigate to consultation details
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'finalized':
        return Colors.green;
      case 'reviewed':
        return Colors.blue;
      case 'draft':
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _startNewRecording(BuildContext context, WidgetRef ref) async {
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
