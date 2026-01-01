import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/wallet_provide.dart';
import '../../shared/components/appBar/design_sheet_app_bar.dart';
import '../../shared/components/buttons/default_button.dart';
import '../../shared/components/text/CText.dart';
import '../../shared/components/text_fields/default_form_field.dart';
import '../../shared/error/error_component.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';

// Hardcoded Arabic strings for wallet screen
class _WalletStrings {
  static const String title = 'المحفظة';
  static const String totalBalance = 'الرصيد الكلي';
  static const String todayEarnings = 'أرباح اليوم';
  static const String weekEarnings = 'أرباح الأسبوع';
  static const String monthEarnings = 'أرباح الشهر';
  static const String withdraw = 'السحب';
  static const String amount = 'المبلغ';
  static const String minWithdrawal = 'الحد الأدنى للسحب';
  static const String connectionError = 'مشكلة في الاتصال';
  static const String retry = 'إعادة المحاولة';
  static const String withdrawSuccess = 'تم سحب المبلغ بنجاح';
  static const String withdrawError = 'حدث خطأ أثناء سحب المبلغ';
  static const String minAmountError = 'المبلغ أقل من الحد الأدنى للسحب';
  static const String enterAmount = 'الرجاء إدخال المبلغ';
  static const String bankName = 'اسم البنك';
  static const String bankAccount = 'رقم الحساب';
  static const String bankIban = 'رقم الآيبان';
  static const String enterBankName = 'الرجاء إدخال اسم البنك';
  static const String enterBankAccount = 'الرجاء إدخال رقم الحساب';
  static const String enterBankIban = 'الرجاء إدخال رقم الآيبان';
  static const String bankDetails = 'بيانات الحساب البنكي';
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  TextEditingController amountController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankAccountController = TextEditingController();
  TextEditingController bankIbanController = TextEditingController();
  late Future<void> _walletFuture;

  @override
  void initState() {
    super.initState();
    _walletFuture = _loadWallet();
  }

  Future<void> _loadWallet() async {
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);
    await walletProvider.getWallet();
  }

  @override
  void dispose() {
    amountController.dispose();
    bankNameController.dispose();
    bankAccountController.dispose();
    bankIbanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (context, walletProvider, child) {
        return Scaffold(
          appBar: designSheetAppBar(
            isLeading: true,
            isCentred: false,
            text: _WalletStrings.title,
            context: context,
            style: AppTextStyle.semiBoldBlack18,
          ),
          backgroundColor: BackgroundColor.background,
          body: FutureBuilder(
            future: _walletFuture,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Error state
              if (walletProvider.walletError != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _WalletStrings.connectionError,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _walletFuture = _loadWallet();
                            });
                          },
                          child: const Text(_WalletStrings.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // No data state
              if (!walletProvider.hasWallet) {
                return Center(
                  child: undefinedError(context: context),
                );
              }

              final wallet = walletProvider.wallet!;

              return RefreshIndicator(
                onRefresh: () => walletProvider.refreshWallet(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance Card
                      Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            cText(
                              text: _WalletStrings.totalBalance,
                              style: AppTextStyle.semiBoldWhite14,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                cText(
                                  text: wallet.balance.toStringAsFixed(2),
                                  style: AppTextStyle.boldWhite18.copyWith(
                                    fontSize: 40,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                cText(
                                  text: wallet.currencySymbol,
                                  style: AppTextStyle.semiBoldWhite16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_WalletStrings.minWithdrawal}: ${wallet.minWithdrawalAmount.toStringAsFixed(0)} ${wallet.currencySymbol}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Earnings Cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildEarningCard(
                                title: _WalletStrings.todayEarnings,
                                amount: wallet.todayEarnings,
                                symbol: wallet.currencySymbol,
                                icon: Icons.today,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildEarningCard(
                                title: _WalletStrings.weekEarnings,
                                amount: wallet.weekEarnings,
                                symbol: wallet.currencySymbol,
                                icon: Icons.date_range,
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildEarningCard(
                          title: _WalletStrings.monthEarnings,
                          amount: wallet.monthEarnings,
                          symbol: wallet.currencySymbol,
                          icon: Icons.calendar_month,
                          color: AppColors.warning,
                          isFullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: DefaultButton(
              loading: walletProvider.loading,
              text: _WalletStrings.withdraw,
              pressed: () {
                if (walletProvider.hasWallet) {
                  _showWithdrawSheet(
                    context: context,
                    walletProvider: walletProvider,
                  );
                }
              },
              activated: true,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEarningCard({
    required String title,
    required double amount,
    required String symbol,
    required IconData icon,
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BackgroundColor.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BorderColor.grey1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cText(
                  text: title,
                  style: AppTextStyle.regularBlack1_12,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    cText(
                      text: amount.toStringAsFixed(2),
                      style: AppTextStyle.semiBoldBlack18.copyWith(color: color),
                    ),
                    const SizedBox(width: 4),
                    cText(
                      text: symbol,
                      style: AppTextStyle.regularBlack1_12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSheet({
    required BuildContext context,
    required WalletProvider walletProvider,
  }) {
    final wallet = walletProvider.wallet;

    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: BorderColor.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  cText(
                    text: _WalletStrings.withdraw,
                    style: AppTextStyle.semiBoldBlack18,
                  ),
                  const SizedBox(height: 8),
                  if (wallet != null)
                    cText(
                      text: '${_WalletStrings.minWithdrawal}: ${wallet.minWithdrawalAmount.toStringAsFixed(0)} ${wallet.currencySymbol}',
                      style: AppTextStyle.regularBlack1_12,
                    ),
                  const SizedBox(height: 16),

                  // Amount field
                  DefaultFormField(
                    hint: _WalletStrings.amount,
                    contoller: amountController,
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 20),

                  // Bank details section
                  cText(
                    text: _WalletStrings.bankDetails,
                    style: AppTextStyle.mediumBlack14,
                  ),
                  const SizedBox(height: 12),

                  // Bank name field
                  DefaultFormField(
                    hint: _WalletStrings.bankName,
                    contoller: bankNameController,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 12),

                  // Bank account field
                  DefaultFormField(
                    hint: _WalletStrings.bankAccount,
                    contoller: bankAccountController,
                    type: TextInputType.number,
                  ),
                  const SizedBox(height: 12),

                  // Bank IBAN field
                  DefaultFormField(
                    hint: _WalletStrings.bankIban,
                    contoller: bankIbanController,
                    type: TextInputType.text,
                  ),
                  const SizedBox(height: 20),

                  DefaultButton(
                    loading: walletProvider.loading,
                    text: _WalletStrings.withdraw,
                    pressed: () {
                      // Validate amount
                      if (amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_WalletStrings.enterAmount),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      final amount = double.tryParse(amountController.text) ?? 0;

                      if (wallet != null && amount < wallet.minWithdrawalAmount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_WalletStrings.minAmountError),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      // Validate bank name
                      if (bankNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_WalletStrings.enterBankName),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      // Validate bank account
                      if (bankAccountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_WalletStrings.enterBankAccount),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      // Validate bank IBAN
                      if (bankIbanController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_WalletStrings.enterBankIban),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      // Call withdraw with all parameters
                      walletProvider.withdraw(
                        context: context,
                        amount: amount,
                        bankName: bankNameController.text.trim(),
                        bankAccount: bankAccountController.text.trim(),
                        bankIban: bankIbanController.text.trim(),
                      );
                    },
                    activated: true,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    ).then((value) {
      amountController.clear();
      bankNameController.clear();
      bankAccountController.clear();
      bankIbanController.clear();
    });
  }
}
