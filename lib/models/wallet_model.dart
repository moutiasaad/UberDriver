class WalletModel {
  final double balance;
  final double todayEarnings;
  final double weekEarnings;
  final double monthEarnings;
  final String currency;
  final String currencySymbol;
  final double minWithdrawalAmount;

  WalletModel({
    required this.balance,
    required this.todayEarnings,
    required this.weekEarnings,
    required this.monthEarnings,
    required this.currency,
    required this.currencySymbol,
    required this.minWithdrawalAmount,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      balance: (json['balance'] ?? 0).toDouble(),
      todayEarnings: (json['today_earnings'] ?? 0).toDouble(),
      weekEarnings: (json['week_earnings'] ?? 0).toDouble(),
      monthEarnings: (json['month_earnings'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'SAR',
      currencySymbol: json['currency_symbol'] ?? 'ر.س',
      minWithdrawalAmount: (json['min_withdrawal_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'today_earnings': todayEarnings,
      'week_earnings': weekEarnings,
      'month_earnings': monthEarnings,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'min_withdrawal_amount': minWithdrawalAmount,
    };
  }
}
