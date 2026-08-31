// class User {
//   final String uid;
//   final String email;
//   final String? displayName;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
//
//   User({
//     required this.uid,
//     required this.email,
//     this.displayName,
//     required this.createdAt,
//     this.updatedAt,
//   });
//
//   /// Convert User object to JSON for database storage
//   Map<String, dynamic> toJson() {
//     return {
//       'uid': uid,
//       'email': email,
//       'displayName': displayName,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//     };
//   }
//
//   /// Convert JSON from database back to User object
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       uid: json['uid'] as String,
//       email: json['email'] as String,
//       displayName: json['displayName'] as String?,
//       createdAt: DateTime.parse(json['createdAt'] as String),
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.parse(json['updatedAt'] as String)
//           : null,
//     );
//   }
//
//   /// Create a copy of User with some fields changed
//   User copyWith({
//     String? uid,
//     String? email,
//     String? displayName,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return User(
//       uid: uid ?? this.uid,
//       email: email ?? this.email,
//       displayName: displayName ?? this.displayName,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
//
//   @override
//   String toString() {
//     return 'User(uid: $uid, email: $email, displayName: $displayName, createdAt: $createdAt)';
//   }
// }