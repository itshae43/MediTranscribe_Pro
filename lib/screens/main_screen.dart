import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import 'home_screen.dart';
import 'archive_screen.dart';
import 'settings_screen.dart';
import 'compliance_screen.dart';

/// Main Screen with Custom Bottom Navigation Bar
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ArchiveScreen(),
    const ComplianceScreen(), // Security Hub
    const SettingsScreen(),   // Profile Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, 'Dashboard', Icons.grid_view_rounded, Icons.grid_view_outlined),
                _buildNavItem(1, 'Archive', Icons.folder_open_rounded, Icons.folder_open_outlined),
                _buildNavItem(2, 'Security', Icons.shield_rounded, Icons.shield_outlined),
                _buildNavItem(3, 'Profile', Icons.person_rounded, Icons.person_outline_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData activeIcon, IconData inactiveIcon) {
    final isSelected = _currentIndex == index;
    final activeColor = AppTheme.primaryColor;
    final inactiveColor = AppTheme.textSecondary;

    return InkWell(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected 
          ? BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                key: ValueKey(isSelected),
                color: isSelected ? activeColor : inactiveColor,
                size: 24,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.2, end: 0),
            ]
          ],
        ),
      ),
    );
  }
}
