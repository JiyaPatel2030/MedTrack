import 'package:flutter/material.dart';

import '../../models/medicine.dart';
import '../../services/medicine_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utilities/date_utils.dart';
import 'add_medicine_screen.dart';

class MedicineDetailScreen extends StatefulWidget {
  final Medicine medicine;

  const MedicineDetailScreen({
    super.key,
    required this.medicine,
  });

  @override
  State<MedicineDetailScreen> createState() => _MedicineDetailScreenState();
}

class _MedicineDetailScreenState extends State<MedicineDetailScreen> {
  late Medicine _currentMedicine;
  final MedicineService _medicineService = MedicineService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _currentMedicine = widget.medicine;
  }

  Color _getStatusColor() {
    if (_currentMedicine.isDiscarded) {
      return AppTheme.textSecondary;
    }
    switch (_currentMedicine.getStatus()) {
      case 'Expired':
        return AppTheme.expired;
      case 'Expiring Soon':
        return AppTheme.expiring;
      default:
        return AppTheme.good;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'syrup':
      case 'liquid':
        return Icons.water_drop_outlined;
      case 'capsule':
        return Icons.pie_chart_outline_rounded;
      case 'injection':
        return Icons.vaccines_outlined;
      case 'drops':
        return Icons.opacity_rounded;
      case 'cream':
      case 'ointment':
        return Icons.clean_hands_outlined;
      default:
        return Icons.medication_rounded;
    }
  }

  Future<void> _navigateToEdit() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicineScreen(medicine: _currentMedicine),
      ),
    );

    if (updated == true) {
      final refreshed = await _medicineService.getMedicineById(_currentMedicine.id);
      if (refreshed != null && mounted) {
        setState(() {
          _currentMedicine = refreshed;
        });
      }
    }
  }

  Future<void> _toggleDiscard() async {
    try {
      final newDiscardedState = !_currentMedicine.isDiscarded;

      if (newDiscardedState) {
        await _notificationService.cancelExpiryReminder(_currentMedicine.id);
      } else {
        await _notificationService.scheduleExpiryReminder(
          medicineId: _currentMedicine.id,
          medicineName: _currentMedicine.name,
          expiryDate: _currentMedicine.expiryDate,
        );
      }

      final updatedMedicine = _currentMedicine.copyWith(
        isDiscarded: newDiscardedState,
      );

      await _medicineService.updateMedicine(updatedMedicine);

      if (!mounted) return;

      setState(() {
        _currentMedicine = updatedMedicine;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newDiscardedState
                ? '${_currentMedicine.name} marked as discarded.'
                : '${_currentMedicine.name} restored to active list.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update medicine status: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteMedicine() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Medicine?'),
          content: Text(
            'Are you sure you want to delete ${_currentMedicine.name}? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.expired,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _notificationService.cancelExpiryReminder(_currentMedicine.id);
        await _medicineService.deleteMedicine(_currentMedicine.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_currentMedicine.name} deleted.'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete medicine: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final statusText = _currentMedicine.isDiscarded
        ? 'Discarded'
        : _currentMedicine.getStatus();
    final daysRemaining = AppDateUtils.daysUntil(_currentMedicine.expiryDate);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Medicine Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Medicine',
            onPressed: _navigateToEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: AppTheme.expired,
            tooltip: 'Delete Medicine',
            onPressed: _deleteMedicine,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(_currentMedicine.category),
                        size: 36,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentMedicine.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Expiry Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _currentMedicine.isExpired()
                          ? Icons.error_outline_rounded
                          : _currentMedicine.isNearingExpiry()
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline_rounded,
                      color: statusColor,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppDateUtils.getExpiryText(_currentMedicine.expiryDate),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            daysRemaining < 0
                                ? 'Please do not consume this medicine.'
                                : daysRemaining <= 30
                                    ? 'Consider replacing soon.'
                                    : 'Medicine is safe for usage.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Details Grid
              const Text(
                'Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Quantity',
                      value: '${_currentMedicine.quantity} units',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      icon: Icons.category_outlined,
                      title: 'Type',
                      value: _currentMedicine.category,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _infoCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Expiry Date',
                      value: AppDateUtils.formatDateReadable(_currentMedicine.expiryDate),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _infoCard(
                      icon: Icons.history_outlined,
                      title: 'Added Date',
                      value: AppDateUtils.formatDateReadable(_currentMedicine.addedDate),
                    ),
                  ),
                ],
              ),

              if (_currentMedicine.notes != null &&
                  _currentMedicine.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Dosage & Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _currentMedicine.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Discard / Restore Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _currentMedicine.isDiscarded
                        ? AppTheme.primary
                        : AppTheme.textSecondary,
                    side: BorderSide(
                      color: _currentMedicine.isDiscarded
                          ? AppTheme.primary
                          : const Color(0xFFCBD5E1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _toggleDiscard,
                  icon: Icon(
                    _currentMedicine.isDiscarded
                        ? Icons.restore_rounded
                        : Icons.delete_sweep_outlined,
                  ),
                  label: Text(
                    _currentMedicine.isDiscarded
                        ? 'Restore Medicine to Reminders'
                        : 'Mark as Discarded',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}