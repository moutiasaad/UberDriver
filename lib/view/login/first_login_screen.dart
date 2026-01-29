
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_driver/shared/language/extension.dart';

import '../../../providers/register_provider.dart';
import '../../models/register_model.dart';
import '../../shared/components/buttons/default_button.dart';
import '../../shared/components/text/CText.dart';
import '../../shared/components/text_fields/default_form_field.dart';
import '../../shared/logique_function/validater.dart';
import '../../utils/app_images.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/colors.dart';

class FirstLoginScreen extends StatefulWidget {
  const FirstLoginScreen({
    super.key,
    required this.data,
    required this.forword,
  });

  final RegisterModel data;
  final Function forword;

  @override
  State<FirstLoginScreen> createState() => _FirstLoginScreenState();
}

class _FirstLoginScreenState extends State<FirstLoginScreen> {
  var formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill email if already exists in data
    if (widget.data.email != null && widget.data.email!.isNotEmpty) {
      emailController.text = widget.data.email!;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerProvider = Provider.of<RegisterProvider>(context);

    return Scaffold(
      backgroundColor: BackgroundColor.background,
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/tshl_tawsil_captin_icon.png',
                    width: 145,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),
                cText(
                  text: context.translate('login.welcome'),
                  style: AppTextStyle.regularBlack1_16,
                  pBottom: 25,
                ),
                DefaultFormField(
                  contoller: emailController,
                  type: TextInputType.emailAddress,
                  label: context.translate('login.email'),
                  validate: (value) {
                    if (value.toString().isEmpty) {
                      return context.translate('errorsMessage.emailEmpty');
                    } else if (!isValidEmail(value)) {
                      return context.translate('errorsMessage.emailInvalid');
                    }
                    // Check for API validation errors
                    if (registerProvider.errors.containsKey('email') &&
                        registerProvider.errors['email'] != null) {
                      return registerProvider.errors['email'][0];
                    }
                    return null;
                  },
                ),
                // Show error message if exists
                if (registerProvider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      registerProvider.errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
                DefaultButton(
                  loading: registerProvider.loading,
                  text: context.translate('buttons.login'),
                  pressed: () {
                    // Prevent multiple submissions
                    if (registerProvider.loading) {
                      return;
                    }

                    // Clear previous errors
                    registerProvider.clearErrors();

                    if (formKey.currentState!.validate()) {
                      // Store email in data model
                      widget.data.email = emailController.text.trim();

                      // Call sendOtp API
                      registerProvider.sendOtp(
                        widget.data,
                        context,
                        widget.forword,
                      );
                    }
                  },
                  activated: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}