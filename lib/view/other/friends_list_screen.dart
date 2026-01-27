import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../authentication/notification_screen.dart';
import '../authentication/profile.dart';
import 'chats/chat_message_screen.dart';

class FriendsList extends StatefulWidget {
  static String routeName = './FriendList';

  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
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
    {"image": "assets/icons/ProfilePhoto.png", "name": "Arjun"},
    {"image": "assets/icons/aadityaIcon.png", "name": "Aarav"},
    {"image": "assets/icons/galleryIcon.png", "name": "Bloom Cafe"},
    {"image": "assets/icons/girlImage.png", "name": "Bistro"},
    {"image": "assets/icons/userprofile.png", "name": "olivia"},
  ];

  List chats = [
    {
      'id': 1,
      'image':
          'assets/icons/ProfilePhoto.png', // Replace with your actual image path
      'name': 'Gaurav Kapoor',
      'lastMessage': '@gkapoor02',
      'message': 'message',
    },
    {
      'id': 2,
      'image': 'assets/icons/riya.png',
      'name': 'Riya',
      'lastMessage': '@riya00',
      'message': 'message',
    },
    {
      'id': 3,
      'image': 'assets/icons/galleryIcon.png',
      'name': 'Bloom Cafe',
      'lastMessage': '@cafebloom34',
      'message': 'Message',
    },
    {
      'id': 4,
      'image': 'assets/icons/aadityaIcon.png',
      'name': 'Aaditya',
      'lastMessage': '@aadi54',
      'message': 'Message',
    },
    {
      'id': 5,
      'image': 'assets/icons/rushi.png',
      'name': 'Rushi',
      'lastMessage': '@rushi87',
      'message': 'Message',
    },
    {
      'id': 6,
      'image': AppImage.soham,
      'name': 'Soham',
      'lastMessage': '@soham23',
      'message': 'Message',
    },
  ];
  int selectedId = 2;

  List Orders = [
    {'id': 1, 'title': 'All'},
    {'id': 2, 'title': 'Events'},
    {'id': 3, 'title': 'Venues'},
    {'id': 4, 'title': 'Members'},
  ];
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
     SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // background color
        statusBarIconBrightness:
            Brightness.dark, // icons color: dark for light bg
        statusBarBrightness: Brightness.light, // for iOS
      ),
    );
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondryColor,
        body: SafeArea(
          child: Container(
            height: size.height * 100 / 100,
            width: size.width * 100 / 100,
            child: Column(
              children: [
                SizedBox(height: size.height * 2 / 100),
                // AppHeader(text: AppLanguage.chatsText[language]),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 90 / 100,
                  height: MediaQuery.of(context).size.height * 8 / 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 14 / 100,
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 15 / 100,
                              child: Image.asset(
                                AppImage.hiilogo,
                                color: AppColor.primaryColor,
                              ),
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              1.5 /
                                              100,
                                    ),
                                    Text(
                                      AppLanguage.welcomeText[language],
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      AppLanguage.sanjanaText[language],
                                      style: TextStyle(
                                        fontFamily: AppFont.fontFamily,
                                        fontSize: 23,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const Notifications()),
                              );
                            },
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 3 / 100,
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
                                MaterialPageRoute(
                                    builder: (context) => const Profile()),
                              );
                            },
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 5 / 100,
                              child: Image.asset(
                                AppImage.userimage,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: size.height * 2 / 100),
                Container(
                  width: size.width * 90 / 100,
                  height: size.height * 6 / 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40), // pill shape
                    border: Border.all(color: AppColor.textfieldfillColor),
                    color: AppColor.secondryColor,
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
                    cursorColor: AppColor.primaryColor,
                    style: AppConstant.textFilledStyle,
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
                          color: AppColor.textcolor,
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
                        vertical: 10,
                        horizontal: size.width * 2 / 100,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 1 / 100,
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Wrap(
                        direction: Axis.horizontal,
                        children: List.generate(
                          Orders.length,
                          (index) {
                            bool isAll = Orders[index]['id'] == 1;
                            return GestureDetector(
                              onTap: isAll
                                  ? null
                                  : () {
                                      setState(() {
                                        selectedId = Orders[index]['id'];
                                      });
                                    },
                              child: Container(
                                height: MediaQuery.of(context).size.height *
                                    5 /
                                    100,
                                width: MediaQuery.of(context).size.width *
                                    18 /
                                    100,
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                    color: selectedId == Orders[index]['id']
                                        ? AppColor.secondryColor
                                        : AppColor.secondryColor,
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                        color: selectedId == Orders[index]['id']
                                            ? AppColor.buttonColor
                                            : AppColor.textfilledColor)),
                                child: Text(
                                  Orders[index]['title'],
                                  style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: selectedId == Orders[index]['id']
                                          ? AppColor.buttonColor
                                          : AppColor.textcolor),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.width * 6 / 100,
                        width: MediaQuery.of(context).size.width * 7 / 100,
                        // color: AppColor.transparentColor,
                        //  padding: const EdgeInsets.only(left: 13),
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImage.spanIcon,
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.width * 6 / 100,
                          width: MediaQuery.of(context).size.width * 7 / 100,
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.93,
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
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(storyImages.length, (index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(35),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(35),
                                        child: Image.asset(
                                          storyImages[index]["image"] ??
                                              "no image",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    storyImages[index]["name"] ?? "No Name",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
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

                SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.93,
                  child: Text(
                    AppLanguage.allFriendstext[language],
                    style: const TextStyle(
                      color: AppColor.buttonColor,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 2 / 100),

                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColor.chatContainerColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                      ),
                      width: size.width * 100 / 100,
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 2 / 100),
                          ...List.generate(chats.length, (index) {
                            final chat = chats[index];
                            return Wrap(
                              children: [
                                Container(
                                  width: size.width * 90 / 100,
                                  height: size.height * 8.5 / 100,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      height: size.height * 10 / 100,
                                      width: size.width * 13 / 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape
                                            .circle, // makes it circular
                                        image: DecorationImage(
                                          image: AssetImage(chat['image']),
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
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColor.secondryColor,
                                        borderRadius: BorderRadius.circular(10),
                                        // border: Border.all(

                                        //      color : AppColor.primaryColor,
                                        // ),
                                      ),
                                      child: Text(
                                        chat['message'],
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: AppFont.fontFamily,
                                          color: AppColor.buttonColor,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      print('Tapped on ${chat['name']}');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatMessageScreen(
                                            name: chat['name'],
                                            image: chat['image'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if (index < chats.length - 0)
                                 
                                  if (index < chats.length - 0)
                                    SizedBox(height: size.height * 0.1 / 100),
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
    );
  }
}
