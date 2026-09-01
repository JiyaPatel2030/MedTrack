class Medicine {
  final String id;
  final String name;
  final int quantity;
  final DateTime expiryDate;
  final DateTime addedDate;

  Medicine({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    required this.addedDate,
  });

  /// Check if medicine is expired
  bool isExpired() {
    return DateTime.now().isAfter(expiryDate);
  }

  /// Check if medicine is about to expire (within 30 days)
  bool isNearingExpiry() {
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  /// Get the number of days until expiry
  int daysUntilExpiry() {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Get expiry status as a readable string
  String getStatus() {
    if (isExpired()) {
      return 'Expired';
    }
    if (isNearingExpiry()) {
      return 'Expiring Soon';
    }
    return 'Good';
  }

  /// Get expiry status color for UI (red, yellow, green)
  String getStatusColor() {
    if (isExpired()) {
      return 'red';
    }
    if (isNearingExpiry()) {
      return 'yellow';
    }
    return 'green';
  }

  /// Convert Medicine object to JSON for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'expiryDate': expiryDate.toIso8601String(),
      'addedDate': addedDate.toIso8601String(),
    };
  }

  /// Convert JSON from database back to Medicine object
  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      addedDate: DateTime.parse(json['addedDate'] as String),
    );
  }

  /// Create a copy of Medicine with some fields changed
  Medicine copyWith({
    String? id,
    String? name,
    int? quantity,
    DateTime? expiryDate,
    DateTime? addedDate,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate ?? this.addedDate,
    );
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, quantity: $quantity, expiryDate: $expiryDate, status: ${getStatus()})';
  }
}