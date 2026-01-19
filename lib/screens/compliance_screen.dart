import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../services/encryption_service.dart';

/// Compliance Screen
/// HIPAA compliance dashboard showing security status and audit features

class ComplianceScreen extends ConsumerWidget {
  const ComplianceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔒 Compliance Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Status Card
            _buildSecurityStatusCard(),
            
            const SizedBox(height: 20),
            
            // HIPAA Features
            _buildHIPAAFeaturesSection(),
            
            const SizedBox(height: 20),
            
            // Encryption Status
            _buildEncryptionStatusCard(),
            
            const SizedBox(height: 20),
            
            // Audit Trail Section
            _buildAuditTrailSection(),
            
            const SizedBox(height: 20),
            
            // Data Protection Policies
            _buildDataProtectionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.verified_user,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HIPAA Compliant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'All security features are active',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHIPAAFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HIPAA Security Features',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: AppConstants.complianceFeatures.map((feature) {
                return _buildFeatureItem(feature, true);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String feature, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.green.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isEnabled ? Icons.check_circle : Icons.cancel,
              color: isEnabled ? Colors.green : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            isEnabled ? 'Enabled' : 'Disabled',
            style: TextStyle(
              color: isEnabled ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncryptionStatusCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Encryption Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEncryptionItem(
                  'Data at Rest',
                  'AES-256 Encryption',
                  Icons.lock,
                  Colors.blue,
                ),
                const Divider(height: 24),
                _buildEncryptionItem(
                  'Data in Transit',
                  'TLS 1.3 / HTTPS',
                  Icons.security,
                  Colors.purple,
                ),
                const Divider(height: 24),
                _buildEncryptionItem(
                  'Key Management',
                  'Secure Key Storage',
                  Icons.key,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEncryptionItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle, color: Colors.green),
      ],
    );
  }

  Widget _buildAuditTrailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Audit Logs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              _buildAuditLogItem(
                'Consultation Created',
                'Doctor accessed patient record',
                DateTime.now().subtract(const Duration(minutes: 15)),
                'CREATE',
              ),
              const Divider(height: 1),
              _buildAuditLogItem(
                'Transcript Encrypted',
                'Audio transcript was encrypted',
                DateTime.now().subtract(const Duration(minutes: 30)),
                'ENCRYPT',
              ),
              const Divider(height: 1),
              _buildAuditLogItem(
                'Notes Generated',
                'Clinical notes auto-generated',
                DateTime.now().subtract(const Duration(hours: 1)),
                'GENERATE',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuditLogItem(
    String title,
    String description,
    DateTime timestamp,
    String action,
  ) {
    final actionColor = _getActionColor(action);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActionIcon(action),
              color: actionColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTimestamp(timestamp),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'CREATE':
        return Colors.blue;
      case 'ENCRYPT':
        return Colors.purple;
      case 'GENERATE':
        return Colors.green;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getActionIcon(String action) {
    switch (action) {
      case 'CREATE':
        return Icons.add_circle;
      case 'ENCRYPT':
        return Icons.lock;
      case 'GENERATE':
        return Icons.auto_fix_high;
      case 'DELETE':
        return Icons.delete;
      default:
        return Icons.info;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildDataProtectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Protection',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Data Retention'),
                  subtitle: const Text('Audio deleted after 24 hours'),
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.visibility_off, color: Colors.orange),
                  title: const Text('PII Auto-Redaction'),
                  subtitle: const Text('Automatically redact sensitive data'),
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.cloud_off, color: Colors.blue),
                  title: const Text('Offline Mode'),
                  subtitle: const Text('Store data only on device'),
                  trailing: Switch(value: false, onChanged: (_) {}),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
