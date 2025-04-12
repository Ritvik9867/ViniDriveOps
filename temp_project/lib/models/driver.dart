class Driver {
  final String id;
  final String name;
  final String email;
  final String phone;
  final double totalEarnings;
  final double totalExpenses;
  final double cashCollected;
  final double totalKmDriven;
  final double tripKm;
  final double burningKm;
  final double advanceBalance;
  final DateTime lastLoginTime;
  final bool isActive;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.totalEarnings = 0.0,
    this.totalExpenses = 0.0,
    this.cashCollected = 0.0,
    this.totalKmDriven = 0.0,
    this.tripKm = 0.0,
    this.burningKm = 0.0,
    this.advanceBalance = 0.0,
    required this.lastLoginTime,
    this.isActive = true,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      cashCollected: (json['cashCollected'] as num?)?.toDouble() ?? 0.0,
      totalKmDriven: (json['totalKmDriven'] as num?)?.toDouble() ?? 0.0,
      tripKm: (json['tripKm'] as num?)?.toDouble() ?? 0.0,
      burningKm: (json['burningKm'] as num?)?.toDouble() ?? 0.0,
      advanceBalance: (json['advanceBalance'] as num?)?.toDouble() ?? 0.0,
      lastLoginTime: DateTime.parse(json['lastLoginTime'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'totalEarnings': totalEarnings,
      'totalExpenses': totalExpenses,
      'cashCollected': cashCollected,
      'totalKmDriven': totalKmDriven,
      'tripKm': tripKm,
      'burningKm': burningKm,
      'advanceBalance': advanceBalance,
      'lastLoginTime': lastLoginTime.toIso8601String(),
      'isActive': isActive,
    };
  }

  Driver copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    double? totalEarnings,
    double? totalExpenses,
    double? cashCollected,
    double? totalKmDriven,
    double? tripKm,
    double? burningKm,
    double? advanceBalance,
    DateTime? lastLoginTime,
    bool? isActive,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      cashCollected: cashCollected ?? this.cashCollected,
      totalKmDriven: totalKmDriven ?? this.totalKmDriven,
      tripKm: tripKm ?? this.tripKm,
      burningKm: burningKm ?? this.burningKm,
      advanceBalance: advanceBalance ?? this.advanceBalance,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      isActive: isActive ?? this.isActive,
    );
  }
}
