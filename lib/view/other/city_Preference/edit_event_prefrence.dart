import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class EditEventPreference extends StatefulWidget {
  static String routeName = './EditEventPreference';

  const EditEventPreference({super.key});

  @override
  State<EditEventPreference> createState() => _EditEventPreferenceState();
}

class _EditEventPreferenceState extends State<EditEventPreference> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;

  @override
  void initState() {
    super.initState();
  }

  int reportId = 0;

  int selectedId = 2;
  Set<int> selectedIds = {};

  TextEditingController searchController = TextEditingController();

  List Events = [
    {'id': 1, 'title': 'Club Night'},
    {'id': 2, 'title': 'Ladies Night'},
    {'id': 3, 'title': 'Live Performance / Gig'},
    {'id': 4, 'title': 'DJ Night / Set'},
    {'id': 5, 'title': 'Concert'},
    {'id': 6, 'title': 'Festival'},
    {'id': 7, 'title': 'Sundowner'},
    {'id': 8, 'title': 'Afterparty'},
    {'id': 9, 'title': 'Launch Party'},
    {'id': 10, 'title': 'Themed Party'},
    {'id': 11, 'title': 'Pool Party'},
    {'id': 12, 'title': 'Beach Party'},
    {'id': 13, 'title': 'Rooftop Party'},
    {'id': 14, 'title': 'Bar Night / Lounge Night'},
    {'id': 15, 'title': 'Open Mic / Jam Session'},
    {'id': 16, 'title': 'Game Night / Quiz Night'},
    {'id': 17, 'title': 'Singles Mixer / Speed Dating'},
    {'id': 18, 'title': 'Pop-Up Event / Takeover'},
  ];

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
              Navigator.pop(
                context,
              );
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
                                AppLanguage.eventPreferencetext[language],
                                style: const TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
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

                SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 75 / 100,
                        child: Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            AppLanguage.selectEventstatementText[language],
                            style: const TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: AppColor.secondryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
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
                      AppLanguage.eventTypetext[language],
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
                  height: MediaQuery.of(context).size.height * 3 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      Events.length,
                      (index) {
                        int id = Events[index]['id'];
                        bool isSelected = selectedIds.contains(id);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedIds.remove(id);
                              } else {
                                if (selectedIds.length < 5) {
                                  selectedIds.add(id);
                                } else {}
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColor.filledcolor
                                  : AppColor.filledcolor,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.buttonColor
                                    : AppColor.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              Events[index]['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: AppFont.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.otherstext[language],
                      style: const TextStyle(
                        fontFamily: AppFont.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.pinkColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 2 / 100),
                Container(
                  width: size.width * 90 / 100,
                  height: size.height * 6 / 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColor.filledcolor,
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
                    cursorColor: AppColor.secondryColor,
                    style: const TextStyle(color: AppColor.secondryColor),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(
                          left: size.width * 4 / 100,
                          right: size.width * 2 / 100,
                        ),
                        // child: Image.asset(
                        //   AppImage.searchIcon,
                        //   height: size.width * 4 / 100,
                        //   width: size.width * 4 / 100,
                        //   color: AppColor.filledText,
                        // ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: size.width * 2 / 100,
                        minHeight: size.height * 6 / 100,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColor.borderColor,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColor.borderColor,
                          width: 2,
                        ),
                      ),
                      border: InputBorder.none,
                      hintText:
                          AppLanguage.typeYoureventpreferenceText[language],
                      hintStyle: AppConstant.textFilledStyle1,
                      contentPadding: EdgeInsets.only(
                        right: size.width * 4 / 100,
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 4 / 100,
                // ),

                // AppButton(
                //     text: AppLanguage.saveandContinue[language],
                //     onPress: () {
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) => VibePreference()));
                //     }),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 18 / 100,
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
