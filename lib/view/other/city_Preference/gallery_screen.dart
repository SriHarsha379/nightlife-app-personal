// import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import 'vibeCheckScreens/vibe_check_screens.dart';

class GalleryScreen extends StatefulWidget {
  static String routeName = './GalleryScreen';

  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;

  @override
  void initState() {
    super.initState();
  }

  int reportId = 0;

  int selectedId = 2;

  TextEditingController searchController = TextEditingController();

  List galleryList = [
    {'id': 1, 'image': AppImage.rectanglePlusicon},
    {'id': 2, 'image': AppImage.rectangleIcon},
    {'id': 3, 'image': AppImage.rectangleIcon},
    {'id': 4, 'image': AppImage.rectangleIcon},
    {'id': 5, 'image': AppImage.rectangleIcon},
    {'id': 6, 'image': AppImage.rectangleIcon},
    {'id': 7, 'image': AppImage.rectangleIcon},
    {'id': 8, 'image': AppImage.rectangleIcon},
    {'id': 9, 'image': AppImage.rectangleIcon},
  ];

  List Vibe = [
    {'id': 1, 'title': 'Energetic 💥'},
    {'id': 2, 'title': 'Chill 😎'},
    {'id': 3, 'title': 'Romantic 😍'},
    {'id': 4, 'title': 'Intimate 🤗'},
    {'id': 5, 'title': 'Wild 😈'},
  ];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // required for iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: const BoxDecoration(gradient: AppColor.backgroundGradientcolor),
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
                                AppLanguage.GalleryText[language],
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
                  width: MediaQuery.of(context).size.width * 88 / 100,
                  child: Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      AppLanguage.uploadPhotosstatementText[language],
                      style: const TextStyle(
                        fontFamily: AppFont.plusJakartaSansFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColor.secondryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 2 / 100,
                ),
                SizedBox(
                  width: size.width,
                  child: ListView.builder(
                    itemCount: (galleryList.length / 3).ceil(),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, rowIndex) {
                      int startIndex = rowIndex * 3;

                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: size.height * 2.5 / 100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(3, (colIndex) {
                            int itemIndex = startIndex + colIndex;
                            if (itemIndex >= galleryList.length) {
                              return SizedBox(
                                  width: size.width *
                                      30 /
                                      100); // Maintain alignment
                            }

                            return GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: size.width * 26 / 100,
                                height: size.width * 32 / 100,
                                decoration: BoxDecoration(
                                  color: AppColor.transparentColor,
                                  borderRadius: BorderRadius.circular(21),
                                  border: Border.all(
                                    color: AppColor.pinkColor,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(21),
                                  child: Image.asset(
                                    galleryList[itemIndex]['image'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 10 / 100,
                ),
                AppButton(
                    text: AppLanguage.continueText[language],
                    onPress: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeftWithFade,
                          child: const VibeCheckScreen(), // Always starts at index 0
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    }),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 4 / 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
