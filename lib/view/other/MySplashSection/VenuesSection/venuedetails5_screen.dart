import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuedetails6_screen.dart';
import 'package:night_life/view/other/calender_screen.dart';
import 'package:night_life/view/other/calenderscreen1.dart';
import 'package:page_transition/page_transition.dart';

import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';

class BookTable extends StatefulWidget {
  const BookTable({super.key});

  @override
  State<BookTable> createState() => _BookTableState();
}

class _BookTableState extends State<BookTable> {
  List topMeals = [
    {
      "id": 1,
      "name": "VIP Zone",
      "price": 3180,
      "seat": 20,
      "image": "assets/icons/vipzone.png",
    },
    {
      "id": 2,
      "name": "Fan Pit",
      "price": 499,
      "seat": 13,
      "image": "assets/icons/vipzone.png",
    },
    {
      "id": 3,
      "name": "Family Zone",
      "price": 4149,
      "seat": 15,
      "image": "assets/icons/vipzone.png",
    },
    {
      "id": 4,
      "name": "Bronze Standing",
      "price": 4180,
      "seat": 17,
      "image": "assets/icons/vipzone.png",
    },
    {
      "id": 5,
      "name": "Lounge Chair",
      "price": 4499,
      "seat": 70,
      "image": "assets/icons/vipzone.png",
    },
    {
      "id": 6,
      "name": "Group of Four",
      "price": 1449,
      "seat": 30,
      "image": "assets/icons/vipzone.png",
    },
  ];

  int selectedIndex = 0; // by default, first selected
  int dateindex = 0; // by default, first selected
  int select = 0; 

  final List<Map<String, String>> dates = [
    {'day': 'Today', 'date': '24 Oct'},
    {'day': 'Tomorrow', 'date': '25 Oct'},
    {'day': 'Saturday', 'date': '26 Oct'},
  ];

  final List<Map<String, String>> timeSlots = [
    {'time': '8:00 PM', 'discount': '10%'},
    {'time': '8:30 PM', 'discount': '10%'},
    {'time': '9:00 PM', 'discount': '10%'},
    {'time': '9:30 PM', 'discount': '10%'},
    {'time': '10:00 PM', 'discount': '10%'},
    {'time': '10:30 PM', 'discount': '10%'},
  ];

  @override
  Widget build(BuildContext context) {
    
    final size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
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
                        child: ReviewBooking2Details(),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
              ),
              body: Container(
                  height: size.height * 100 / 100,
                  width: size.width * 100 / 100,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: size.height * 1 / 100,
                        ),
                        Stack(
                          children: [
                            Image.asset(
                              AppImage.brewandbloomIcon,
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
                          height: size.height * 1 / 100,
                        ),
                        Container(
                          width: size.width * 90 / 100,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: size.width * 76 / 100,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              AppLanguage.bookTableText[language],
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
                                            AppLanguage
                                                .Brewbloomcafetext[language],
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
                                          color: AppColor.secondryColor
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: size.width * 1 / 100,
                                        ),
                                        Text(
                                          AppLanguage
                                              .selectNumberGiText[language],
                                          style: TextStyle(
                                              color: AppColor.secondryColor),
                                        ),
                                        Container(
                                          height: size.height * 4.5 / 100,
                                          width: size.width * 18 / 100,
                                          decoration: BoxDecoration(
                                              color: AppColor.primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(30),
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
                                                      color:
                                                          AppColor.secondryColor),
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CalendarScreen1()));
                                  },
                                  child: Row(
                                    children: [
                                      Image.asset(
                                          width: size.width * 5 / 100,
                                          height: size.width * 5 / 100,
                                          AppImage.calenderImage),
                                      SizedBox(
                                        width: size.width * 3 / 100,
                                      ),
                                      Text(
                                        AppLanguage.selectDateText[language],
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily1,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: AppColor.secondryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 2 / 100,
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: List.generate(dates.length, (index) {
                                    final isSelect = dateindex == index;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          dateindex = index;
                                        });
                                      },
                                      child: Container(
                                        height: size.height * 7 / 100,
                                        width: size.width * 28 / 100,
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor,
                                          borderRadius: BorderRadius.circular(40),
                                          border: Border.all(
                                            color: isSelect
                                                ? AppColor.pinkColor
                                                : AppColor.secondryColor,
                                            width: 0.8,
                                          ),
                                          boxShadow: [
                                            // BoxShadow(
                                            //   color: isSelect
                                            //       ? AppColor.pinkColor
                                            //           .withOpacity(0.4)
                                            //       : AppColor.secondryColor
                                            //           .withOpacity(0.1),
                                            //   spreadRadius: 2,
                                            //   blurRadius: 8,
                                            //   offset: const Offset(0, 4),
                                            // ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              dates[index]['day']!,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily1,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: isSelect
                                                    ? AppColor.pinkColor
                                                    : AppColor.secondryColor,
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.5 / 100),
                                            Text(
                                              dates[index]['date']!,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily1,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: isSelect
                                                    ? AppColor.pinkColor
                                                    : AppColor.secondryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                // Container(
                                //   height: size.height * 7.5 / 100,
                                //   width: size.width * 30 / 100,
                                //   decoration: BoxDecoration(
                                //       color: AppColor.primaryColor,
                                //       boxShadow: [
                                //         BoxShadow(
                                //           color: AppColor.secondryColor
                                //               .withOpacity(0.1),
                                //           spreadRadius: 2,
                                //           blurRadius: 8,
                                //           offset: const Offset(0, 4),
                                //         ),
                                //       ],
                                //       borderRadius: BorderRadius.circular(30),
                                //       border: Border.all(
                                //           color: AppColor.pinkColor, width: 0.5)),
                                //   child: Column(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       Text(
                                //         'Today',
                                //         style: TextStyle(
                                //           fontFamily: AppFont.fontFamily1,
                                //           fontWeight: FontWeight.w600,
                                //           fontSize: 14,
                                //           color: AppColor.secondryColor,
                                //         ),
                                //       ),
                                //       SizedBox(
                                //         height: size.height * 0.5 / 100,
                                //       ),
                                //       Text(
                                //         '24 Oct',
                                //         style: TextStyle(
                                //           fontFamily: AppFont.fontFamily1,
                                //           fontWeight: FontWeight.w600,
                                //           fontSize: 14,
                                //           color: AppColor.secondryColor,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: size.height * 4 / 100,
                                // ),
                                SizedBox(
                                  height: size.height * 3 / 100,
                                ),
                                Text(
                                  AppLanguage.selectTimeDayText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily1,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColor.secondryColor,
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 2 / 100,
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 18,
                                  children:
                                      List.generate(timeSlots.length, (index) {
                                    final isSelected = selectedIndex == index;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedIndex = index;
                                        });
                                      },
                                      child: Container(
                                        height: size.height * 8.5 / 100,
                                        width: size.width * 28 / 100,
                                        decoration: BoxDecoration(
                                          color: AppColor.primaryColor,
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColor.pinkColor
                                                : AppColor.secondryColor,
                                            width: 0.8,
                                          ),
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: isSelected
                                          //         ? AppColor.pinkColor
                                          //             .withOpacity(0.4)
                                          //         : AppColor.secondryColor
                                          //             .withOpacity(0.1),
                                          //     spreadRadius: 2,
                                          //     blurRadius: 8,
                                          //     offset: const Offset(0, 4),
                                          //   ),
                                          // ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              timeSlots[index]['time']!,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily1,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: isSelected
                                                    ? AppColor.pinkColor
                                                    : AppColor.secondryColor,
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.5 / 100),
                                            Text(
                                              '${timeSlots[index]['discount']!}',
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily1,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                                color: isSelected
                                                    ? AppColor.pinkColor
                                                    : AppColor.secondryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                      SizedBox(
                                  height: size.height * 2 / 100,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'View all slots',
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                        color: AppColor.secondryColor,
                                      ),
                                    ),
                                    SizedBox(
                                      width: size.width * 2 / 100,
                                    ),
                                    Image.asset(
                                        height: size.width * 3 / 100,
                                        width: size.width * 3 / 100,
                                        AppImage.downArrow),
                                  ],
                                ),
      
                                SizedBox(
                                  height: size.height * 6 / 100,
                                ),
                                Container(
                                    height: size.height * 22 / 100,
                                    width: size.width * 90 / 100,
                                    decoration: BoxDecoration(
                                        color: AppColor.primaryColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColor.secondryColor
                                                .withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: AppColor.pinkColor,
                                            width: 0.5)),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 25),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    select = 0;
                                                  });
                                                },
                                                child: Container(
                                                  height: size.height * 3 / 100,
                                                  width: size.height * 3 / 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: select == 0
                                                          ? AppColor
                                                              .darkPurpleColor
                                                          : AppColor
                                                              .lightgreyColor,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Container(
                                                      height:
                                                          size.height * 1.5 / 100,
                                                      width:
                                                          size.height * 1.5 / 100,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: select == 0
                                                            ? AppColor
                                                                .darkPurpleColor
                                                            : Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 4 / 100,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Flat 10% OFF on total bill',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily1,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14,
                                                      color:
                                                          AppColor.secondryColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    '₹50 cover charge required',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily1,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 14,
                                                      color: AppColor
                                                          .darkPurpleColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: size.height * 1 / 100,
                                          ),
                                          Divider(
                                            color: AppColor.pinkColor,
                                          ),
                                          SizedBox(
                                            height: size.height * 1 / 100,
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    select = 1;
                                                  });
                                                },
                                                child: Container(
                                                  height: size.height * 3 / 100,
                                                  width: size.height * 3 / 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: select == 1
                                                          ? AppColor
                                                              .darkPurpleColor
                                                          : AppColor
                                                              .lightgreyColor,
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Container(
                                                      height:
                                                          size.height * 1.5 / 100,
                                                      width:
                                                          size.height * 1.5 / 100,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: select == 1
                                                            ? AppColor
                                                                .darkPurpleColor
                                                            : Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: size.width * 4 / 100,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Regular table reservation',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily1,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14,
                                                      color:
                                                          AppColor.secondryColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    'No cover charge required',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppFont.fontFamily1,
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 14,
                                                      color: AppColor
                                                          .darkPurpleColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )),
                                SizedBox(
                                  height: size.height * 19 / 100,
                                )
                              ]),
                        ),
                      ],
                    ),
                  )))),
    );
  }
}
