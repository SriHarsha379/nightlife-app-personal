import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_button.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venudetails7_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_image.dart';

class ReviewBooking2Details extends StatefulWidget {
  ReviewBooking2Details({super.key});

  @override
  State<ReviewBooking2Details> createState() => _ReviewBooking2DetailsState();
}

class _ReviewBooking2DetailsState extends State<ReviewBooking2Details> {
  List<Map<String, String>> termsList = [
    {
      'id': '1',
      'text': 'Arrive 15 minutes early.',
    },
    {
      'id': '2',
      'text': 'Valid for the selected number of guests.',
    },
    {
      'id': '3',
      'text': 'Cover charges apply as per restaurant discretion.',
    },
    {
      'id': '4',
      'text': 'Offers valid only via app payment.',
    },
    {
      'id': '5',
      'text': 'Cover charges non-refundable if cancelled late.',
    },
  ];
  int select = 0;
  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor(context),
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20), // adjust as needed
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        select = select == 1 ? 0 : 1;
                      });
                    },
                    child: Container(
                      height: size.height * 3 / 100,
                      width: size.height * 3 / 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: select == 1
                              ? AppColor.darkPurpleColor
                              : AppColor.lightgreyColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          height: size.height * 1.5 / 100,
                          width: size.height * 1.5 / 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: select == 1
                                ? AppColor.darkPurpleColor
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 1 / 100),
                  Text(
                    'Accept the terms and conditions',
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColor.lightGreyColor(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 1 / 100),
              AppButton(
                text: AppLanguage.continueText[language],
                onPress: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeftWithFade,
                      child: CompletePayment2(),
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Container(
            height: size.height * 100 / 100,
            width: size.width * 100 / 100,
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 1 / 100,
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
                            color: AppColor.secondryColor(context),
                            height: size.width * 5 / 100,
                            width: size.width * 5 / 100,
                            AppImage.backArrowIcon),
                      ),
                      Text(
                        AppLanguage.reviewBookingDetailsText[language],
                        style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: AppColor.secondryColor(context)),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                  height: size.width * 6 / 100,
                                  width: size.width * 6 / 100,
                                  AppImage.infoIcon),
                              SizedBox(
                                width: size.width * 5 / 100,
                              ),
                              Expanded(
                                child: ExpandableText(
                                  text: AppLanguage.noteMsgText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: size.height * 5 / 100,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${'24${' Oct at'}${' 9:00 PM'} · ${'2 guests'}'}',
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: AppColor.pinkColor),
                                  ),
                                  Text(
                                    'Solaire',
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                  Text(
                                    'Santacruz East, Mumbai',
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: AppColor.pinkColor),
                                  ),
                                ],
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  AppImage.chairsImage,
                                  height: size.height * 9 / 100,
                                  width: size.width * 35 / 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 4 / 100,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLanguage.addSpecialRequestText[language],
                                style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: AppColor.secondryColor(context)),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  AppLanguage.plusText[language],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 30,
                                      color: AppColor.secondryColor(context)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),
                          Text(
                            AppLanguage.yourDetailsText[language],
                            style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColor.secondryColor(context)),
                          ),
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),
                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 30.0),
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: AppColor.secondryColor(
                                                context)),
                                      ),
                                    ),
                                    Text(
                                      'Ethan Carter',
                                      style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColor.pinkColor),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    AppLanguage.editText[language],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 3 / 100,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: size.width * 1 / 100,
                                  ),
                                  Text(
                                    'Phone Number',
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 14.0),
                                    child: Text(
                                      '+91 9876543210',
                                      style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColor.pinkColor),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  AppLanguage.editText[language],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: AppColor.secondryColor(context)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 3 / 100,
                          ),
                          SizedBox(
                            width: size.width * 92 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 51.0),
                                      child: Text(
                                        'Email id',
                                        style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: AppColor.secondryColor(
                                                context)),
                                      ),
                                    ),
                                    Text(
                                      'carter@gmail.com',
                                      style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColor.pinkColor),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    AppLanguage.editText[language],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 3 / 100,
                          ),
                          SizedBox(
                            width: size.width * 90 / 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 30.0),
                                      child: Text(
                                        'Select City',
                                        style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            color: AppColor.secondryColor(
                                                context)),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 81.0),
                                      child: Text(
                                        'Delhi',
                                        style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: AppColor.pinkColor),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    AppLanguage.editText[language],
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 3 / 100,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isOpen = !isOpen; // toggle open/close
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLanguage.termAndconditionsText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                                Transform.rotate(
                                  angle: isOpen ? 0 : 3.14,
                                  child: Image.asset(
                                    AppImage.downArrow,
                                    height: size.height * 2 / 100,
                                    width: size.width * 4 / 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),
                          if (isOpen)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: termsList.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Text(
                                    termsList[index]['text']!,
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                );
                              },
                            ),
                          SizedBox(
                            height: size.height * 15 / 100,
                          ),
                        ],
                      ),
                    )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ExpandableText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isExpanded = !isExpanded;
        });
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: ConstrainedBox(
          constraints: isExpanded
              ? const BoxConstraints()
              : const BoxConstraints(maxHeight: 25),
          child: Text(
            widget.text,
            style: widget.style,
            overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            softWrap: true,
          ),
        ),
      ),
    );
  }
}
