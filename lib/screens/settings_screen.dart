import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../config/environment.dart';

/// Settings & Profile Screen
/// Redesigned to match the specific UI provided
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // State variables for toggles
  bool _darkMode = false;
  bool _biometricLock = true;

  @override
  Widget build(BuildContext context) {
    // The design has a deep blue header and a light grey body
    // We can interpret this as a column with the header container and then the scrollable content
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Light grey background
      body: Column(
        children: [
          // 1. Custom Blue Header
          _buildHeader(),

          // 2. Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                   // Profile Card
                   _buildProfileCard(),
                   const SizedBox(height: 24),

                   // App Preferences
                   _buildSectionTitle('APP PREFERENCES'),
                   _buildAppPreferencesCard(),
                   const SizedBox(height: 24),

                   // Security & Privacy
                   _buildSectionTitle('SECURITY & PRIVACY'),
                   _buildSecurityCard(),
                   const SizedBox(height: 24),

                   // Data & Storage
                   _buildSectionTitle('DATA & STORAGE'),
                   _buildStorageCard(),
                   const SizedBox(height: 32),

                   // Send Feedback Button
                   SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: ElevatedButton.icon(
                       onPressed: () {},
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF2E3E8C),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(12),
                         ),
                       ),
                       icon: const Icon(Icons.chat_bubble_outline, size: 20),
                       label: const Text(
                         'Send Feedback',
                         style: TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w600,
                         ),
                       ),
                     ),
                   ),
                   const SizedBox(height: 16),

                   // Delete Account
                   TextButton(
                     onPressed: _showDeleteAccountDialog,
                     child: const Text(
                       'Delete Account',
                       style: TextStyle(
                         color: Colors.red, // Design shows red text
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                   ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      width: double.infinity,
      color: const Color(0xFF2E3E8C), // Royal Blue
      child: Center(
        child: Row(
          children: [
            InkWell(
              onTap: () {
                 if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
            const Expanded(
              child: Text(
                'Settings & Profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20), // Balance the back button
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
               // Avatar
               Stack(
                 children: [
                   const CircleAvatar(
                     radius: 30,
                     backgroundColor: Colors.grey,
                     // Use a real image or asset if available. 
                     // Using network for placeholder or icon
                     backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026024d'),
                   ),
                   Positioned(
                     right: 0,
                     bottom: 0,
                     child: Container(
                       padding: const EdgeInsets.all(2),
                       decoration: const BoxDecoration(
                         color: Colors.white,
                         shape: BoxShape.circle,
                       ),
                       child: const Icon(Icons.verified, color: Colors.blue, size: 18),
                     ),
                   ),
                 ],
               ),
               const SizedBox(width: 16),
               // Name & Details
               const Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(
                       'Dr. Sarah Chen',
                       style: TextStyle(
                         fontSize: 18,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFF1E3A8A), // Dark blue text
                       ),
                     ),
                     SizedBox(height: 4),
                     Text(
                       'Cardiology • ID: 8942-A',
                       style: TextStyle(
                         fontSize: 14,
                         color: Colors.grey, // Grey subtitle
                       ),
                     ),
                   ],
                 ),
               ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF2E3E8C),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Profile'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E3E8C),
                    side: const BorderSide(color: Color(0xFF2E3E8C), width: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildAppPreferencesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          SwitchListTile(
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
            secondary: Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
               child: const Icon(Icons.dark_mode_outlined, size: 20, color: Colors.indigo),
            ),
            activeColor: Colors.indigo,
          ),
          const Divider(height: 1, indent: 64, endIndent: 20),
          ListTile(
            title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
            leading: Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
               child: const Icon(Icons.notifications_none, size: 20, color: Colors.indigo),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(
                     color: Colors.green.withOpacity(0.1),
                     shape: BoxShape.circle
                   ),
                   child: const Icon(Icons.lock, size: 20, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Encryption Status', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text('AES-256 Active', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View Keys', style: TextStyle(color: Color(0xFF2E3E8C), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 64, endIndent: 20),
          SwitchListTile(
            value: _biometricLock,
            onChanged: (val) => setState(() => _biometricLock = val),
            title: const Text('Biometric Lock', style: TextStyle(fontWeight: FontWeight.w500)),
            secondary: Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
               child: const Icon(Icons.face, size: 20, color: Colors.indigo), // Or fingerprint
            ),
            activeColor: Colors.green, // Design shows green toggle
          ),
        ],
      ),
    );
  }

  Widget _buildStorageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
                Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                   child: const Icon(Icons.cloud_queue, size: 24, color: Color(0xFF2E3E8C)),
                ),
                const SizedBox(width: 16),
                const Text('Cloud Storage', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('PRO PLAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
             ],
           ),
           const SizedBox(height: 20),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               const Text('12.5 GB Used', style: TextStyle(color: Color(0xFF2E3E8C), fontWeight: FontWeight.bold, fontSize: 12)),
               Text('50 GB Total', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, fontSize: 12)),
             ],
           ),
           const SizedBox(height: 8),
           // Custom Progress Bar
           Stack(
             children: [
               Container(
                 height: 8,
                 width: double.infinity,
                 decoration: BoxDecoration(
                   color: Colors.grey.shade200,
                   borderRadius: BorderRadius.circular(4),
                 ),
               ),
               Container(
                 height: 8,
                 width: 100, // Approx 25% of width
                 decoration: BoxDecoration(
                   color: const Color(0xFF2E3E8C),
                   borderRadius: BorderRadius.circular(4),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 16),
           Text(
             'Your medical dictations are securely encrypted and stored. Storage is optimal.',
             style: TextStyle(fontSize: 11, color: Colors.grey.shade500, height: 1.4),
           ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
     showDialog(
       context: context,
       builder: (context) => AlertDialog(
         title: const Text('Delete Account'),
         content: const Text('This action is irreversible. All your data will be permanently removed. Are you sure?'),
         actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Implement delete logic
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
         ],
       ),
     );
  }
}
