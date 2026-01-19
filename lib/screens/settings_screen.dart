import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/environment.dart';

/// Settings Screen
/// App settings and preferences

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _offlineMode = true;
  bool _autoTranscribe = true;
  bool _enableNotifications = false;
  String _language = 'en-US';

  @override
  void initState() {
    super.initState();
    _darkMode = Environment.enableDarkMode;
    _offlineMode = Environment.enableOfflineMode;
    _enableNotifications = Environment.enablePushNotifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Section
          _buildSectionHeader('App Information'),
          _buildAppInfoCard(),
          
          const SizedBox(height: 24),
          
          // Recording Settings
          _buildSectionHeader('Recording'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Auto Transcribe',
              'Start transcription automatically when recording',
              Icons.record_voice_over,
              _autoTranscribe,
              (value) => setState(() => _autoTranscribe = value),
            ),
            _buildDivider(),
            _buildDropdownTile(
              'Language',
              'Transcription language',
              Icons.language,
              _language,
              ['en-US', 'en-GB', 'es-ES', 'fr-FR', 'de-DE'],
              (value) => setState(() => _language = value ?? 'en-US'),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Appearance Settings
          _buildSectionHeader('Appearance'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Dark Mode',
              'Use dark theme',
              Icons.dark_mode,
              _darkMode,
              (value) => setState(() => _darkMode = value),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Data & Privacy Settings
          _buildSectionHeader('Data & Privacy'),
          _buildSettingsCard([
            _buildSwitchTile(
              'Offline Mode',
              'Store data only on device',
              Icons.cloud_off,
              _offlineMode,
              (value) => setState(() => _offlineMode = value),
            ),
            _buildDivider(),
            _buildSwitchTile(
              'Notifications',
              'Enable push notifications',
              Icons.notifications,
              _enableNotifications,
              (value) => setState(() => _enableNotifications = value),
            ),
            _buildDivider(),
            _buildNavigationTile(
              'Clear Cache',
              'Remove temporary files',
              Icons.cleaning_services,
              () => _showClearCacheDialog(),
            ),
            _buildDivider(),
            _buildNavigationTile(
              'Export All Data',
              'Download your data',
              Icons.download,
              () => _exportData(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Security Settings
          _buildSectionHeader('Security'),
          _buildSettingsCard([
            _buildNavigationTile(
              'Change Encryption Key',
              'Update your encryption settings',
              Icons.key,
              () => _showChangeKeyDialog(),
            ),
            _buildDivider(),
            _buildNavigationTile(
              'View Audit Logs',
              'Review access history',
              Icons.history,
              () => _viewAuditLogs(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // About Section
          _buildSectionHeader('About'),
          _buildSettingsCard([
            _buildNavigationTile(
              'Privacy Policy',
              'Read our privacy policy',
              Icons.privacy_tip,
              () => _openPrivacyPolicy(),
            ),
            _buildDivider(),
            _buildNavigationTile(
              'Terms of Service',
              'Read our terms',
              Icons.description,
              () => _openTerms(),
            ),
            _buildDivider(),
            _buildNavigationTile(
              'Open Source Licenses',
              'View third-party licenses',
              Icons.code,
              () => _showLicenses(),
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          _buildSettingsCard([
            _buildDangerTile(
              'Delete All Data',
              'Permanently remove all your data',
              Icons.delete_forever,
              () => _showDeleteDataDialog(),
            ),
          ], isDanger: true),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.medical_services,
                color: AppTheme.primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MediTranscribe Pro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${Environment.appVersion} (Build ${Environment.buildNumber})',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Environment.isDevelopment
                          ? Colors.orange.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      Environment.environment.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Environment.isDevelopment
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
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

  Widget _buildSettingsCard(List<Widget> children, {bool isDanger = false}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDanger
            ? const BorderSide(color: Colors.red, width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: DropdownButton<String>(
        value: value,
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
        onChanged: onChanged,
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildNavigationTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDangerTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: const TextStyle(color: Colors.red)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.red),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56);
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache?'),
        content: const Text('This will remove all temporary files.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showChangeKeyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Encryption key management coming soon')),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your consultations, notes, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data...')),
    );
  }

  void _viewAuditLogs() {
    Navigator.pop(context);
  }

  void _openPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening privacy policy...')),
    );
  }

  void _openTerms() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening terms of service...')),
    );
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'MediTranscribe Pro',
      applicationVersion: Environment.appVersion,
    );
  }
}
