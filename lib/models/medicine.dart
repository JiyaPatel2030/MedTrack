import '../Utilities/date_utils.dart';

class Medicine {
  final String id;
  final String name;
  final int quantity;
  final DateTime expiryDate;
  final DateTime addedDate;
  final bool isDiscarded;
  final String category;
  final String? notes;

  Medicine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.addedDate,
    this.isDiscarded = false,
    this.category = 'Tablet',
    this.notes,
  });

  /// Check if medicine is expired
  bool isExpired() {
    return AppDateUtils.daysUntil(expiryDate) < 0;
  }

  /// Check if medicine is about to expire (within 30 days and not expired)
  bool isNearingExpiry({int warningDays = 30}) {
    final days = AppDateUtils.daysUntil(expiryDate);
    return days >= 0 && days <= warningDays;
  }

  /// Get the number of days until expiry
  int daysUntilExpiry() {
    return AppDateUtils.daysUntil(expiryDate);
  }

  /// Get expiry status string ('Expired', 'Expiring Soon', 'Good')
  String getStatus({int warningDays = 30}) {
    return AppDateUtils.getExpiryStatus(expiryDate, warningDays: warningDays);
  }

  /// Convert Medicine object to JSON map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
      'isDiscarded': isDiscarded,
      'category': category,
      'notes': notes,
    };
  }

  /// Factory constructor to deserialize JSON map from Firestore
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      addedDate: DateTime.parse(json['addedDate'] as String),
      isDiscarded: json['isDiscarded'] ?? false,
      category: json['category'] as String? ?? 'Tablet',
      notes: json['notes'] as String?,
    );
  }

  /// Create a copy of Medicine with updated fields
  Medicine copyWith({
    String? id,
    String? name,
    int? quantity,
    DateTime? expiryDate,
    DateTime? addedDate,
    bool? isDiscarded,
    String? category,
    String? notes,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
      isDiscarded: isDiscarded ?? this.isDiscarded,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, quantity: $quantity, category: $category, expiryDate: $expiryDate, status: ${getStatus()})';
  }
}