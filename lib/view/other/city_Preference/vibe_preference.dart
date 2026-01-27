// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/city_Preference/aboutyou_screen.dart';
import 'package:page_transition/page_transition.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class VibePreference extends StatefulWidget {
  static String routeName = './VibePreference';

  const VibePreference({super.key});

  @override
  State<VibePreference> createState() => _VibePreferenceState();
}

class _VibePreferenceState extends State<VibePreference> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;

  @override
  void initState() {
    super.initState();
  }

  int reportId = 0;

  int? selectedId;
  Set<int> selectedIds = {};
  Set<int> selectedIds1 = {};
  List<int> selectedMusicIds = [];
  List<int> selectedVibeIds = [];
  List<int> selectedList = [];

  List Orders = [
    {
      'id': 1,
      'emoji': '💥',
      'title': 'High Energy',
      'title1': 'Dance, EDM, full party',
      'emoji2': '😎',
      "music": "Chill & Easy",
      "music1": "Lounge, acoustic, sundowner"
    },
    {
      'id': 2,
      'emoji': '😍',
      'title': 'Romantic',
      'title1': 'Candlelight, date-friendly',
      'emoji2': '🕳️',
      "music": "Underground",
      "music1": "Hidden venues, techno"
    },
    {
      'id': 3,
      'emoji': '✨',
      'title': 'Trendy & Stylish',
      'title1': 'Influencer spots, new openings',
      'emoji2': '👑',
      "music": "Exclusive",
      "music1": "VIP, invite-only"
    },
    {
      'id': 4,
      'emoji': '😈',
      'title': 'Wild & Crazy',
      'title1': 'Anything goes, unpredictable',
      'emoji2': '💎',
      "music": "Luxury",
      "music1": "Premium crowd,craft cocktails"
    },
    {
      'id': 5,
      'emoji': '📼',
      'title': 'Retro & Nostalgic',
      'title1': '80s/90s/2000s theme',
      'emoji2': '🤗',
      "music": "Friendly & Fun",
      "music1": "Meet new people, mixers"
    },
    {
      'id': 6,
      'emoji': '🌆',
      'title': 'Rooftop & Views',
      'title1': 'Skyline bars, scenic venues',
      'emoji2': '🎨',
      "music": "Creative & Artsy",
      "music1": "Art, fashion, concept parties"
    },
    {
      'id': 7,
      'emoji': '🌅',
      'title': 'Beach & Sundowner',
      'title1': 'Tropical, relaxed, sunset',
      'emoji2': '🌙',
      "music": "Late & Loose",
      "music1": "Afterparties, unplanned"
    },
    {
      'id': 8,
      'emoji': '💕',
      'title': 'Flirty & Playful',
      'title1': 'Dating, singles nights',
      'emoji2': '🎊',
      "music": "Festive & Themed",
      "music1": "Halloween, Holi, NYE"
    },
    {
      'id': 9,
      'emoji': '🤝',
      'title': 'Social & Warm',
      'title1': 'Familiar faces, regulars',
      'emoji2': '🎸',
      "music": "Live & Loud",
      "music1": "Bands, concerts, performances"
    },
    {
      'id': 10,
      'emoji': '🌍',
      'title': 'Cultural & Local',
      'title1': 'Themed or regional nights',
      'emoji2': '🔬',
      "music": "Experimental",
      "music1": "Fusion, cross-genre, surprise"
    },
  ];



  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  List<int> leftSelected = [];
  List<int> rightSelected = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.statusbar,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: AppButton(
            text: '${AppLanguage.continueText[language]}',
            onPress: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: AboutYouScreen(),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            },
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 3 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
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
                                  color: AppColor.secondryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 80 / 100,
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLanguage.vibePreferenceText[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 92 / 100,
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.whatKindofVibeText[language],
                      style: TextStyle(
                        fontFamily: AppFont.plusJakartaSansFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.vibeTypetext[language],
                      style: TextStyle(
                        fontFamily: AppFont.plusJakartaSansFamily,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppColor.secondryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.select1to5Text[language],
                      style: TextStyle(
                        fontFamily: AppFont.plusJakartaSansFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColor.filledText,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Wrap(
                    // spacing: 9,
                    runSpacing: 12,
                    children: List.generate(
                      Orders.length,
                      (index) {
                        int baseId = Orders[index]['id'];

                        int leftId = baseId * 2;
                        int rightId = baseId * 2 + 1;

                        bool isLeftSelected = selectedList.contains(leftId);
                        bool isRightSelected = selectedList.contains(rightId);

                        return Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 2 / 100,
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isLeftSelected) {
                                    selectedList.remove(leftId);
                                  } else {
                                    if (selectedList.length < 5) {
                                      selectedList.add(leftId);
                                    } else {}
                                  }
                                });
                              },
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.9, // screen-safe
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: MediaQuery.of(context).size.width * 0.032,
                                    vertical: MediaQuery.of(context).size.height * 0.012,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.filledcolor,
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: isLeftSelected
                                          ? AppColor.buttonColor
                                          : AppColor.borderColor,
                                      width: 1,
                                    ),
                                    boxShadow: isLeftSelected
                                        ? [
                                      BoxShadow(
                                        color: AppColor.buttonColor.withOpacity(0.35),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      )
                                    ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${Orders[index]['emoji']} ',
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 13.2,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.secondryColor,
                                        ),
                                      ),

                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Orders[index]['title'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppFont.plusJakartaSansFamily,
                                                fontSize: 13.2,
                                                fontWeight: FontWeight.w500,
                                                color: AppColor.secondryColor,
                                              ),
                                              ),
                                            SizedBox(height: size.height * 0.1 / 100),
                                            Text(
                                              Orders[index]['title1'],
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: AppFont.fontFamily,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w400,
                                                color: AppColor.lightGreyColor,
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
                            SizedBox(width: size.width * 4 / 100),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isRightSelected) {
                                    selectedList.remove(rightId);
                                  } else {
                                    if (selectedList.length < 5) {
                                      selectedList.add(rightId);
                                    } else {}
                                  }
                                });
                              },
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.011,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.012,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColor.filledcolor,
                                    borderRadius: BorderRadius.circular(11),
                                    border: Border.all(
                                      color: isRightSelected
                                          ? AppColor.buttonColor
                                          : AppColor.borderColor,
                                      width: 1,
                                    ),
                                    boxShadow: isRightSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColor.buttonColor
                                                  .withOpacity(0.35),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${Orders[index]['emoji2']} ',
                                        style: TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 13.2,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.secondryColor,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            Orders[index]['music'],
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 13.2,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.secondryColor,
                                            ),
                                          ),
                                          SizedBox(
                                              height: size.height * 0.1 / 100),
                                          Text(
                                            Orders[index]['music1'],
                                            style: TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w400,
                                              color: AppColor.lightGreyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 16 / 100,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4 / 100,
                ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: const AppFooter(
        //     selectedMenu: BottomMenus.home, notificationCount: 0),
      ),
    );
  }
}
