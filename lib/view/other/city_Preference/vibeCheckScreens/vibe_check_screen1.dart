import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/city_Preference/vibeCheckScreens/vibe_check_screen2.dart';
import 'package:night_life/utilities/page_transition.dart';
import '../../../../utilities/app_button.dart';
import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class VibeCheckScreen1 extends StatefulWidget {
  static String routeName = './VibeCheckScreen1';

  const VibeCheckScreen1({super.key});

  @override
  State<VibeCheckScreen1> createState() => _VibeCheckScreen1State();
}

class _VibeCheckScreen1State extends State<VibeCheckScreen1> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;

  int reportId = 0;
  bool isDropdownOpen = false;
  int selectedIndex = -1;

  int selectedId = 2;
  List<Map<String, dynamic>> imageList = [
    {
      "image": AppImage.div3,
    },
    {
      "image": AppImage.div,
    },
    {
      "image": AppImage.div2,
    },
  ];
  TextEditingController searchController = TextEditingController();

  List<Map<String, String>> questionList = [
    {
      "title": "What's your perfect night out?",
      "subtitle": "Describe your ideal evening in a few words.",
    },
    {
      "title": "Go–to drink?",
      "subtitle": "What do you usually order at the bar?",
    },
    {
      "title": "Something interesting about you?",
      "subtitle": "Tell something interesting about yourself",
    },
    {
      "title": "What's your perfect night out?",
      "subtitle": "Describe your ideal evening in a few words.",
    },
    {
      "title": "Go–to drink?",
      "subtitle": "What do you usually order at the bar?",
    },
    {
      "title": "Something interesting about you?",
      "subtitle": "Tell something interesting about yourself",
    },
  ];

  List<bool> isOpen = [];

  @override
  void initState() {
    super.initState();
    isOpen = List.filled(questionList.length, false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ignore: deprecated_member_use
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.statusbar,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          // Was previously a floatingActionButton, which renders on top of
          // the Scaffold's own (black) background rather than this gradient
          // Container - that mismatch is what caused the button to look
          // like it was floating over a black gap. Moving it into a Column
          // here, pinned below the scrollable content, keeps it sitting
          // directly on the gradient instead.
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 4 / 100,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          height: MediaQuery.of(context).size.height * 8 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: SizedBox(
                                      width:
                                      MediaQuery.of(context).size.width * 4 / 100,
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height *
                                            5 /
                                            100,
                                        child: Image.asset(
                                          AppImage.backArrowIcon,
                                          color: AppColor.secondryColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 2 / 100,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 73 / 100,
                                    child: Center(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        AppLanguage.vibeCheck[language],
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: AppColor.secondryColor(context),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: size.height * 2 / 100),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 88 / 100,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              textAlign: TextAlign.center,
                              '1/3',
                              style: TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 90 / 100,
                          child: Image.asset(
                            AppImage.frequencyOneicon,
                            width: MediaQuery.of(context).size.width * 20 / 100,
                            height: MediaQuery.of(context).size.width * 10 / 100,
                          ),
                        ),
                        SizedBox(height: size.height * 2 / 100),

                        //
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isDropdownOpen = !isDropdownOpen;
                            });
                          },
                          child: Container(
                            width: size.width * 90 / 100,
                            // height: size.heiht *9/100,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 15),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor(context),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(50),
                                topRight: const Radius.circular(50),
                                bottomLeft: Radius.circular(isDropdownOpen ? 0 : 50),
                                bottomRight: Radius.circular(isDropdownOpen ? 0 : 50),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "What's your perfect night out?",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: AppFont.plusJakartaSansFamily),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Describe your ideal evening in a few words.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: AppFont.plusJakartaSansFamily,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xffB7AFC9),
                                      ),
                                    ),
                                  ],
                                ),
                                AnimatedRotation(
                                  turns: isDropdownOpen ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ===== DROPDOWN LIST (VISIBLE WHEN CLICKED) =====
                        if (isDropdownOpen)
                          Divider(
                            height: 0.2,
                            thickness: 0.5,
                            color: AppColor
                                .greyLightColor(context),
                            indent: 30,
                            endIndent: 30,
                          ),
                        if (isDropdownOpen)
                          Container(
                            width: size.width * 0.9,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 19,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor(context),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(50),
                                bottomRight: Radius.circular(50),
                              ),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: questionList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isDropdownOpen = false;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          questionList[index]["title"]!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          questionList[index]["subtitle"]!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xffB7AFC9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        SizedBox(height: size.height * 4 / 100),

                        Container(
                          width: size.width * 90 / 100,
                          height: size.height * 6 / 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColor.filledcolor(context),
                            boxShadow: [
                              BoxShadow(
                                offset: const Offset(0, 1),
                                spreadRadius: 0,
                                blurRadius: 0,
                                color: AppColor.transparentColor.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: searchController,
                            cursorColor: AppColor.secondryColor(context),
                            style: TextStyle(color: AppColor.secondryColor(context)),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(
                                  left: size.width * 4 / 100,
                                  right: size.width * 2 / 100,
                                ),
                              ),
                              prefixIconConstraints: BoxConstraints(
                                minWidth: size.width * 2 / 100,
                                minHeight: size.height * 6 / 100,
                              ),
                              border: InputBorder.none,
                              hintText: AppLanguage.myperfectNight[language],
                              hintStyle: AppConstant.textFilledStyle1(context).copyWith(
                                color: AppColor.hintPlaceHolderText,
                              ),
                              contentPadding: EdgeInsets.only(
                                right: size.width * 4 / 100,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * 3 / 100,
                        ),
                      ],
                    ),
                  ),
                ),
                // Continue / Skip block - now a normal part of the layout,
                // pinned below the scrollable content via Expanded above,
                // instead of a floatingActionButton sitting outside the
                // gradient-decorated body.
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(
                        height: 62,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        text: '${AppLanguage.continueText[language]}',
                        onPress: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeftWithFade,
                              child: const VibeCheckScreen2(),
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: size.height * 1 / 100),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const VibeCheckScreen2()));
                        },
                        child: Text(
                          textAlign: TextAlign.center,
                          AppLanguage.skip[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColor.greyLightColor(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}