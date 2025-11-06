enum SubscriptionTier {
  free,
  basic,
  premium,
  pro,
}

extension SubscriptionTierExtension on SubscriptionTier {
  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.basic:
        return 'Basic';
      case SubscriptionTier.premium:
        return 'Premium';
      case SubscriptionTier.pro:
        return 'Pro';
    }
  }

  int get analysisLimit {
    switch (this) {
      case SubscriptionTier.free:
        return 3;
      case SubscriptionTier.basic:
        return 20;
      case SubscriptionTier.premium:
        return 100;
      case SubscriptionTier.pro:
        return -1; // Unlimited
    }
  }

  bool get hasCloudStorage {
    switch (this) {
      case SubscriptionTier.free:
        return false;
      case SubscriptionTier.basic:
      case SubscriptionTier.premium:
      case SubscriptionTier.pro:
        return true;
    }
  }

  bool get hasPrioritySupport {
    switch (this) {
      case SubscriptionTier.free:
      case SubscriptionTier.basic:
        return false;
      case SubscriptionTier.premium:
      case SubscriptionTier.pro:
        return true;
    }
  }
}

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final SubscriptionTier subscriptionTier;
  final DateTime? subscriptionExpiresAt;
  final int analysisCount;
  final bool isEmailVerified;
  final Map<String, dynamic>? preferences;
  final List<String>? deviceTokens;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    required this.createdAt,
    this.lastLoginAt,
    required this.subscriptionTier,
    this.subscriptionExpiresAt,
    required this.analysisCount,
    required this.isEmailVerified,
    this.preferences,
    this.deviceTokens,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt?.millisecondsSinceEpoch,
      'subscriptionTier': subscriptionTier.name,
      'subscriptionExpiresAt': subscriptionExpiresAt?.millisecondsSinceEpoch,
      'analysisCount': analysisCount,
      'isEmailVerified': isEmailVerified,
      'preferences': preferences ?? {},
      'deviceTokens': deviceTokens ?? [],
    };
  }

  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'])
          : null,
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (tier) => tier.name == map['subscriptionTier'],
        orElse: () => SubscriptionTier.free,
      ),
      subscriptionExpiresAt: map['subscriptionExpiresAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['subscriptionExpiresAt'])
          : null,
      analysisCount: map['analysisCount'] ?? 0,
      isEmailVerified: map['isEmailVerified'] ?? false,
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      deviceTokens: List<String>.from(map['deviceTokens'] ?? []),
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    SubscriptionTier? subscriptionTier,
    DateTime? subscriptionExpiresAt,
    int? analysisCount,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
    List<String>? deviceTokens,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      analysisCount: analysisCount ?? this.analysisCount,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
      deviceTokens: deviceTokens ?? this.deviceTokens,
    );
  }

  bool get hasActiveSubscription {
    if (subscriptionTier == SubscriptionTier.free) return false;
    if (subscriptionExpiresAt == null) return true;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  bool get canPerformAnalysis {
    if (subscriptionTier == SubscriptionTier.pro) return true;
    return analysisCount < subscriptionTier.analysisLimit;
  }

  @override
  String toString() {
    return 'AppUser{id: $id, email: $email, fullName: $fullName, subscriptionTier: $subscriptionTier}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}