import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/other/city_Preference/vibeCheckScreens/vibe_check_screen1.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';

class BadgeScreen extends StatefulWidget {
  static String routeName = './BadgeScreen';

  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  // File? _imageSelect;
  // ignore: prefer_typing_uninitialized_variables
  var fileName;

  @override
  void initState() {
    super.initState();
  }

  int reportId = 0;

  int selectedId = 2;
  List Orders = [
    {'id': 1, 'title': 'Delhi'},
    {'id': 2, 'title': 'Banglore'},
    {'id': 3, 'title': 'Gurgaon'},
    {'id': 4, 'title': 'Mumbai'},
  ];
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

  List chats = [
    {
      'id': 1,
      'image':
          'assets/icons/ProfilePhoto.png', // Replace with your actual image path
      'name': 'Gaurav Kapoor',
      'lastMessage': '@gkapoor02',
      'message': 'send',
    },
    {
      'id': 2,
      'image': 'assets/icons/riya.png',
      'name': 'Riya',
      'lastMessage': '@riya00',
      'message': 'send',
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'Bloom Cafe',
      'lastMessage': '@cafebloom34',
      'message': 'send',
    },
    {
      'id': 4,
      'image': 'assets/icons/aadityaIcon.png',
      'name': 'Aaditya',
      'lastMessage': '@aadi54',
      'message': 'send',
    },
    {
      'id': 5,
      'image': 'assets/icons/rushi.png',
      'name': 'Rushi',
      'lastMessage': '@rushi87',
      'message': 'send',
    },
    {
      'id': 6,
      'image': 'assets/icons/soham.png',
      'name': 'Soham',
      'lastMessage': '@soham23',
      'message': 'send',
    },
  ];
 

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
        statusBarColor: AppColor.secondryColor(context),
        statusBarIconBrightness: Brightness.dark));

    // ignore: deprecated_member_use
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width * 100 / 100,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor(context)),
          child: Column(
            children: [
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
                            width: MediaQuery.of(context).size.width * 5 / 100,
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
                              child: Image.asset(
                                AppImage.backArrowIcon,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 80 / 100,
                          child: Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              AppLanguage.partyPreferenceText[language],
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 90 / 100,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    textAlign: TextAlign.center,
                    AppLanguage.selectBadgeSentence[language],
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
                width: MediaQuery.of(context).size.width * 95 / 100,
                child: Image.asset(
                  AppImage.badgeIcon,
                  height: size.height * 66 / 100, // smaller, looks balanced
                  width: size.width * 15 / 100,
                ),
              ),

           

              SizedBox(
                height: MediaQuery.of(context).size.height * 5 / 100,
              ),
              AppButton(
                  text: AppLanguage.saveandContinue[language],
                  onPress: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VibeCheckScreen1()));
                  }),

          
            ],
          ),
        ),
      ),

    );
  }


}
