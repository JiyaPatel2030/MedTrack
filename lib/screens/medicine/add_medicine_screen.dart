import 'package:flutter/material.dart';

import '../../models/medicine.dart';
import '../../services/medicine_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../utilities/date_utils.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddMedicineScreen({
    super.key,
    this.medicine,
  });

  bool get isEditing => medicine != null;

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  String _selectedCategory = 'Tablet';
  DateTime? _expiryDate;

  final MedicineService _medicineService = MedicineService();
  final NotificationService _notificationService = NotificationService();

  bool _isSaving = false;

  final List<String> _categories = [
    'Tablet',
    'Syrup',
    'Capsule',
    'Injection',
    'Drops',
    'Cream',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.medicine?.name ?? '',
    );

    _quantityController = TextEditingController(
      text: widget.medicine?.quantity.toString() ?? '',
    );

    _notesController = TextEditingController(
      text: widget.medicine?.notes ?? '',
    );

    _selectedCategory = widget.medicine?.category ?? 'Tablet';
    _expiryDate = widget.medicine?.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 30)),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 20),
    );

    if (selectedDate != null) {
      setState(() {
        _expiryDate = selectedDate;
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expiry date'),
        ),
      );
      return;
    }

    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final name = _nameController.text.trim();
    final quantity = int.parse(_quantityController.text.trim());
    final notes = _notesController.text.trim();

    try {
      if (widget.isEditing) {
        final updatedMedicine = widget.medicine!.copyWith(
          name: name,
          quantity: quantity,
          category: _selectedCategory,
          expiryDate: _expiryDate,
          notes: notes.isNotEmpty ? notes : null,
        );

        await _medicineService.updateMedicine(updatedMedicine);
        await _notificationService.cancelExpiryReminder(updatedMedicine.id);

        if (!updatedMedicine.isDiscarded) {
          await _notificationService.scheduleExpiryReminder(
            medicineId: updatedMedicine.id,
            medicineName: updatedMedicine.name,
            expiryDate: updatedMedicine.expiryDate,
          );
        }
      } else {
        final medicine = Medicine(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          quantity: quantity,
          category: _selectedCategory,
          expiryDate: _expiryDate!,
          addedDate: DateTime.now(),
          notes: notes.isNotEmpty ? notes : null,
        );

        await _medicineService.addMedicine(medicine);

        if (!medicine.isDiscarded) {
          await _notificationService.scheduleExpiryReminder(
            medicineId: medicine.id,
            medicineName: medicine.name,
            expiryDate: medicine.expiryDate,
          );
        }
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save medicine: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medicine' : 'Add Medicine'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update medicine details' : 'Add a new medicine',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isEditing
                      ? 'Keep your medicine information up to date.'
                      : 'Enter the details to keep track of its expiry.',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),

                // Medicine Name
                const Text(
                  'Medicine name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Paracetamol',
                    prefixIcon: Icon(Icons.medication_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter medicine name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Category & Quantity row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: _categories.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategory = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'e.g. 20',
                              prefixIcon: Icon(Icons.inventory_2_outlined),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final q = int.tryParse(value.trim());
                              if (q == null || q <= 0) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Expiry Date
                const Text(
                  'Expiry date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _selectExpiryDate,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 17,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _expiryDate == null
                                ? 'Select expiry date'
                                : AppDateUtils.formatDateReadable(_expiryDate!),
                            style: TextStyle(
                              color: _expiryDate == null
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Notes / Instructions
                const Text(
                  'Dosage / Notes (Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Take 1 tablet twice daily after meals.',
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 36),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveMedicine,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditing ? 'Update Medicine' : 'Save Medicine',
                          ),
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