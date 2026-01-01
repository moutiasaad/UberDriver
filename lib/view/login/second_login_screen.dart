import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../../../providers/register_provider.dart';
import '../../../shared/components/text/verification_time_text.dart';
import '../../models/register_model.dart';
import '../../shared/components/text/CText.dart';
import '../../shared/components/text_fields/verification_field.dart';
import '../../utils/app_images.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';

class SecondLoginScreen extends StatefulWidget {
  const SecondLoginScreen({
    super.key,
    required this.data,
    required this.forword,
    required this.back,
  });

  final RegisterModel data;
  final Function forword;
  final Function back;

  @override
  State<SecondLoginScreen> createState() => _SecondLoginScreenState();
}

class _SecondLoginScreenState extends State<SecondLoginScreen> {
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    // Clear any previous OTP errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RegisterProvider>(context, listen: false).clearErrors();
    });
  }

  void _onResendOtp() {
    if (!canResend) return;

    final registerProvider =
    Provider.of<RegisterProvider>(context, listen: false);

    registerProvider.resendOtp(widget.data, context);

    // Reset timer
    setState(() {
      canResend = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final registerProvider = Provider.of<RegisterProvider>(context);

    return Scaffold(
      backgroundColor: BackgroundColor.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                AppImages.otpIcon,
                width: 140,
                height: 140,
                fit: BoxFit.cover,
              ),
              cText(
                text: context.translate('login.checkNumber'),
                style: AppTextStyle.boldPrimary22,
                pBottom: 5,
              ),
              cText(
                text: '${context.translate('login.codeSendIt')}',
                style: AppTextStyle.regularBlack1_16,
                pBottom: 10,
              ),
              // Email display with edit button
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  // Go back to edit email
                  registerProvider.clearErrors();
                  widget.back();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: BackgroundColor.grey1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, color: IconColors.black, size: 20),
                      cText(
                        text: widget.data.email ?? '',
                        style: AppTextStyle.regularBlack1_16,
                      ),
                    ],
                  ),
                ),
              ),
              // OTP Verification Field
              VerificationField(
                forword: widget.forword,
                clear: () {
                  registerProvider.clearErrors();
                },
                secondsRemaining: 60,
                data: widget.data,
              ),
              // Error message display
              if (registerProvider.otpError ||
                  registerProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red.shade700, size: 20),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            registerProvider.errorMessage ??
                                context.translate('errorsMessage.invalidOtp'),
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 20),
              // Countdown timer with resend option
              CountdownTimer(
                done: () {
                  setState(() {
                    canResend = true;
                  });
                },
                secondsRemaining: 60,
              ),
              SizedBox(height: 15),
              // Resend OTP button
              if (canResend)
                TextButton(
                  onPressed: registerProvider.loading ? null : _onResendOtp,
                  child: Text(
                    context.translate('login.resendOtp'),
                    style: TextStyle(
                      color: registerProvider.loading ? Colors.grey : Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}