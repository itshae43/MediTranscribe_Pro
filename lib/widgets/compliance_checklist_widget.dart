import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';

/// Compliance Checklist Widget
/// Shows HIPAA compliance status indicators

class ComplianceChecklistWidget extends StatelessWidget {
  final List<String>? features;
  final bool showHeader;

  const ComplianceChecklistWidget({
    super.key,
    this.features,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayFeatures = features ?? AppConstants.complianceFeatures;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) ...[
              const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'HIPAA Compliance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
            ...displayFeatures.map((feature) => _buildCheckItem(feature)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.check,
              color: Colors.green.shade600,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Security Badge Widget
class SecurityBadgeWidget extends StatelessWidget {
  final String status;
  final bool isActive;

  const SecurityBadgeWidget({
    super.key,
    this.status = 'HIPAA Compliant',
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.verified_user : Icons.warning,
            color: isActive ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: isActive ? Colors.green.shade800 : Colors.orange.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
