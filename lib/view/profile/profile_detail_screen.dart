import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../shared/components/buttons/cancel_button.dart';
import '../../../shared/components/buttons/default_button.dart';
import '../../providers/profile_provider.dart';
import '../../shared/components/buttons/default_outlined_button.dart';
import '../../shared/components/text/CText.dart';
import '../../shared/local/cash_helper.dart';
import '../../shared/local/secure_cash_helper.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';
import '../login/login_layout.dart';

// Hardcoded Arabic strings for profile screen
class _ProfileStrings {
  static const String title = 'بياناتي';
  static const String personalInfo = 'المعلومات الشخصية';
  static const String name = 'الاسم';
  static const String email = 'البريد الالكتروني';
  static const String phone = 'رقم الجوال';
  static const String vehicleInfo = 'معلومات المركبة';
  static const String vehicleType = 'نوع المركبة';
  static const String vehicleModel = 'موديل المركبة';
  static const String vehicleColor = 'لون المركبة';
  static const String plateNumber = 'رقم اللوحة';
  static const String licenseInfo = 'معلومات الرخصة';
  static const String licenseNumber = 'رقم الرخصة';
  static const String licenseExpiry = 'تاريخ انتهاء الرخصة';
  static const String accountStatus = 'حالة الحساب';
  static const String status = 'الحالة';
  static const String rating = 'التقييم';
  static const String totalTrips = 'إجمالي الرحلات';
  static const String walletBalance = 'رصيد المحفظة';
  static const String earnings = 'الأرباح';
  static const String todayEarnings = 'أرباح اليوم';
  static const String weekEarnings = 'أرباح الأسبوع';
  static const String monthEarnings = 'أرباح الشهر';
  static const String deleteAccount = 'حذف الحساب';
  static const String deleteConfirmTitle = 'هل انت متأكد من رغبتك في حذف الحساب؟';
  static const String deleteConfirmDesc = 'سيتم حذف الحساب نهائياً بعد 30 يوم وحذف جميع معلوماتك، خلال هذه المدة يمكنك استرجاع حسابك واستعادة بياناتك';
  static const String noDelete = 'لا، لا تقم بحذفه';
  static const String yesDelete = 'نعم، انا متأكد';
  static const String online = 'متصل';
  static const String offline = 'غير متصل';
  static const String available = 'متاح';
  static const String unavailable = 'غير متاح';
  static const String connectionError = 'مشكلة في الاتصال';
  static const String retry = 'إعادة المحاولة';
  static const String noData = 'لا توجد بيانات';
}

class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({super.key});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late Future<void> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.getDriverProfile();
  }

  @override
  Widget build(BuildContext context) {
    final currency = CashHelper.getCurrency();

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return Scaffold(
          backgroundColor: BackgroundColor.background,
          appBar: AppBar(
            title: cText(
              text: _ProfileStrings.title,
              style: AppTextStyle.semiBoldPrimary20,
            ),
            elevation: 0.5,
            backgroundColor: BackgroundColor.background,
            leading: CancelButton(
              context: context,
              icon: Icons.arrow_back,
              cancel: () => Navigator.pop(context),
            ),
          ),
          body: FutureBuilder(
            future: _profileFuture,
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Error state
              if (profileProvider.profileError != null) {
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
                          _ProfileStrings.connectionError,
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
                              _profileFuture = _loadProfile();
                            });
                          },
                          child: const Text(_ProfileStrings.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // No data state
              if (!profileProvider.hasProfile) {
                return Center(
                  child: Text(
                    _ProfileStrings.noData,
                    style: AppTextStyle.regularBlack1_14,
                  ),
                );
              }

              final profile = profileProvider.driverProfile!;

              return RefreshIndicator(
                onRefresh: () => profileProvider.refreshProfile(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      _buildProfileHeader(profile),

                      const SizedBox(height: 24),

                      // Status Cards
                      _buildStatusCards(profile),

                      const SizedBox(height: 24),

                      // Earnings Section
                      _buildSection(
                        title: _ProfileStrings.earnings,
                        icon: Icons.account_balance_wallet,
                        children: [
                          _buildInfoRow(
                            _ProfileStrings.todayEarnings,
                            '${profile.todayEarnings.toStringAsFixed(2)} $currency',
                            valueColor: AppColors.success,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.weekEarnings,
                            '${profile.weekEarnings.toStringAsFixed(2)} $currency',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.monthEarnings,
                            '${profile.monthEarnings.toStringAsFixed(2)} $currency',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.walletBalance,
                            '${profile.walletBalance.toStringAsFixed(2)} $currency',
                            valueColor: AppColors.primary,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Personal Info Section
                      _buildSection(
                        title: _ProfileStrings.personalInfo,
                        icon: Icons.person,
                        children: [
                          _buildInfoRow(_ProfileStrings.name, profile.name),
                          _buildDivider(),
                          _buildInfoRow(_ProfileStrings.email, profile.email),
                          _buildDivider(),
                          _buildInfoRow(_ProfileStrings.phone, profile.phone),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Vehicle Info Section
                      _buildSection(
                        title: _ProfileStrings.vehicleInfo,
                        icon: Icons.directions_car,
                        children: [
                          _buildInfoRow(
                            _ProfileStrings.vehicleType,
                            profile.vehicleTypeText,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.vehicleModel,
                            profile.vehicleModel ?? '-',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.vehicleColor,
                            profile.vehicleColor ?? '-',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.plateNumber,
                            profile.plateNumber ?? '-',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // License Info Section
                      _buildSection(
                        title: _ProfileStrings.licenseInfo,
                        icon: Icons.badge,
                        children: [
                          _buildInfoRow(
                            _ProfileStrings.licenseNumber,
                            profile.licenseNumber ?? '-',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.licenseExpiry,
                            profile.licenseExpiry ?? '-',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Account Status Section
                      _buildSection(
                        title: _ProfileStrings.accountStatus,
                        icon: Icons.verified_user,
                        children: [
                          _buildInfoRow(
                            _ProfileStrings.status,
                            profile.statusText,
                            valueColor: profile.isApproved
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.rating,
                            '${profile.ratingAverage.toStringAsFixed(1)} / 5.0',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            _ProfileStrings.totalTrips,
                            '${profile.totalTrips}',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Delete Account Button
                      InkWell(
                        onTap: () => _showDeleteDialog(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              cText(
                                text: _ProfileStrings.deleteAccount,
                                style: AppTextStyle.mediumRed14,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BackgroundColor.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BorderColor.grey1),
      ),
      child: Row(
        children: [
          // Profile Image
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: BackgroundColor.grey1,
              shape: BoxShape.circle,
            ),
            child: profile.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      profile.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    ),
                  )
                : _buildDefaultAvatar(),
          ),
          const SizedBox(width: 16),
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cText(
                  text: profile.name,
                  style: AppTextStyle.semiBoldBlack18,
                ),
                const SizedBox(height: 4),
                cText(
                  text: profile.email,
                  style: AppTextStyle.regularBlack1_14,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(
                      profile.isOnline
                          ? _ProfileStrings.online
                          : _ProfileStrings.offline,
                      profile.isOnline ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(
                      profile.isAvailable
                          ? _ProfileStrings.available
                          : _ProfileStrings.unavailable,
                      profile.isAvailable
                          ? AppColors.info
                          : AppColors.warning,
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

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards(profile) {
    final currency = CashHelper.getCurrency();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            value: profile.ratingAverage.toStringAsFixed(1),
            label: _ProfileStrings.rating,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.directions_car,
            value: '${profile.totalTrips}',
            label: _ProfileStrings.totalTrips,
            color: AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance_wallet,
            value: '${profile.walletBalance.toStringAsFixed(0)} $currency',
            label: _ProfileStrings.walletBalance,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          cText(
            text: value,
            style: AppTextStyle.semiBoldBlack14.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          cText(
            text: label,
            style: AppTextStyle.regularBlack1_12,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: BackgroundColor.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BorderColor.grey1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                cText(
                  text: title,
                  style: AppTextStyle.semiBoldBlack14,
                ),
              ],
            ),
          ),
          Container(height: 1, color: BorderColor.grey1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          cText(
            text: label,
            style: AppTextStyle.regularBlack1_14,
          ),
          cText(
            text: value,
            style: AppTextStyle.mediumBlack14.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: BorderColor.grey1,
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  Widget _buildDefaultAvatar() {
    return Center(
      child: Icon(
        Icons.person,
        color: IconColors.grey6,
        size: 40,
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    await showDialog(
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      context: context,
      builder: (BuildContext contexte) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: cText(
                                text: _ProfileStrings.deleteConfirmTitle,
                                style: AppTextStyle.semiBoldBlack18,
                              ),
                            ),
                            CancelButton(
                              size: 25,
                              context: context,
                              icon: CupertinoIcons.xmark,
                              cancel: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        cText(
                          text: _ProfileStrings.deleteConfirmDesc,
                          style: AppTextStyle.regularBlack1_14,
                        ),
                        const SizedBox(height: 16),
                        DefaultButton(
                          raduis: 6,
                          text: _ProfileStrings.noDelete,
                          pressed: () => Navigator.pop(context),
                          activated: true,
                        ),
                        const SizedBox(height: 12),
                        DefaultOutlinedButton(
                          ContainerColor: TextColor.red,
                          textStyle: AppTextStyle.mediumRed14,
                          raduis: 6,
                          text: _ProfileStrings.yesDelete,
                          pressed: () async {
                            await CashHelper.clearData();
                            await SecureCashHelper.clear();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginLayout(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
