import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';

/// Alerts Screen
/// Displays system notifications and medical alerts
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications & Alerts',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: AppTheme.secondaryColor),
            tooltip: 'Mark all as read',
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Critical / Today
          _buildSectionHeader(context, 'Critical & Priority'),
          const SizedBox(height: 12),
          _buildAlertCard(
            context: context,
            title: 'Abnormal Lab Results',
            description: 'Patient (Sarah J.) showed elevated potassium levels. Immediate follow-up recommended.',
            timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
            type: AlertType.critical,
            isRead: false,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0),
          
          const SizedBox(height: 12),
          
          _buildAlertCard(
            context: context,
            title: 'Compliance Audit Required',
            description: 'Monthly HIPAA security audit is pending. Please review the security log.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            type: AlertType.warning,
            isRead: false,
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Section: Recent / Info
          _buildSectionHeader(context, 'Recent Updates'),
          const SizedBox(height: 12),

          _buildAlertCard(
            context: context,
            title: 'Transcription Completed',
            description: 'Consultation has been successfully localized and saved.',
            timestamp: DateTime.now().subtract(const Duration(hours: 5)),
            type: AlertType.success,
            isRead: true,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),

          const SizedBox(height: 12),

          _buildAlertCard(
            context: context,
            title: 'System Maintenance',
            description: 'Scheduled maintenance this Saturday at 2:00 AM EST. Expected downtime: 30 mins.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            type: AlertType.info,
            isRead: true,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
          
           const SizedBox(height: 12),

          _buildAlertCard(
            context: context,
            title: 'New Feature Available',
            description: 'Try the new "Smart Summary" feature in your settings.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            type: AlertType.info,
            isRead: true,
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required String title,
    required String description,
    required DateTime timestamp,
    required AlertType type,
    required bool isRead,
  }) {
    final dateFormat = DateFormat('h:mm a • MMM d');
    
    // Determine colors/icons based on type
    Color accentColor;
    IconData icon;
    
    switch (type) {
      case AlertType.critical:
        accentColor = AppTheme.errorColor;
        icon = Icons.error_outline;
        break;
      case AlertType.warning:
        accentColor = AppTheme.warningColor;
        icon = Icons.warning_amber_rounded;
        break;
      case AlertType.success:
        accentColor = AppTheme.successColor;
        icon = Icons.check_circle_outline;
        break;
      case AlertType.info:
      default:
        accentColor = AppTheme.secondaryColor;
        icon = Icons.info_outline;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead ? Colors.grey.shade200 : accentColor.withOpacity(0.3),
        ),
        boxShadow: isRead ? [] : AppTheme.shadowElevation1,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Indicator
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFormat.format(timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AlertType { critical, warning, success, info }
