import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_header.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/city_Preference/vibe_check_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import 'citypreference_screen.dart';


class AboutYouScreen extends StatefulWidget {
  const AboutYouScreen({super.key});

  @override
  State<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends State<AboutYouScreen> {
  final List<String> aboutOptions = [
    "Men",
    "Women",
    "Everyone",
  ];
  final List<String> sexuality = [
    "Straight",
    "Gay",
    "Lesbian",
    "Bisexual",
    "Unsure / Exploring",
  ];
  final List<String> pronouns = [
    "She/Her",
    "He/Him",
    "They/Them",
    "Other",
  ];
  TextEditingController enterYourpronounsController = TextEditingController();
  int selectedIndex = 1;
  int pronounsSelectedIndex = 1;
  int sexualitySelectedIndex = 1;
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
      child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: AppColor.secondryColor,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: AppButton(
                text: '${AppLanguage.continueText[language]}',
                onPress: () {
                   Navigator.push(context,
                      PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: VibeCheckScreen(),
                      duration: const Duration(milliseconds: 500),
                    ),);
                },
              ),
            ),
            body: Container(
              height: size.height * 100 / 100,
              width: size.width * 100 / 100,
              decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
              child: Column(
                children: [
                      SizedBox(
                    height: size.height * 5 / 100,
                  ),
                  Container(
                    width: size.width * 90 / 100,
                    
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Image.asset(
                              color: AppColor.secondryColor,
                              height: size.width * 5 / 100,
                              width: size.width * 4 / 100,
                              AppImage.backArrowIcon),
                        ),
                        Text(
                             AppLanguage.aboutYouText[language],
                          style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColor.secondryColor),
                        ),
                        Container(
                          height: size.width * 5 / 100,
                          width: size.width * 5 / 100,
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 2 / 100,
                  ),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Container(
                        width: size.width * 90 / 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.height * 2 / 100,
                            ),
                            Text(
                              AppLanguage.knowYouBetterText[language],
                              style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor),
                            ),
                            SizedBox(
                              height: size.height * 2 / 100,
                            ),
                            Text(
                               AppLanguage.knowYouBetterMsg[language],
                              style: TextStyle( 
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.listTextColor),
                            ),
                            SizedBox(
                              height: size.height * 4.5 / 100,
                            ),
                            Text(
                              AppLanguage.sexualityText[language],
                              style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor),
                            ),
                            SizedBox(
                              height: size.height * 2.5 / 100,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: sexuality.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: size.height * 1.5 / 100,
                                  ),
                                  child: AboutRow(
                                    text: sexuality[index],
                                    isSelected: sexualitySelectedIndex == index,
                                    onTap: () {
                                      setState(() {
                                        sexualitySelectedIndex = index;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: size.height * 4 / 100,
                            ),
                            Text(
                             AppLanguage.interestedInText[language],
                              style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor),
                            ),
                            SizedBox(
                              height: size.height * 2.5 / 100,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: aboutOptions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: size.height * 1.5 / 100,
                                  ),
                                  child: AboutRow(
                                    text: aboutOptions[index],
                                    isSelected: selectedIndex == index,
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = index;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: size.height * 4 / 100,
                            ),
                            Text(
                             AppLanguage.yourPronounsText[language],
                              style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor),
                            ),
                            SizedBox(
                              height: size.height * 2.5 / 100,
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: pronouns.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: size.height * 1.5 / 100,
                                  ),
                                  child: AboutRow(
                                    text: pronouns[index],
                                    isSelected: pronounsSelectedIndex == index,
                                    onTap: () {
                                      setState(() {
                                        pronounsSelectedIndex = index;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                  
                  
                           
                 Container(
                      width: size.width * 0.9,
                      height: size.height * 0.07,
                      decoration: BoxDecoration(
                        color: AppColor.themeColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
            width: 0.3,
            color: AppColor.pinkColor,
                        ),
                      ),
                      child: Row(
                        children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.05),
              child: Text(
                AppLanguage.enterYourpronounsText[language],
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondryColor,
                ),
              ),
            ),
                      
                        ],
                      ),
                    ),
                            SizedBox(
                              height: size.height * 20 / 100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )),
    );
  }
}

class AboutRow extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const AboutRow({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.07,
        decoration: BoxDecoration(
          color: AppColor.themeColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            width: 0.3,
            color: AppColor.pinkColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: size.width * 0.05),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColor.secondryColor,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.05),
              child: Container(
                height: size.height * 0.03,
                width: size.height * 0.03,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColor.pinkColor
                        : AppColor.pinkColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Container(
                    height: size.height * 0.015,
                    width: size.height * 0.015,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isSelected ? AppColor.pinkColor : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
