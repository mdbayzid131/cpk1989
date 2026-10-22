import 'package:cpk1989/data/models/profile_stats_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'profile distinguishes inventory, sales, purchases and payout earnings',
    () {
      final stats = ProfileStatsModel.fromJson({
        'data': {
          'totalProductsListed': 7,
          'totalProductsPurchased': 2,
          'totalProductsSold': 1,
          'closetValue': 1234.50,
          'totalSalesValue': 800,
          'totalEarnings': 0,
        },
      });
      expect(stats.totalProductsListed, 7);
      expect(stats.totalProductsPurchased, 2);
      expect(stats.totalProductsSold, 1);
      expect(stats.formattedClosetValue, '1,234.50');
      expect(stats.formattedSalesValue, '800');
      expect(stats.totalEarnings, 0);
    },
  );
  test('empty profile stats remain zero', () {
    final stats = ProfileStatsModel.fromJson({});
    expect(stats.totalProductsSold, 0);
    expect(stats.totalProductsPurchased, 0);
    expect(stats.formattedClosetValue, '0');
  });
  test('large closet values preserve decimals instead of rounding to k', () {
    final stats = ProfileStatsModel(closetValue: 1234567.89);
    expect(stats.formattedClosetValue, '1,234,567.89');
  });
}
