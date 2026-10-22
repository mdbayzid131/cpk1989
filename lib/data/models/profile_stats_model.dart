class ProfileStatsModel {
  final int totalProductsListed;
  final int totalProductsPurchased;
  final int totalProductsSold;
  final double closetValue;
  final double totalSalesValue;
  final double totalEarnings;
  final String currency;

  ProfileStatsModel({
    this.totalProductsListed = 0,
    this.totalProductsPurchased = 0,
    this.totalProductsSold = 0,
    this.closetValue = 0,
    this.totalSalesValue = 0,
    this.totalEarnings = 0.0,
    this.currency = 'AED',
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    return ProfileStatsModel(
      totalProductsListed: data['totalProductsListed'] ?? 0,
      totalProductsPurchased: data['totalProductsPurchased'] ?? 0,
      totalProductsSold: data['totalProductsSold'] ?? 0,
      closetValue: (data['closetValue'] as num?)?.toDouble() ?? 0,
      totalSalesValue: (data['totalSalesValue'] as num?)?.toDouble() ?? 0,
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

  String get formattedClosetValue => _formatAmount(closetValue);
  String get formattedSalesValue => _formatAmount(totalSalesValue);

  static String _formatAmount(double value) {
    final amount = value.toStringAsFixed(2);
    final parts = amount.split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return parts[1] == '00' ? whole : '$whole.${parts[1]}';
  }
}
