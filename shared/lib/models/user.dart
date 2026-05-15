// shared/lib/models/user.dart

class User {
  final String? id; // Backend _id
  final String name;
  final String email;
  final String? phoneNumber;
  final String? countryCode;
  final String? role; // admin, livreur, operateur, client, user
  final String? genderrole; // man, women, other
  final bool isEmailVerified;
  final bool isArchived;
  final String? profileImageUrl;
  final String? profileImagePublicId;
  final String? signupIntent; // client, livreur
  final String? livreurRequestStatus; // none, pending, approved, rejected
  final DateTime? livreurRequestedAt;
  final DateTime? livreurReviewedAt;
  final String? livreurReviewedBy;
  final String? livreurRejectionReason;
  final bool isBlocked;
  final double walletBalance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.countryCode,
    this.role,
    this.genderrole,
    this.isEmailVerified = false,
    this.isArchived = false,
    this.isBlocked = false,
    this.walletBalance = 0.0,
    this.profileImageUrl,
    this.profileImagePublicId,
    this.signupIntent,
    this.livreurRequestStatus,
    this.livreurRequestedAt,
    this.livreurReviewedAt,
    this.livreurReviewedBy,
    this.livreurRejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
        'role': role,
        'genderrole': genderrole,
        'isEmailVerified': isEmailVerified,
        'isArchived': isArchived,
        'isBlocked': isBlocked,
        'walletBalance': walletBalance,
        'profileImageUrl': profileImageUrl,
        'profileImagePublicId': profileImagePublicId,
        'signupIntent': signupIntent,
        'livreurRequestStatus': livreurRequestStatus,
        'livreurRequestedAt': livreurRequestedAt?.toIso8601String(),
        'livreurReviewedAt': livreurReviewedAt?.toIso8601String(),
        'livreurReviewedBy': livreurReviewedBy,
        'livreurRejectionReason': livreurRejectionReason,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id'] as String?,
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String?,
        countryCode: json['countryCode'] as String?,
        role: json['role'] as String?,
        genderrole: json['genderrole'] as String?,
        isEmailVerified: json['isEmailVerified'] as bool? ?? false,
        isArchived: json['isArchived'] as bool? ?? false,
        isBlocked: json['isBlocked'] as bool? ?? false,
        walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
        profileImageUrl: json['profileImageUrl'] as String?,
        profileImagePublicId: json['profileImagePublicId'] as String?,
        signupIntent: json['signupIntent'] as String?,
        livreurRequestStatus: json['livreurRequestStatus'] as String?,
        livreurRequestedAt: json['livreurRequestedAt'] != null
            ? DateTime.parse(json['livreurRequestedAt'] as String)
            : null,
        livreurReviewedAt: json['livreurReviewedAt'] != null
            ? DateTime.parse(json['livreurReviewedAt'] as String)
            : null,
        livreurReviewedBy: json['livreurReviewedBy'] as String?,
        livreurRejectionReason: json['livreurRejectionReason'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? role,
    String? genderrole,
    bool? isEmailVerified,
    bool? isArchived,
    bool? isBlocked,
    double? walletBalance,
    String? profileImageUrl,
    String? profileImagePublicId,
    String? signupIntent,
    String? livreurRequestStatus,
    DateTime? livreurRequestedAt,
    DateTime? livreurReviewedAt,
    String? livreurReviewedBy,
    String? livreurRejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      role: role ?? this.role,
      genderrole: genderrole ?? this.genderrole,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isArchived: isArchived ?? this.isArchived,
      isBlocked: isBlocked ?? this.isBlocked,
      walletBalance: walletBalance ?? this.walletBalance,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileImagePublicId: profileImagePublicId ?? this.profileImagePublicId,
      signupIntent: signupIntent ?? this.signupIntent,
      livreurRequestStatus: livreurRequestStatus ?? this.livreurRequestStatus,
      livreurRequestedAt: livreurRequestedAt ?? this.livreurRequestedAt,
      livreurReviewedAt: livreurReviewedAt ?? this.livreurReviewedAt,
      livreurReviewedBy: livreurReviewedBy ?? this.livreurReviewedBy,
      livreurRejectionReason: livreurRejectionReason ?? this.livreurRejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
