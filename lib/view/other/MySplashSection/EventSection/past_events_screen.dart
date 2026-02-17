import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_constant.dart';
import 'package:night_life/utilities/app_language.dart';

import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';

class PastEventScreen extends StatefulWidget {
  const PastEventScreen({super.key});

  @override
  State<PastEventScreen> createState() => _PastEventScreenState();
}

class _PastEventScreenState extends State<PastEventScreen> {
  final List<Map<String, String>> dates = [
    {'day': 'Friday', 'date': '24 Oct'},
    {'day': '9:00', 'date': 'P.M.'},
    {'day': 'One Day', 'date': 'GA Phase-1'},
  ];
  int dateindex = 0;
  int select = 0;
  int selectedEmoji = -1;
  TextEditingController feedbackController = TextEditingController();
  bool showDetails = false;

  List<String> emojis = ["😡", "😞", "😐", "😊", "🤩"];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor(context),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
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
                    text: '${AppLanguage.submitButtonText[language]}',
                    onPress: () {}),
              ),
              body: Container(
                  height: size.height * 100 / 100,
                  width: size.width * 100 / 100,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.03),
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
                          width: size.width * 92 / 100,
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
                                        AppLanguage
                                            .BassDropFridaytext[language],
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
                                  SizedBox(height: size.height * 0.5 / 100),
                                  SizedBox(
                                    width: size.width * 75 / 100,
                                    child: Text(
                                      "Santacruz East, Mumbai",
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.5,
                                        color: AppColor.buttonColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: size.width * 15 / 100,
                                height: size.height * 8 / 100,
                                decoration: BoxDecoration(
                                  color: Colors
                                      .black, // background same as screenshot
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Number of\nguests",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 7,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.5 / 100),
                                    Text(
                                      "2",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * 2 / 100,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Headings Row
                            Row(
                              children: [
                                SizedBox(width: size.width * 15 / 100),
                                Text(
                                  "Date",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.secondryColor(context),
                                    fontFamily: AppFont.fontFamily1,
                                  ),
                                ),
                                SizedBox(width: size.width * 23 / 100),
                                Text(
                                  "Time",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.secondryColor(context),
                                    fontFamily: AppFont.fontFamily1,
                                  ),
                                ),
                                SizedBox(width: size.width * 22 / 100),
                                Text(
                                  "Ticket",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.secondryColor(context),
                                    fontFamily: AppFont.fontFamily1,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: size.height * 1 / 100),

                            // Select Items
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              alignment: WrapAlignment.center,
                              children: List.generate(dates.length, (index) {
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
                                      color: AppColor.primaryColor(context),
                                      borderRadius: BorderRadius.circular(40),
                                      border: Border.all(
                                        color: AppColor.pasttimecolor(context),
                                        width: 0.8,
                                      ),
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
                                            color:
                                                AppColor.pasttimecolor(context),
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
                                            color:
                                                AppColor.pasttimecolor(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),

                            SizedBox(height: size.height * 4 / 100),

                            // ----------------- Your Details -----------------
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: size.width,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 20),
                                    decoration: BoxDecoration(
                                      color: AppColor.bookeventcontainercolor(
                                          context),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // -------- Your Details Title ----------
                                        Text(
                                          "Your Details",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),

                                        SizedBox(height: size.height * 3 / 100),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            infoItem("Phone Number",
                                                "+91 9876543210"),
                                            SizedBox(
                                                height: size.height * 3 / 100),
                                            infoItem(
                                                "Email Id", "carter@gmail.com"),
                                            SizedBox(
                                                height: size.height * 3 / 100),
                                            infoItem("City", "Delhi"),
                                          ],
                                        ),

                                        SizedBox(height: 16),
                                        Divider(
                                            color: Colors.white24,
                                            thickness: 0.6),
                                        SizedBox(height: 16),

                                        // -------- Price breakdown title ----------
                                        Text(
                                          "Price breakdown",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),

                                        SizedBox(height: 16),

                                        detailsRow("Ticket Charges", "₹14,999"),
                                        Divider(
                                            thickness: 0.2,
                                            color: AppColor.secondryColor(
                                                context)),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2 /
                                                100),

                                        detailsRow("Cover charge", "₹50"),
                                        Divider(
                                            thickness: 0.2,
                                            color: AppColor.secondryColor(
                                                context)),

                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2 /
                                                100),

                                        // -------- Expandable Booking Fee ----------
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showDetails = !showDetails;
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Booking Fee",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.white70),
                                                  ),
                                                  SizedBox(width: 6),
                                                  Icon(
                                                    showDetails
                                                        ? Icons
                                                            .keyboard_arrow_down
                                                        : Icons
                                                            .keyboard_arrow_up,
                                                    color:
                                                        AppColor.lightGreyColor(
                                                            context),
                                                  ),
                                                ],
                                              ),
                                              Text("₹1,416",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: AppColor
                                                          .secondryColor(
                                                              context))),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2 /
                                                100),
                                        if (showDetails) ...[
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.2 /
                                                  100),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Base Price",
                                                    style: TextStyle(
                                                        fontSize: 7.30,
                                                        fontFamily:
                                                            AppFont.fontFamily,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Colors.white70),
                                                  ),
                                                ],
                                              ),
                                              Text("₹1200",
                                                  style: TextStyle(
                                                      fontSize: 7.30,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white70)),
                                            ],
                                          ),
                                          SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.6 /
                                                  100),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    "Integrated GST (IGST) @18%",
                                                    style: TextStyle(
                                                        fontSize: 7.30,
                                                        color: Colors.white70),
                                                  ),
                                                ],
                                              ),
                                              Text("₹1,200",
                                                  style: TextStyle(
                                                      fontSize: 7.30,
                                                      color: Colors.white70)),
                                            ],
                                          ),
                                        ],

                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                2 /
                                                100),
                                        detailsRow("Discount", "-10%"),

                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.3 /
                                                100),
                                        Divider(
                                            thickness: 0.2,
                                            color: AppColor.secondryColor(
                                                context)),

                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8 /
                                                100),

                                        // -------- Total Row ----------
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Total",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white70),
                                                ),
                                              ],
                                            ),
                                            Text("₹14,818.5",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontFamily:
                                                        AppFont.fontFamily,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColor.secondryColor(
                                                            context))),
                                          ],
                                        ),

                                        SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                1.6 /
                                                100),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  "Payment Mode",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white70),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: size.width * 15 / 100,
                                              child: Text("UPI",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                          AppFont.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppColor
                                                          .secondryColor(
                                                              context))),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: size.height * 2 / 100),

                            // ------------------- Emoji Rating -----------------------
                            Container(
                              width: size.width * 90 / 100,
                              height: size.height * 27.6 / 100,
                              padding: EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 16),
                              decoration: BoxDecoration(
                                color:
                                    AppColor.bookeventcontainercolor(context),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Heading
                                  Text(
                                    "How’s your experience?",
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.w700,
                                      color: AppColor.secondryColor(context),
                                      fontFamily: AppFont.fontFamily,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: size.height * 1 / 100),

                                  // Subtitle
                                  Text(
                                    "We’d love to know!",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: AppColor.lightGreyColor(context)
                                          .withOpacity(0.8),
                                      fontFamily: AppFont.fontFamily,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: size.height * 3 / 100),

                                  // Divider Line
                                  Container(
                                    height: 1,
                                    width: size.width * 80 / 100,
                                    color: Colors.white24,
                                  ),
                                  SizedBox(height: size.height * 2.6 / 100),

                                  // Emoji Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children:
                                        List.generate(emojis.length, (index) {
                                      final isSelected = selectedEmoji == index;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedEmoji = index;
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          padding: EdgeInsets.all(
                                              isSelected ? 10 : 8),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: isSelected
                                                ? const LinearGradient(
                                                    colors: [
                                                      Color.fromARGB(255, 195,
                                                          151, 236), // purple
                                                      Color.fromARGB(255, 80,
                                                          91, 216), // blue
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  )
                                                : null,
                                            color: isSelected
                                                ? null
                                                : Colors.transparent,
                                          ),
                                          child: Text(
                                            emojis[index],
                                            style:
                                                const TextStyle(fontSize: 30),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: size.height * 2 / 100),

                            // ----------------- Feedback Text Field -----------------------

                            SizedBox(height: size.height * 2 / 100),
                            Container(
                              width: size.width * 90 / 100,
                              height: size.height * 55 / 100,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 18),
                              decoration: BoxDecoration(
                                color:
                                    AppColor.bookeventcontainercolor(context),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Thanks for your feedback!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: AppFont.fontFamily,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  ),

                                  SizedBox(height: size.height * 1 / 100),

                                  Text(
                                    "Your opinion matters. Tell us what worked and what didn’t.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: AppFont.fontFamily,
                                      color: AppColor.lightGreyColor(context),
                                    ),
                                  ),

                                  SizedBox(height: size.height * 1.2 / 100),

                                  Container(
                                    width: size.width,
                                    height: size.height * 0.0025,
                                    color: Colors.white12,
                                  ),

                                  SizedBox(height: size.height * 2.2 / 100),

                                  // Feedback Text Input
                                  Container(
                                    width: size.width * 80 / 100,
                                    height: size.height * 32 / 100,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: AppColor.myperfectcontainercolr(
                                          context),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: TextField(
                                      controller: feedbackController,
                                      maxLines: 8,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: "My perfect night...",
                                        hintStyle: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 14),
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.height * 20.5 / 100,
                        ),
                      ],
                    ),
                  )))),
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget detailsRow(String title, String value,
      {bool isBold = false,
      bool highlight = false,
      double? fontSize, // <-- new parameter
      FontWeight? fontWeight // <-- optional override
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: fontSize ?? 13, // default 13
              fontWeight: FontWeight.w400,

              color: AppColor.lightGreyColor(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize ?? 13, // default 14
              fontWeight: FontWeight.w400,
              color: highlight ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget infoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColor.secondryColor(context),
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
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
