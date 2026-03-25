import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:night_life/utilities/app_language.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_snack_bar_toast_message.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_font.dart';

class DeleteAccountScreen extends StatefulWidget {
  static String routeName = './DeleteAccountScreen';
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  TextEditingController messageTextEditingController = TextEditingController();
  final List<Map<String, String>> selectedMediaList = [];

  @override
  void dispose() {
    messageTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _submitReason() async {
    final description = messageTextEditingController.text.trim();
    if (description.isEmpty) {
      SnackBarToastMessage.info(
          context, AppLanguage.deleteAccountHintText[language]);
      return;
    }

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    await apiProvider.deleteAccountApiCalling(
        context, messageTextEditingController.text);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: Container(
          width: size.width,
          height: size.height,
          color: AppColor.primaryColor(context),
          child: Column(
            children: [
              SizedBox(height: size.height * 5 / 100),
              AppHeader(
                text: AppLanguage.deleteAccount[language],
                onPress: () => Navigator.pop(context),
              ),
              SizedBox(height: size.height * 2 / 100),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 5 / 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Description Heading
                      Container(
                        width: size.width * 90 / 100,
                        child: Text(
                          AppLanguage.deleteAccountDescriptionText[language],
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontSize: 13,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 2 / 100),

                      // SizedBox(height: size.height * 2 / 100),

                      /// Description Field
                      Container(
                        padding: EdgeInsets.symmetric(),
                        decoration: BoxDecoration(
                            color: const Color(0xff36214A),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.appButtonColor)),
                        child: TextField(
                          controller: messageTextEditingController,
                          maxLines: 5,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: AppFont.fontFamily,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                AppLanguage.deleteAccountHintText[language],
                            hintStyle: TextStyle(
                                color: AppColor.filledText(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 15 / 100),

                      Center(
                        child: Consumer<PostApiProvider>(
                          builder: (context, apiprovider, child) {
                            if (apiprovider.loading) {
                              return const CircularProgressIndicator(
                                color: AppColor.pinkColor,
                              );
                            }
                            return GestureDetector(
                              onTap: _submitReason,
                              child: Container(
                                width: MediaQuery.of(context).size.width *
                                    85 /
                                    100,
                                height: MediaQuery.of(context).size.height *
                                    6 /
                                    100,
                                decoration: const BoxDecoration(
                                  color: AppColor.buttonColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  AppLanguage.sendButtonText[language],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 16),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: size.height * 2 / 100),

                      /// Footer Text
                    ],
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
