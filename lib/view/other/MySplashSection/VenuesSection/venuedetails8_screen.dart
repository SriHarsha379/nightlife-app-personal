import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/reviewbooking_details_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';

class BookEvent extends StatefulWidget {
  const BookEvent({super.key});

  @override
  State<BookEvent> createState() => _BookEventState();
}

class _BookEventState extends State<BookEvent> {
  List topMeals = [
    {
      "id": 1,
      "name": "GA Phase-1",
      "price": 3180,
      "seat": 20,
    },
    {
      "id": 2,
      "name": "GA Phase-2",
      "price": 499,
      "seat": 13,
    },
    {
      "id": 3,
      "name": "VIP Zone",
      "price": 4149,
      "seat": 15,
    },
  ];
  Set<int> selectedIndexes = {};
  int selectedPassIndex = 0;

  // Track which containers are expanded
  bool isEventLayoutExpanded = false;
  bool isProhibitedItemsExpanded = false;
  bool isFAQExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
              backgroundColor: AppColor.primaryColor(context),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: AppButton(
                    text: '${AppLanguage.continueText[language]}',
                    onPress: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: ReviewBookingDetails(),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    }),
              ),
              body: Container(
                  height: size.height * 100 / 100,
                  width: size.width * 100 / 100,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 2 / 100,
                        ),
                        Stack(
                          children: [
                            Image.asset(
                              AppImage.concertImage,
                              width: size.width * 100 / 100,
                              height: size.height * 30 / 100,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: size.height * 4 / 100,
                              left: size.width * 5 / 100,
                              child: Container(
                                width: size.width * 8 / 100,
                                height: size.width * 8 / 100,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Center(
                                    child: Image.asset(
                                      AppImage.backarrow,
                                      width: size.width * 5 / 100,
                                      height: size.width * 5 / 100,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.height * 0.9 / 100,
                        ),
                        SizedBox(
                          width: size.width * 90 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: size.width * 76 / 100,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Book Event",
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 2 / 100,
                                  ),
                                  SizedBox(
                                    width: size.width * 75 / 100,
                                    child: Text(
                                      AppLanguage.BassDropFridaytext[language],
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColor.secondryColor(context),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: size.width * 75 / 100,
                                    child: Text(
                                      "Santacruz East,Mumbai",
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColor.buttonColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: size.width * 12 / 100,
                                child: Image.asset(
                                  AppImage.likeImage,
                                  fit: BoxFit.cover,
                                  height: size.width * 18 / 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * 2.5 / 100,
                        ),
                        Container(
                          height: size.height * 7.5 / 100,
                          width: size.width * 90 / 100,
                          decoration: BoxDecoration(
                              color: AppColor.primaryColor(context),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.secondryColor(context)
                                      .withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: AppColor.pinkColor, width: 0.5)),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: size.width * 1 / 100,
                                ),
                                Text(
                                  AppLanguage.selectNumberGiText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                                Container(
                                  height: size.height * 4.5 / 100,
                                  width: size.width * 18 / 100,
                                  decoration: BoxDecoration(
                                      color: AppColor.primaryColor(context),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                          color: AppColor.pinkColor,
                                          width: 0.5)),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '2',
                                          style: TextStyle(
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                        SizedBox(
                                          width: size.width * 3 / 100,
                                        ),
                                        Image.asset(
                                            height: size.width * 3 / 100,
                                            width: size.width * 3 / 100,
                                            AppImage.downArrow),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: size.width * 1 / 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height * 4 / 100,
                        ),
                        Container(
                          width: size.width * 90 / 100,
                          child: Column(children: [
                            Container(
                              width: size.width * 65 / 100,
                              height: size.height * 5.2 / 100,
                              decoration: BoxDecoration(
                                color: AppColor.washpressColor,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: size.width * 1.2 / 100),

                                  /// -------- ONE DAY PASS --------
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPassIndex = 0;
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 30 / 100,
                                      height: size.height * 4.2 / 100,
                                      decoration: BoxDecoration(
                                        color: selectedPassIndex == 0
                                            ? AppColor.secondryColor(context)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(44),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: size.width * 3 / 100,
                                            vertical: size.height * 1 / 100,
                                          ),
                                          child: Text(
                                            "One Day Pass",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: selectedPassIndex == 0
                                                  ? AppColor.primaryColor(
                                                      context)
                                                  : AppColor.secondryColor(
                                                      context),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: size.width * 2 / 100),

                                  /// -------- MULTI DAY PASS --------
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedPassIndex = 1;
                                      });
                                    },
                                    child: Container(
                                      width: size.width * 30 / 100,
                                      height: size.height * 4.2 / 100,
                                      decoration: BoxDecoration(
                                        color: selectedPassIndex == 1
                                            ? AppColor.secondryColor(context)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(44),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLanguage.mutidayText[language],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: AppFont.fontFamily,
                                            fontWeight: FontWeight.w500,
                                            color: selectedPassIndex == 1
                                                ? AppColor.primaryColor(context)
                                                : AppColor.secondryColor(
                                                    context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: topMeals.length,
                              itemBuilder: (context, index) {
                                final item = topMeals[index];
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColor.listTextColor(
                                                    context),
                                              ),
                                            ),
                                            SizedBox(
                                                height:
                                                    size.height * 0.5 / 100),
                                            Row(
                                              children: [
                                                Text(
                                                  '₹ ${item['price']}',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily1,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context),
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                        size.width * 0.5 / 100),
                                                Text(
                                                  ' • ${item['seat']} seats left',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppFont.fontFamily1,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color:
                                                        AppColor.listTextColor(
                                                            context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    size.height * 1.5 / 100),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (selectedIndexes
                                                  .contains(index)) {
                                                selectedIndexes.remove(index);
                                              } else {
                                                selectedIndexes.add(index);
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: size.height * 3.5 / 100,
                                            width: size.width * 20 / 100,
                                            decoration: BoxDecoration(
                                              color: selectedIndexes
                                                      .contains(index)
                                                  ? AppColor
                                                      .logoutContainerColor(
                                                          context)
                                                  : AppColor.secondryColor(
                                                      context),
                                              border: Border.all(
                                                width: 1,
                                                color: selectedIndexes
                                                        .contains(index)
                                                    ? AppColor.pinkColor
                                                    : AppColor.secondryColor(
                                                        context),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Center(
                                              child: Text(
                                                selectedIndexes.contains(index)
                                                    ? "Done"
                                                    : AppLanguage
                                                        .selectText[language],
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: selectedIndexes
                                                          .contains(index)
                                                      ? AppColor.secondryColor(
                                                          context)
                                                      : AppColor.primaryColor(
                                                          context),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: size.height * 3 / 100),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: size.height * 5.5 / 100),
                            Column(
                              children: [
                                // View Event Layout
                                customExpandableContainer(
                                  title: "View Event Layout",
                                  isExpanded: isEventLayoutExpanded,
                                  onTap: () {
                                    setState(() {
                                      isEventLayoutExpanded =
                                          !isEventLayoutExpanded;
                                    });
                                  },
                                  child: _buildEventLayout(size),
                                ),

                                // Prohibited Items
                                customExpandableContainer(
                                  title: "Prohibited Items",
                                  isExpanded: isProhibitedItemsExpanded,
                                  onTap: () {
                                    setState(() {
                                      isProhibitedItemsExpanded =
                                          !isProhibitedItemsExpanded;
                                    });
                                  },
                                  child: _buildProhibitedItems(),
                                ),

                                // FAQ
                                customExpandableContainer(
                                  title: "Frequently Asked Questions",
                                  isExpanded: isFAQExpanded,
                                  onTap: () {
                                    setState(() {
                                      isFAQExpanded = !isFAQExpanded;
                                    });
                                  },
                                  child: _buildFAQ(),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 20 / 100,
                            )
                          ]),
                        ),
                      ],
                    ),
                  )))),
    );
  }

  Widget customExpandableContainer({
    required String title,
    required bool isExpanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A0F29),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLayout(Size size) {
    return Column(
      children: [
        // Stage Section
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              "STAGE",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
        // VIP and GA Area
        Container(
          height: 280,
          decoration: BoxDecoration(
            color: Colors.purple.shade900,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              // VIP Area
              Positioned(
                top: 15,
                left: 15,
                right: 15,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "VIP AREA",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              // GA Area
              Positioned(
                top: 80,
                left: 15,
                right: 15,
                bottom: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.purple.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "GA AREA",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 30),
                      // Center Rectangle
                      Container(
                        width: 60,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        // Notes
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey,
              size: 14,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                "This layout is not drawn to the actual scale of the venue.",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.square,
              color: Colors.grey,
              size: 14,
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                "Sold Out / Unavailable tickets are marked in grey",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProhibitedItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBulletPoint("Outside food and beverages"),
        _buildBulletPoint("Professional cameras and recording equipment"),
        _buildBulletPoint("Weapons or sharp objects"),
        _buildBulletPoint("Illegal substances"),
      ],
    );
  }

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFAQItem(
          "What time does the event start?",
          "The event starts at 8:00 PM.",
        ),
        SizedBox(height: 12),
        _buildFAQItem(
          "Is parking available?",
          "Yes, parking is available at the venue.",
        ),
        SizedBox(height: 12),
        _buildFAQItem(
          "Can I get a refund?",
          "Refunds are available up to 48 hours before the event.",
        ),
        SizedBox(height: 12),
        _buildFAQItem(
          "Is outside food allowed?",
          "No, outside food is not permitted inside the venue.",
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              color: AppColor.secondryColor(context),
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColor.secondryColor(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            color: AppColor.secondryColor(context),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4),
        Text(
          answer,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
