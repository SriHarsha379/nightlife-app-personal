import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class EditVibePreference extends StatefulWidget {
  static String routeName = './EditVibePreference';

  const EditVibePreference({super.key});

  @override
  State<EditVibePreference> createState() => _EditVibePreferenceState();
}

class _EditVibePreferenceState extends State<EditVibePreference> {
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
      'title1': 'Dance, EDM, full party mode',
      'emoji2': '😎',
      "music": "Chill & Easy",
      "music1": "Lounge, acoustic, sundowner"
    },
    {
      'id': 2,
      'emoji': '😍',
      'title': 'Romantic',
      'title1': 'Candlelight, date-friendly',
      'emoji2': '🤗',
      "music": "Social & Fun",
      "music1": "Meet new people, mixers"
    },
    {
      'id': 3,
      'emoji': '👑',
      'title': 'Exclusive',
      'title1': 'VIP, invite-only, high-end',
      'emoji2': '😈',
      "music": "Wild & Crazy",
      "music1": "Anything goes, unpredictable"
    },
    {
      'id': 4,
      'emoji': '✨',
      'title': 'Trendy & Stylish',
      'title1': 'Influencer spots, new openings',
      'emoji2': '💎',
      "music": "Luxury",
      "music1": "Premium crowd, craft cocktails"
    },
    {
      'id': 5,
      'emoji': '📼',
      'title': 'Retro & Nostalgic',
      'title1': '80s/90s/2000s theme',
      'emoji2': '🎸',
      "music": "Live & Loud",
      "music1": "Bands, concerts, performances"
    },
    {
      'id': 6,
      'emoji': '🌆',
      'title': 'Rooftop & Views',
      'title1': 'Skyline bars, scenic venues',
      'emoji2': '🌅',
      "music": "Beach & Sundowner",
      "music1": "Sunset vibes, golden hour"
    },
    {
      'id': 7,
      'emoji': '🎨',
      'title': 'Creative & Artsy',
      'title1': 'Art, fashion, concept parties',
      'emoji2': '💕',
      "music": "Flirty & Playful",
      "music1": "Dating, singles nights"
    },
    {
      'id': 8,
      'emoji': '🤝',
      'title': 'Community & Warm',
      'title1': 'Familiar faces, regulars',
      'emoji2': '🎊',
      "music": "Festive & Themed",
      "music1": "Halloween, Holi, NYE"
    },
    {
      'id': 9,
      'emoji': '🌙',
      'title': 'Late & Loose',
      'title1': 'Afterparties, unplanned',
      'emoji2': '🔬',
      "music": "Experimental",
      "music1": "Fusion, cross-genre, surprise"
    },
    {
      'id': 10,
      'emoji': '🕳️',
      'title': 'Underground',
      'title1': 'Hidden venues, techno, secret-',
      'emoji2': '🌍',
      "music": "Cultural & Local",
      "music1": "Themed or regional nights"
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
            text: AppLanguage.continueText[language],
            onPress: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration:
              const BoxDecoration(gradient: AppColor.backgroundGradientcolor),
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
                                style: const TextStyle(
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
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
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
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
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
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
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
                              child: IntrinsicWidth(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.032,
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.012,
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
                                        '${Orders[index]['emoji']} ',
                                        style: const TextStyle(
                                          fontFamily: AppFont.fontFamily,
                                          fontSize: 13.2,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.secondryColor,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Orders[index]['title'],
                                            style: const TextStyle(
                                              fontFamily: AppFont.fontFamily,
                                              fontSize: 13.2,
                                              fontWeight: FontWeight.w500,
                                              color: AppColor.secondryColor,
                                            ),
                                          ),
                                          SizedBox(
                                              height: size.height * 0.1 / 100),
                                          Text(
                                            Orders[index]['title1'],
                                            style: const TextStyle(
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
                                        style: const TextStyle(
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
                                            style: const TextStyle(
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
                                            style: const TextStyle(
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
