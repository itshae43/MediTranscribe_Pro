import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/consultation_provider.dart';
import '../models/consultation.dart';

/// Archive Screen
/// Displays past consultations with a specific design:
/// - Custom Blue Header with Search
/// - Filter Chips (All Dates, Doctor, Status)
/// - Date Grouped List
/// - Card style with Time, Doctor Name, ID/Details, Status Icon + Lock
class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  String _searchQuery = '';
  // "All Dates" is the primary active filter in the design
  String _selectedDateFilter = 'All Dates'; 
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the list of consultations
    final consultationsAsync = ref.watch(consultationsListProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // 1. Custom Blue Header
          _buildHeader(),

          // 2. Filter Row
          _buildFilterRow(),

          // 3. Consultation List (Grouped)
          Expanded(
            child: consultationsAsync.when(
              data: (consultations) => _buildGroupedList(consultations),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for new recording?
        },
        backgroundColor: AppTheme.warningColor, // Orange for Action
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }

  // --- HEADER ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor, // Medical Blue
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Top Row: Back | Title | Settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderIcon(Icons.arrow_back, () {
                 // If pushed from navigation, pop. 
                 // If main tab, maybe do nothing or switch tab.
                 // Assuming standard nav behavior for now.
                 if (Navigator.canPop(context)) Navigator.pop(context);
              }),
              Text(
                'Archive',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildHeaderIcon(Icons.settings, () {
                // Navigate to Settings
              }),
            ],
          ),
          const SizedBox(height: 20),
          
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Search by patient, ID, or keyword...',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  // --- FILTER ROW ---
  Widget _buildFilterRow() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Active Filter (Deep Blue)
          _buildFilterChip('All Dates', true, hasDropdown: true),
          const SizedBox(width: 12),
          // Inactive Filters (White with border)
          _buildFilterChip('Dr. Evans', false, hasDropdown: true),
          const SizedBox(width: 12),
          _buildFilterChip('Completed', false, hasDropdown: false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive, {bool hasDropdown = false}) {
    final bgColor = isActive ? AppTheme.primaryColor : Colors.white;
    final textColor = isActive ? Colors.white : AppTheme.textPrimary;
    final borderColor = isActive ? Colors.transparent : Colors.grey.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: textColor, size: 18),
          ],
        ],
      ),
    );
  }

  // --- LIST LOGIC ---
  Widget _buildGroupedList(List<Consultation> consultations) {
    // 1. Filter
    final filtered = _filterConsultations(consultations);
    
    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    // 2. Group by Date
    // Map<String, List<Consultation>>
    final grouped = <String, List<Consultation>>{};
    
    for (var c in filtered) {
        final dateKey = _getDateGroupHeader(c.createdAt);
        if (!grouped.containsKey(dateKey)) {
            grouped[dateKey] = [];
        }
        grouped[dateKey]!.add(c);
    }
    
    // Sort keys? Today first, then Yesterday, then dates.
    // Since we likely process most recent first, insertion order might be fine if list is sorted.
    // Let's assume input list is sorted by date desc. If not, sort keys.
    final sortedKeys = grouped.keys.toList(); // Should rely on list order for now

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedKeys.length + 1, // +1 for "Load older records" button
      itemBuilder: (context, index) {
        if (index == sortedKeys.length) {
            return _buildLoadMoreButton();
        }
        
        final key = sortedKeys[index];
        final items = grouped[key]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                key.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            ...items.map((c) => _buildConsultationCard(c)),
          ],
        );
      },
    );
  }

  String _getDateGroupHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    return DateFormat('MMMM yyyy').format(date); // e.g. JANUARY 2026
  }

  List<Consultation> _filterConsultations(List<Consultation> items) {
     if (_searchQuery.isEmpty) return items;
     final q = _searchQuery.toLowerCase();
     return items.where((c) => 
        c.patientId.toLowerCase().contains(q) || 
        c.doctorId.toLowerCase().contains(q) ||
        (c.transcript?.toLowerCase().contains(q) ?? false)
     ).toList();
  }

  Widget _buildEmptyState() {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Icon(Icons.search_off, size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text("No results found", style: TextStyle(color: Colors.grey.shade500)),
              ],
          ),
      );
  }

  Widget _buildLoadMoreButton() {
     return Center(
       child: Padding(
         padding: const EdgeInsets.symmetric(vertical: 24),
         child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1), // Light Blue bg
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Text(
                    'Load older records',
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.refresh, size: 18, color: AppTheme.primaryColor),
              ],
            ),
         ),
       ),
     );
  }

  // --- CARD DESIGN ---
  Widget _buildConsultationCard(Consultation c) {
    final timeStr = DateFormat('hh:mm').format(c.createdAt);
    final amPm = DateFormat('a').format(c.createdAt);
    
    // Status Logic
    final isFinalized = c.status == 'finalized';
    final statusIcon = isFinalized ? Icons.check : Icons.hourglass_empty;
    final statusBgColor = isFinalized ? AppTheme.successColor.withOpacity(0.1) : Colors.orange.withOpacity(0.1); 
    final statusIconColor = isFinalized ? AppTheme.successColor : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: AppTheme.shadowElevation1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Time
          Column(
            children: [
              Text(
                timeStr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                amPm,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Middle: Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Dr. ${c.doctorId == 'doctor_001' ? 'Sarah Mitchell' : 'Unknown'}', // Use real name or mock map
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16, 
                        color: Colors.black87,
                    ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4),
                    children: [
                        TextSpan(text: 'ID: #${c.patientId.split('_').last.substring(0,5)} • ', style: const TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(text: _getSnippet(c)),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Status + Lock
          Column(
              children: [
                   Container(
                     padding: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                         color: statusBgColor,
                         shape: BoxShape.circle,
                     ),
                     child: Icon(statusIcon, color: statusIconColor, size: 20),
                   ),
                   const SizedBox(height: 8),
                   Icon(Icons.lock, color: Colors.grey.shade300, size: 16),
              ],
          ),
        ],
      ),
    );
  }

  String _getSnippet(Consultation c) {
      if (c.transcript != null && c.transcript!.isNotEmpty) {
          return c.transcript!;
      }
      return 'No transcript available for this consultation...';
  }
}
