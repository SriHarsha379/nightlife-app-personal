import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_language.dart';
import '../../utilities/app_button.dart';

/// A real "Contact Us" screen — previously
/// PostApiProvider.contactUsApiCalling existed (posts to
/// common/send_messageTo_admin) but nothing in the app ever navigated
/// here to actually call it, so there was no way to reach a contact form
/// at all.
class ContactUsScreen extends StatefulWidget {
  static String routeName = './ContactUsScreen';
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(BuildContext context, String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColor.secondryColor(context).withOpacity(0.5),
        fontFamily: AppFont.fontFamily,
        fontSize: 14,
      ),
      filled: true,
      fillColor: AppColor.filledcolor(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _submit(BuildContext context, PostApiProvider apiProvider) {
    if (!_formKey.currentState!.validate()) return;
    apiProvider.contactUsApiCalling(
      context,
      _nameController.text.trim(),
      _emailController.text.trim(),
      _messageController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final apiProvider = Provider.of<PostApiProvider>(context);
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: SafeArea(
          child: Column(
            children: [
              AppHeader(
                text: AppLanguage.contactUsText[language],
                onPress: () => Navigator.pop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 6 / 100,
                    vertical: size.height * 3 / 100,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Have a question or feedback? Send us a message and we'll get back to you.",
                          style: TextStyle(
                            color: AppColor.secondryColor(context).withOpacity(0.7),
                            fontFamily: AppFont.fontFamily,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: size.height * 3 / 100),
                        TextFormField(
                          controller: _nameController,
                          style: TextStyle(color: AppColor.secondryColor(context)),
                          decoration: _decoration(context, "Your name"),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Please enter your name" : null,
                        ),
                        SizedBox(height: size.height * 2 / 100),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: AppColor.secondryColor(context)),
                          decoration: _decoration(context, "Your email"),
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return "Please enter your email";
                            if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
                              return "Enter a valid email address";
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 2 / 100),
                        TextFormField(
                          controller: _messageController,
                          maxLines: 6,
                          style: TextStyle(color: AppColor.secondryColor(context)),
                          decoration: _decoration(context, "How can we help?"),
                          validator: (v) =>
                          (v == null || v.trim().isEmpty) ? "Please enter a message" : null,
                        ),
                        SizedBox(height: size.height * 4 / 100),
                        AppButton(
                          text: apiProvider.loading ? "Sending..." : "Send Message",
                          onPress: apiProvider.loading
                              ? () {}
                              : () => _submit(context, apiProvider),
                        ),
                      ],
                    ),
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