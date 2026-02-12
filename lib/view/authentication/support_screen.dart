// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:night_life/view/authentication/report_problem.dart';
import 'package:page_transition/page_transition.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/support/faq_controller.dart';
import '../../provider/content_service.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../content_screen/content_screen.dart';
import 'chat_support.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<bool> expanded = [];
  String privacypolicytype = '';
  String termsandconditionstype = '';
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final faqController = Provider.of<FaqController>(context, listen: false);
      faqController.fetchFaqData(context);
      faqController.fetchSupportEmailData(context);
    });
    loadContentData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: size.width,
          height: size.height,
          color: AppColor.primaryColor(context),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 5 / 100),
                AppHeader(
                  onPress: () => Navigator.pop(context),
                  text: AppLanguage.supportText[language],
                ),
                SizedBox(height: size.height * 2 / 100),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17.0),
                  child: Text(
                    AppLanguage.frequenctlyAskedquestions[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),

                Consumer<FaqController>(
                  builder: (context, faqController, child) {
                    final faqList = faqController.getFaqList;
                    if (expanded.length != faqList.length) {
                      expanded = List.generate(faqList.length, (_) => false);
                    }

                    if (faqController.getIsLoading) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: size.height * 3 / 100),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColor.buttonColor,
                          ),
                        ),
                      );
                    }

                    if (faqList.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 5 / 100,
                          vertical: size.height * 2 / 100,
                        ),
                        child: Text(
                          "No FAQ available",
                          style: TextStyle(
                            color: AppColor.notificationtextColor(context),
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: faqList.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;

                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: size.width * 4 / 100,
                            vertical: size.height * 0.8 / 100,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 4 / 100,
                            vertical: size.height * 1.8 / 100,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.notificationContainerColor(context),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.primaryColor(context)
                                    .withOpacity(0.6),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expanded[index] = !expanded[index];
                                  });
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.question,
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontSize: 14,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Transform.rotate(
                                      angle: expanded[index] ? 0 : 3.14,
                                      child: Image.asset(
                                        AppImage.downArrow,
                                        height: size.width * 5 / 100,
                                        width: size.width * 5 / 100,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (expanded[index]) ...[
                                SizedBox(height: size.height * 1 / 100),
                                Text(
                                  item.answer,
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    color:
                                        AppColor.notificationtextColor(context),
                                    fontSize: 14,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17.0, vertical: 10),
                  child: Text(
                    AppLanguage.contactSupportText[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.topToBottom,
                        child: ChatSupport(),
                        duration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColor.notificationContainerColor(context),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor(context),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * 8 / 100,
                              width: size.width * 12 / 100,
                              child: Image.asset(
                                AppImage.messageChatsicon,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: size.width * 2 / 100),
                            Text(
                              AppLanguage.chatWithus[language],
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await Provider.of<FaqController>(context, listen: false)
                        .fetchSupportEmailData(context);
                    if (!context.mounted) return;
                    liveSupportbottomsheet(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColor.notificationContainerColor(context),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor(context),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * 8 / 100,
                          width: size.width * 12 / 100,
                          child: Image.asset(
                            AppImage.headphoneIcon,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: size.width * 2 / 100),
                        Text(
                          AppLanguage.liveSupport[language],
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// --- Privacy Policy Heading Added Below ---

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17.0, vertical: 10),
                  child: Text(
                    AppLanguage.reportAproblemText[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: ReportProblemScreen(),
                        duration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.notificationContainerColor(context),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor(context),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: size.width * 2 / 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * 8 / 100,
                              width: size.width * 12 / 100,
                              child: Image.asset(
                                AppImage.flagIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: size.width * 2 / 100),
                            Text(
                              AppLanguage.reportAproblemText[language],
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 17.0, vertical: 10),
                  child: Text(
                    AppLanguage.legalText[language],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ContentScreen(
                                header:
                                    AppLanguage.termAndconditionsText[language],
                                contenttype: termsandconditionstype,
                              )),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColor.notificationContainerColor(context),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor(context),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.width * 8 / 100,
                              width: size.width * 12 / 100,
                              child: Image.asset(
                                AppImage.termsConditionIcon,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: size.width * 2 / 100),
                            Text(
                              AppLanguage.termsConditionText[language],
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontSize: 14,
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * .2 / 100),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ContentScreen(
                                header: AppLanguage.privacyPolicyText[language],
                                contenttype: privacypolicytype,
                              )),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColor.notificationContainerColor(context),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor(context),
                          spreadRadius: 3,
                          blurRadius: 7,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.width * 8 / 100,
                          width: size.width * 12 / 100,
                          child: Image.asset(
                            AppImage.privacyPolicyIcon,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: size.width * 2 / 100),
                        Text(
                          AppLanguage.privacyPolicy[language],
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
                            fontSize: 14,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void liveSupportbottomsheet(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            width: MediaQuery.of(context).size.width * 95 / 100,
            height: MediaQuery.of(context).size.height * 40 / 100,
            color: Colors.transparent,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 95 / 100,
                  height: MediaQuery.of(context).size.height * 40 / 100,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColor.backgroundGradientcolor(context),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(45),
                              topRight: Radius.circular(45),
                            ),
                          ),
                          width: size.width * 1.0,
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Container(
                                width: size.width * 0.88,
                                child: Column(
                                  children: [
                                    // First Image

                                    Align(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        AppImage.dashIcon,
                                        height: size.height * 0.5 / 100,
                                        width: size.width * 22 / 100,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 4 / 100),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage
                                            .contactSupportText[language],
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 23,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 1 / 100),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: Text(
                                        AppLanguage
                                            .contactSupportHintText[language],
                                        style: TextStyle(
                                          color:
                                              AppColor.secondryColor(context),
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.04),

                                    Consumer<FaqController>(
                                      builder: (context, faqController, child) {
                                        final supportEmail =
                                            faqController.getSupportEmail;
                                        return Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: size.width * 4 / 100,
                                              vertical: size.height * 1.6 / 100,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  AppImage.email,
                                                  height: size.width * 5 / 100,
                                                  width: size.width * 6 / 100,
                                                  fit: BoxFit.contain,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                    width:
                                                        size.width * 3 / 100),
                                                Text(
                                                  "Mail Id: ${supportEmail.isEmpty ? "-" : supportEmail}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                                    SizedBox(height: size.height * 0.03),

                                    Consumer<FaqController>(
                                      builder: (context, faqController, child) {
                                        return GestureDetector(
                                          onTap: () async {
                                            await _openSupportEmail(
                                              faqController.getSupportEmail,
                                            );
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                85 /
                                                100,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                6.5 /
                                                100,
                                            decoration: const BoxDecoration(
                                              color: AppColor.buttonColor,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(40)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              AppLanguage
                                                  .contactSupportText[language],
                                              style: TextStyle(
                                                  color: AppColor.secondryColor(
                                                      context),
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    ).then((_) {});
  }

  Future<void> _openSupportEmail(String email) async {
    final toEmail = email.trim();
    if (toEmail.isEmpty) return;

    final uri = Uri(
      scheme: 'mailto',
      path: toEmail,
      queryParameters: const {
        'subject': 'Support',
      },
    );

    final openedMailApp =
        await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (openedMailApp) return;

    final webCompose = Uri.parse(
      'https://mail.google.com/mail/?view=cm&fs=1&to=$toEmail&su=Support',
    );
    final openedWeb =
        await launchUrl(webCompose, mode: LaunchMode.externalApplication);

    if (!openedWeb && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No email app found")));
    }
  }

  loadContentData() {
    fetchAllContent((List data) {
      for (var item in data) {
        if (item['content_type'] == 1) {
          setState(() {
            privacypolicytype = item['content_url'];
          });
        }

        if (item['content_type'] == 2) {
          setState(() {
            termsandconditionstype = item['content_url'];
          });
        }
      }
    });
  }
}
