class ProfileStatsModel {
  final int totalProductsListed;
  final int totalProductsPurchased;
  final double totalEarnings;
  final String currency;

  ProfileStatsModel({
    this.totalProductsListed = 0,
    this.totalProductsPurchased = 0,
    this.totalEarnings = 0.0,
    this.currency = 'AED',
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return ProfileStatsModel(
      totalProductsListed: data['totalProductsListed'] ?? 0,
      totalProductsPurchased: data['totalProductsPurchased'] ?? 0,
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'AED',
    );
  }

  String get formattedEarnings {
    if (totalEarnings >= 1000) {
      return "${(totalEarnings / 1000).toStringAsFixed(1)}k";
    }
    return totalEarnings.toInt().toString();
  }
}
