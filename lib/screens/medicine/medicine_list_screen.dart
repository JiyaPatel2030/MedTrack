import 'package:flutter/material.dart';

import '../../models/medicine.dart';
import '../../services/medicine_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utilities/date_utils.dart';
import 'add_medicine_screen.dart';
import 'medicine_detail_screen.dart';

class MedicineListScreen extends StatefulWidget {
  const MedicineListScreen({super.key});

  @override
  State<MedicineListScreen> createState() => _MedicineListScreenState();
}

class _MedicineListScreenState extends State<MedicineListScreen> {
  final MedicineService _medicineService = MedicineService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Medicine> _filteredMedicines(List<Medicine> medicines) {
    final searchText = _searchController.text.toLowerCase().trim();

    return medicines.where((medicine) {
      final matchesSearch = medicine.name.toLowerCase().contains(searchText) ||
          medicine.category.toLowerCase().contains(searchText);

      bool matchesFilter = true;

      switch (_selectedFilter) {
        case 'Good':
          matchesFilter = !medicine.isDiscarded && medicine.getStatus() == 'Good';
          break;
        case 'Expiring':
          matchesFilter = !medicine.isDiscarded && medicine.getStatus() == 'Expiring Soon';
          break;
        case 'Expired':
          matchesFilter = !medicine.isDiscarded && medicine.getStatus() == 'Expired';
          break;
        case 'Discarded':
          matchesFilter = medicine.isDiscarded;
          break;
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> _addMedicine() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMedicineScreen(),
      ),
    );
  }

  Future<void> _openDetail(Medicine medicine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineDetailScreen(medicine: medicine),
      ),
    );
  }

  Future<void> _editMedicine(Medicine medicine) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicineScreen(medicine: medicine),
      ),
    );
  }

  Future<void> _deleteMedicine(Medicine medicine) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Medicine?'),
          content: Text('Are you sure you want to delete ${medicine.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.expired),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      await _notificationService.cancelExpiryReminder(medicine.id);
      await _medicineService.deleteMedicine(medicine.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medicine deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete medicine')),
      );
    }
  }

  Future<void> _discardMedicine(Medicine medicine) async {
    try {
      await _notificationService.cancelExpiryReminder(medicine.id);

      final discardedMedicine = medicine.copyWith(isDiscarded: true);
      await _medicineService.updateMedicine(discardedMedicine);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${medicine.name} marked as discarded.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to discard medicine')),
      );
    }
  }

  Color _statusColor(Medicine medicine) {
    if (medicine.isDiscarded) return AppTheme.textSecondary;
    switch (medicine.getStatus()) {
      case 'Expired':
        return AppTheme.expired;
      case 'Expiring Soon':
        return AppTheme.expiring;
      default:
        return AppTheme.good;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Medicines'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMedicine,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search medicines by name or type...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () => _searchController.clear(),
                        icon: const Icon(Icons.close),
                      )
                    : null,
              ),
            ),
          ),

          // Category & Filter Chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _filterChip('All'),
                _filterChip('Good'),
                _filterChip('Expiring'),
                _filterChip('Expired'),
                _filterChip('Discarded'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Realtime Stream of Medicines
          Expanded(
            child: StreamBuilder<List<Medicine>>(
              stream: _medicineService.medicinesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppTheme.expired,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Unable to load medicines',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allMedicines = snapshot.data ?? [];
                final medicines = _filteredMedicines(allMedicines);

                if (medicines.isEmpty) {
                  return _emptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  itemCount: medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index];
                    return _medicineTile(medicine);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final selected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppTheme.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: selected ? AppTheme.primary : AppTheme.textSecondary,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }

  Widget _medicineTile(Medicine medicine) {
    final color = _statusColor(medicine);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _openDetail(medicine),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.medication_rounded,
            color: color,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                medicine.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (medicine.isDiscarded)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Discarded',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${medicine.quantity} units • ${medicine.category} • ${AppDateUtils.getExpiryText(medicine.expiryDate)}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              _openDetail(medicine);
            } else if (value == 'edit') {
              _editMedicine(medicine);
            } else if (value == 'discard') {
              _discardMedicine(medicine);
            } else if (value == 'delete') {
              _deleteMedicine(medicine);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('View Details'),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            if (!medicine.isDiscarded)
              const PopupMenuItem(
                value: 'discard',
                child: Text('Discard'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 40,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No medicines found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your medicines to start tracking their expiry.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addMedicine,
              icon: const Icon(Icons.add),
              label: const Text('Add Medicine'),
            ),
          ],
        ),
      ),
    );
  }
}