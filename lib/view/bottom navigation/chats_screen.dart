import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../utilities/app_color.dart';
import '../../provider/darkmode_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../authentication/notification_screen.dart';
import '../authentication/profile.dart';
import '../other/chats/chat_message_screen.dart';

class ChatScreen extends StatefulWidget {
  static String routeName = './ChatScreen';

  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> storyImages = [
    {"image": "assets/icons/aadityaIcon.png", "name": "Arjun"},
    {"image": "assets/icons/arjunrampalIcon.png", "name": "Arav"},
    {"image": "assets/icons/galleryIcon.png", "name": "Bloom Cafe"},
    {"image": "assets/icons/girlImage.png", "name": "Bistro"},
    {"image": "assets/icons/userprofile.png", "name": "olivia"},
  ];

  List chats = [
    {
      'id': 1,
      'image':
          'assets/icons/aadityaIcon.png', // Replace with your actual image path
      'name': 'Gaurav Kapoor',
      'lastMessage': 'What about that new jacket if..',
      'time': '09:18',
    },
    {
      'id': 2,
      'image': 'assets/icons/arjunRoyicon.png',
      'name': 'Clara Hazel',
      'lastMessage': 'Are you ready for today\'s part..',
      'time': '12:44',
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'Bloom Cafe',
      'lastMessage': 'I\'am sending you a parcel rece..',
      'time': '08:06',
    },
    {
      'id': 4,
      'image': 'assets/icons/girlImage.png',
      'name': 'Monica Randawa',
      'lastMessage': 'Hope you\'re doing well today..',
      'time': '09:32',
    },
  ];
  int selectedId = 2;

  List Orders = [
    {'id': 1, 'title': 'Members'},
    {'id': 2, 'title': 'Events'},
    {'id': 3, 'title': 'Venues'},
    {'id': 4, 'title': 'All'},
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));
    final themeProvider = Provider.of<ThemeProvider>(context);

    bool isDark = themeProvider.isDarkMode;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        setState(() {
          AppConstant.selectFooterIndex = 0; // Footer first index par jao
        });
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor:
              isDark ? AppColor.primaryColor : AppColor.secondryColor,
          body: SafeArea(
            child: Container(
              height: size.height * 100 / 100,
              width: size.width * 100 / 100,
              child: Column(
                children: [
                  // SizedBox(height: size.height * 0.2 / 100),
                  // AppHeader(text: AppLanguage.chatsText[language]),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 95 / 100,
                    height: MediaQuery.of(context).size.height * 9 / 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 14 / 100,
                              child: Image.asset(
                                AppImage.hiilogo,
                                color: isDark
                                    ? AppColor.darkTextColor
                                    : AppColor.richBlackColor,
                                width: MediaQuery.of(context).size.width *
                                    10 /
                                    100,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      2 /
                                      100,
                                ),
                                Text(
                                  AppLanguage.welcomeText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? AppColor.darkTextColor
                                        : AppColor.richBlackColor,
                                  ),
                                ),
                                Text(
                                  AppLanguage.sanjanaText[language],
                                  style: TextStyle(
                                    fontFamily: AppFont.fontFamily,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColor.secondryColor
                                        : AppColor.richBlackColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.topToBottom,
                                    child: Notifications(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    3 /
                                    100,
                                child: Image.asset(
                                  AppImage.bellicon,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * 2 / 100,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type:
                                        PageTransitionType.rightToLeftWithFade,
                                    child: Profile(),
                                    duration: const Duration(milliseconds: 500),
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                                child: Image.asset(
                                  AppImage.userimage,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 4 / 100),
                          ],
                        )
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 2 / 100),
                  Container(
                    width: size.width * 90 / 100,
                    height: size.height * 5.5 / 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40), // pill shape
                      border: Border.all(color: AppColor.textfieldfillColor),
                      color: isDark
                          ? AppColor.primaryColor
                          : AppColor.secondryColor,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                          blurRadius: 4,
                          color: AppColor.primaryColor.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: searchController,
                      cursorColor: isDark
                          ? AppColor.secondryColor
                          : AppColor.primaryColor,
                      style: TextStyle(
                          color: isDark
                              ? AppColor.secondryColor
                              : AppColor.primaryColor,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFont.fontFamily,
                          fontSize: 14),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 4 / 100,
                            vertical: 10,
                          ),
                          child: Image.asset(
                            AppImage.searchIcon,
                            height: size.width * 4 / 100,
                            width: size.width * 4 / 100,
                            color: isDark
                                ? AppColor.secondryColor
                                : AppColor.primaryColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: AppColor.primaryColor,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide: const BorderSide(
                            color: AppColor.primaryColor,
                            width: 0,
                          ),
                        ),
                        border: InputBorder.none,
                        // hintText: AppLanguage.searchText[language],
                        hintStyle: AppConstant.textFilledStyle,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: size.width * 2 / 100,
                        ),
                      ),
                    ),
                  ),

                  Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: Text(
                          AppLanguage.recentFriends[language],
                          style: const TextStyle(
                            color: AppColor.buttonColor,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 91 / 100,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                List.generate(storyImages.length, (index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: size.width * 15 / 100,
                                            height: size.width * 15 / 100,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(35),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColor.primaryColor
                                                      .withOpacity(0.25),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(35),
                                              child: Image.asset(
                                                storyImages[index]["image"] ??
                                                    "no image",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          // ===== SEND ICON ONLY ON FIRST ITEM =====
                                          if (index == 0)
                                            Positioned(
                                              right: -8,
                                              top: -2,
                                              child: Container(
                                                width: size.width * 5.2 / 100,
                                                height: size.width * 5.2 / 100,
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColor.darkPurpleColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Image.asset(
                                                  AppImage.storySendiconn,
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                      .size
                                                      .height,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.8 / 100),
                                    Text(
                                      storyImages[index]["name"] ?? "No Name",
                                      style: const TextStyle(
                                        color: AppColor.secondryColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                      )
                    ],
                  ),

                  SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: Text(
                      AppLanguage.messageText[language],
                      style: const TextStyle(
                        color: AppColor.buttonColor,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100),

                  Expanded(
                    flex: 1,
                    child: Container(
                      height: size.height * 76 / 100,
                      width: size.width * 100 / 100,
                      decoration: BoxDecoration(
                        gradient: AppColor.backgroundGradientcolor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          children: [
                            SizedBox(height: size.height * 3 / 100),
                            ...List.generate(chats.length, (index) {
                              final chat = chats[index];

                              return Column(
                                children: [
                                  Wrap(
                                    children: [
                                      SizedBox(
                                        width: size.width * 92 / 100,
                                        height: size.height * 9.5 / 100,
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          horizontalTitleGap: 8,
                                          leading: Container(
                                            margin: EdgeInsets.only(
                                                left: size.width * 2.8 / 100),
                                            height: size.width * 18 / 100,
                                            width: size.width * 18 / 100,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image:
                                                    AssetImage(chat['image']),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            chat['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: AppColor.secondryColor,
                                            ),
                                          ),
                                          subtitle: Text(
                                            chat['lastMessage'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.secondryColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                width: size.width * 2.5 / 100,
                                                height: size.height * 2 / 100,
                                                decoration: BoxDecoration(
                                                  color: AppColor.pinkColor,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.height * 1 / 100,
                                              ),
                                              Text(
                                                chat['time'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      AppColor.greyLightColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                type: PageTransitionType
                                                    .rightToLeftWithFade,
                                                child: ChatMessageScreen(
                                                  name: chat['name'],
                                                  image: chat['image'],
                                                ),
                                                duration: const Duration(
                                                    milliseconds: 500),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const Divider(
                                        height: 0.2,
                                        thickness: 0.5,
                                        color: AppColor.greyLightColor,
                                        indent: 30,
                                        endIndent: 30,
                                      ),
                                      SizedBox(height: size.height * 2.5 / 100),
                                    ],
                                  ),
                                  if (index == chats.length - 1)
                                    SizedBox(height: size.height * 4.5 / 100),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
