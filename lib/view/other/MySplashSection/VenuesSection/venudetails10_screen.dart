import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:night_life/utilities/app_button.dart';
import 'package:night_life/utilities/app_font.dart';
import 'package:night_life/utilities/app_header.dart';
import 'package:night_life/utilities/app_language.dart';
import 'package:night_life/view/other/MySplashSection/VenuesSection/venuedetails8_screen.dart';

import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_image.dart';

class CompletePayment extends StatefulWidget {
  const CompletePayment({super.key});

  @override
  State<CompletePayment> createState() => _CompletePaymentState();
}

class _CompletePaymentState extends State<CompletePayment> {
  final Map<String, String> terms = {
    'totalcharge': '14999',
    'covercharge': '50',
    'bookingfee': '1416',
    'discount': '-10',
    'taxes': 'Included',
    'total': '14,818',
  };
  int select = 0;
  bool isCouponSelected = false;
  TextEditingController couponController = TextEditingController();
  double discountAmount = 0;
  double totalAmount = 0;
  @override
  @override
  void initState() {
    super.initState();
    totalAmount = double.parse(terms['total']!.replaceAll(',', ''));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: AppButton(
            text: '${AppLanguage.paySecurelyText[language]} ₹${'450'}',
            onPress: () {
              //  Navigator.push(context,
              //     MaterialPageRoute(builder: (context) =>  SearchScreen()));
            },
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
                            color: AppColor.secondryColor,
                            height: size.width * 5 / 100,
                            width: size.width * 5 / 100,
                            AppImage.backArrowIcon),
                      ),
                      Text(
                        AppLanguage.completeYourPaymentText[language],
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
                  height: size.height * 3 / 100,
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
                                  SizedBox(height: size.height *0.1/100),
                                  Text(
                                    'Bass Drop Fridays',
                                    style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                        color: AppColor.secondryColor),
                                  ),
                            SizedBox(height: size.height *0.1/100),
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
                                  AppImage.eventimg,
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
                          Text(
                            AppLanguage.priceBreakdownText[language],
                            style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColor.secondryColor),
                          ),
                          SizedBox(
                            height: size.height * 2 / 100,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(
                                  thickness: 0.3,
                                  color: AppColor.secondryColor),
                              SizedBox(height: size.height * 0.02),

                              // Total charges
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Charges',
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: AppColor.pinkColor,
                                    ),
                                  ),
                                  Text(
                                    '₹${terms['totalcharge']}',
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColor.secondryColor,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: size.height * 0.02),
                              Divider(
                                  thickness: 0.2,
                                  color: AppColor.secondryColor),
                              SizedBox(height: size.height * 0.01),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Cover charge',
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: AppColor.pinkColor,
                                    ),
                                  ),
                                  Text(
                                    '₹${terms['covercharge']}',
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColor.secondryColor,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: size.height * 0.02),
                              Divider(
                                  thickness: 0.2,
                                  color: AppColor.secondryColor),

                              // Booking fee
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppLanguage.bookingfeeText[language],
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          color: AppColor.pinkColor,
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.02),
                                      Image.asset(
                                          height: size.width * 3 / 100,
                                          width: size.width * 3 / 100,
                                          AppImage.upArrow),
                                    ],
                                  ),
                                  Text(
                                    '₹${terms['bookingfee']}',
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColor.secondryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),

                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Base Price",
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: AppColor.lightGreyColor,
                                      ),
                                    ),
                                    Text(
                                      '₹${terms['bookingfee']}',
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: AppColor.secondryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: size.height * 0.01),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Integrated GST (IGST) @18%",
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: AppColor.lightGreyColor,
                                      ),
                                    ),
                                    Text(
                                      '₹${terms['bookingfee']}',
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: AppColor.secondryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),

                              // Coupon checkbox section
                              Row(
                                children: [
                                  Text(
                                    "Coupon Code",
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      color: AppColor.pinkColor,
                                    ),
                                  ),
                                  Checkbox(
                                    value: isCouponSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        isCouponSelected = value!;
                                        if (!isCouponSelected) {
                                          discountAmount = 0;
                                          totalAmount = double.parse(
                                              terms['total']!
                                                  .replaceAll(',', ''));
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (isCouponSelected)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: couponController,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Enter Coupon Code",
                                          hintStyle: const TextStyle(
                                            color: Color(0xffB7AFC9),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          filled: true,
                                          fillColor: Color(0xff1E1A24),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 16),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (couponController.text.trim() ==
                                              "SAVE10") {
                                            double discountPercentage =
                                                double.parse(
                                                    terms['discount']!); // -10
                                            discountAmount = (totalAmount *
                                                    discountPercentage.abs()) /
                                                100;
                                          } else {
                                            discountAmount = 0;
                                          }

                                          totalAmount = double.parse(
                                                  terms['total']!
                                                      .replaceAll(',', '')) -
                                              discountAmount;
                                        });
                                      },
                                      child: const Text("Apply"),
                                    ),
                                  ],
                                ),
                              if (discountAmount > 0)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Discount",
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: AppColor.pinkColor,
                                      ),
                                    ),
                                    Text(
                                      "- ₹$discountAmount",
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                        color: AppColor.secondryColor,
                                      ),
                                    ),
                                  ],
                                ),

                              Divider(
                                  thickness: 0.2,
                                  color: AppColor.secondryColor),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLanguage.totalText[language],
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppColor.pinkColor,
                                    ),
                                  ),
                                  Text(
                                    "₹$totalAmount",
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: AppColor.secondryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   height: size.height * 4 / 100,
                          // ),
                          // Text(
                          //   AppLanguage.paymentMethodsText[language],
                          //   style: TextStyle(
                          //       fontFamily: AppFont.fontFamily,
                          //       fontWeight: FontWeight.w700,
                          //       fontSize: 18,
                          //       color: AppColor.secondryColor),
                          // ),
                          SizedBox(
                            height: size.height * 4 / 100,
                          ),
                          // Column(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Row(
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Row(
                          //           children: [
                          //             Image.asset(
                          //                 height: size.width * 6 / 100,
                          //                 width: size.width * 6 / 100,
                          //                 AppImage.rupeesIcon),
                          //             SizedBox(
                          //               width: size.width * 6 / 100,
                          //             ),
                          //             Text(
                          //               AppLanguage.upiText[language],
                          //               style: TextStyle(
                          //                   fontFamily: AppFont.fontFamily,
                          //                   fontWeight: FontWeight.w400,
                          //                   fontSize: 16,
                          //                   color: AppColor.secondryColor),
                          //             ),
                          //           ],
                          //         ),

                          //         // SizedBox(
                          //         //   width: size.width * 65 / 100,
                          //         // ),
                          //         GestureDetector(
                          //           onTap: () {
                          //             setState(() {
                          //               select = 1;
                          //             });
                          //           },
                          //           child: Container(
                          //             height: size.height * 2.5 / 100,
                          //             width: size.height * 2.5 / 100,
                          //             decoration: BoxDecoration(
                          //               shape: BoxShape.circle,
                          //               border: Border.all(
                          //                 color: select == 1
                          //                     ? AppColor.darkPurpleColor
                          //                     : AppColor.lightgreyColor,
                          //                 width: 2,
                          //               ),
                          //             ),
                          //             child: Center(
                          //               child: Container(
                          //                 height: size.height * 1.4 / 100,
                          //                 width: size.height * 1.4 / 100,
                          //                 decoration: BoxDecoration(
                          //                   shape: BoxShape.circle,
                          //                   color: select == 1
                          //                       ? AppColor.darkPurpleColor
                          //                       : Colors.transparent,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //     SizedBox(
                          //       height: size.height * 4 / 100,
                          //     ),
                          //     Row(
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Row(
                          //           children: [
                          //             Image.asset(
                          //                 height: size.width * 6 / 100,
                          //                 width: size.width * 6 / 100,
                          //                 AppImage.debitCardIcon),
                          //             SizedBox(
                          //               width: size.width * 6 / 100,
                          //             ),
                          //             Text(
                          //               AppLanguage.debitCreditText[language],
                          //               style: TextStyle(
                          //                   fontFamily: AppFont.fontFamily,
                          //                   fontWeight: FontWeight.w400,
                          //                   fontSize: 16,
                          //                   color: AppColor.secondryColor),
                          //             ),
                          //           ],
                          //         ),
                          //         //    SizedBox(
                          //         //   width: size.width * 42 / 100,
                          //         // ),
                          //         GestureDetector(
                          //           onTap: () {
                          //             setState(() {
                          //               select = 3;
                          //             });
                          //           },
                          //           child: Container(
                          //             height: size.height * 2.5 / 100,
                          //             width: size.height * 2.5 / 100,
                          //             decoration: BoxDecoration(
                          //               shape: BoxShape.circle,
                          //               border: Border.all(
                          //                 color: select == 3
                          //                     ? AppColor.darkPurpleColor
                          //                     : AppColor.lightgreyColor,
                          //                 width: 2,
                          //               ),
                          //             ),
                          //             child: Center(
                          //               child: Container(
                          //                 height: size.height * 1.4 / 100,
                          //                 width: size.height * 1.4 / 100,
                          //                 decoration: BoxDecoration(
                          //                   shape: BoxShape.circle,
                          //                   color: select == 3
                          //                       ? AppColor.darkPurpleColor
                          //                       : Colors.transparent,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //     SizedBox(
                          //       height: size.height * 4 / 100,
                          //     ),
                          //     Row(
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
                          //       children: [
                          //         Row(
                          //           children: [
                          //             Image.asset(
                          //                 height: size.width * 6 / 100,
                          //                 width: size.width * 6 / 100,
                          //                 AppImage.walletIcon),
                          //             SizedBox(
                          //               width: size.width * 6 / 100,
                          //             ),
                          //             Text(
                          //               AppLanguage.walletAppPayText[language],
                          //               style: TextStyle(
                          //                   fontFamily: AppFont.fontFamily,
                          //                   fontWeight: FontWeight.w400,
                          //                   fontSize: 16,
                          //                   color: AppColor.secondryColor),
                          //             ),
                          //           ],
                          //         ),

                          //         GestureDetector(
                          //           onTap: () {
                          //             setState(() {
                          //               select = 2;
                          //             });
                          //           },
                          //           child: Container(
                          //             height: size.height * 2.5 / 100,
                          //             width: size.height * 2.5 / 100,
                          //             decoration: BoxDecoration(
                          //               shape: BoxShape.circle,
                          //               border: Border.all(
                          //                 color: select == 2
                          //                     ? AppColor.darkPurpleColor
                          //                     : AppColor.lightgreyColor,
                          //                 width: 2,
                          //               ),
                          //             ),
                          //             child: Center(
                          //               child: Container(
                          //                 height: size.height * 1.4 / 100,
                          //                 width: size.height * 1.4 / 100,
                          //                 decoration: BoxDecoration(
                          //                   shape: BoxShape.circle,
                          //                   color: select == 2
                          //                       ? AppColor.darkPurpleColor
                          //                       : Colors.transparent,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ],
                          // ),

                          SizedBox(
                            height: size.height * 20 / 100,
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
