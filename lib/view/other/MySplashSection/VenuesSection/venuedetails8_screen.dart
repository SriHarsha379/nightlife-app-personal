import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/reviewbooking_details_screen.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuedetails5_screen.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import 'venuedetails6_screen.dart';

class BookEvent extends StatefulWidget {
  const BookEvent({super.key});

  @override
  State<BookEvent> createState() => _BookEventState();
}

class _BookEventState extends State<BookEvent> {
  List topMeals = [
    {
      "id": 1,
      "name": "GA PHASE-1",
      "price": 3180,
      "seat": 20,
    },
    {
      "id": 2,
      "name": "GA PHASE-2",
      "price": 499,
      "seat": 13,
    },
    {
      "id": 3,
      "name": "GA PHASE-3",
      "price": 4149,
      "seat": 15,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return  AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
              backgroundColor: AppColor.primaryColor,
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
                                      color: AppColor.secondryColor,
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
                                        AppLanguage.bookEventText[language],
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 24,
                                          color: AppColor.secondryColor,
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
                                      AppLanguage.Brewbloomcafetext[language],
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: AppColor.secondryColor,
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
                              color: AppColor.primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColor.secondryColor.withOpacity(0.1),
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
                                    color: AppColor.secondryColor,
                                  ),
                                ),
                                Container(
                                  height: size.height * 4.5 / 100,
                                  width: size.width * 18 / 100,
                                  decoration: BoxDecoration(
                                      color: AppColor.primaryColor,
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
                                            color: AppColor.secondryColor,
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
                                  borderRadius: BorderRadius.circular(40)),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: size.width * 1.2 / 100,
                                  ),
                                  Container(
                                    width: size.width * 32 / 100,
                                    height: size.height * 4.2 / 100,
                                    decoration: BoxDecoration(
                                        color: AppColor.secondryColor,
                                        borderRadius:
                                            BorderRadius.circular(44)),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              3 /
                                              100,
                                          vertical: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              1 /
                                              100,
                                        ),
                                        child: Text(
                                          "One Day Pass",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontFamily: AppFont.fontFamily,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.primaryColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        3 /
                                        100,
                                  ),
                                  Container(
                                    child: Text(
                                      AppLanguage.mutidayText[language],
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.secondryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              // scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: topMeals
                                  .length, // your list of BookEvent items
                              itemBuilder: (context, index) {
                                final item = topMeals[index];
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Container(
                                        //   height: size.height * 14 / 100,
                                        //   width: size.width * 30 / 100,
                                        //   decoration: BoxDecoration(
                                        //     borderRadius:
                                        //         BorderRadius.circular(
                                        //             15), // slightly rounded corners
                                        //     image: DecorationImage(
                                        //       image: AssetImage(
                                        //           item['image']),
                                        //       fit: BoxFit.cover,
                                        //     ),
                                        //   ),
                                        // ),
                        
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['name'],
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily1,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColor.listTextColor,
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
                                                        AppColor.secondryColor,
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
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color:
                                                        AppColor.listTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    size.height * 1.5 / 100),
                                          ],
                                        ),
                                        Container(
                                          height: size.height * 3.5 / 100,
                                          width: size.width * 20 / 100,
                                          decoration: BoxDecoration(
                                            color: AppColor.secondryColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              AppLanguage.selectText[language],
                                              style: TextStyle(
                                                  fontFamily:
                                                      AppFont.fontFamily,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.primaryColor),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: size.height * 5.5 / 100),
                            Column(
                              children: [
                                customDropContainer(
                                  title: "View Event Layout",
                                  onTap: () {},
                                ),
                                customDropContainer(
                                  title: "Prohibited Items",
                                  onTap: () {},
                                ),
                                customDropContainer(
                                  title: "Frequently Asked Questions",
                                  onTap: () {},
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

  Widget customDropContainer({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0F29), // background color
          borderRadius: BorderRadius.circular(30),
        ),
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
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
