import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../../utilities/app_color.dart';
import '../../../../utilities/app_constant.dart';
import '../../../../utilities/app_font.dart';
import '../../../../utilities/app_image.dart';
import '../../../../utilities/app_language.dart';

class ChatMessageScreen extends StatefulWidget {
  static String routeName = "./ChatMessageScreen";
  final String name;
  final dynamic image;

  const ChatMessageScreen({super.key, required this.name, required this.image});

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen>
    with SingleTickerProviderStateMixin {
  bool isBottomSheetOpen = false; // Add this variable at the top of your State
  TextEditingController messageTextEditingController = TextEditingController();
  List messageList = [
    // {"id": 1, "message": "Hi", "time": "9:30 PM"},
    {"id": 2, "message": "Hey! New event this weekend", "time": "10:32 AM"},
    {"id": 2, "message": "Live band at Royal Venue 🎸", "time": "10:32 AM"},
    {"id": 3, "message": "Tickets going fast 👀", "time ": "5:05 PM"},
    {"id": 4, "message": "Oh nice! Didn’t know 😍", "time": "9:38 AM"},
    {"id": 5, "message": "Checking now.", "time": "9:38 AM"},
  ];
  bool isContainerVisible = false;
  bool isApproved = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // Bottom start
      end: Offset.zero, // Final position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.primaryColor,
        statusBarIconBrightness: Brightness.light));
    final size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            isContainerVisible = false;
          });
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
              // backgroundColor: AppColor.backgroundColor,
              systemOverlayStyle: SystemUiOverlayStyle(
                systemNavigationBarColor: Color(0xff000000),
                systemNavigationBarIconBrightness: Brightness.light,
                statusBarColor: Color(0xff000000),
                statusBarIconBrightness: Brightness.light,
              ),
            ),
          ),
          body: SafeArea(
              child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 100 / 100,
                height: MediaQuery.of(context).size.height * 100 / 100,
                color: AppColor.primaryColor,
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 100 / 100,
                      height: MediaQuery.of(context).size.height * 9 / 100,
                      alignment: Alignment.center,
                      //  color: AppColor.themeColor,
                      child: Row(
                        //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.width * 10 / 100,
                              width:
                                  MediaQuery.of(context).size.width * 12 / 100,
                              color: AppColor.transparentColor,
                              //  padding: const EdgeInsets.only(left: 13),
                              alignment: Alignment.center,
                              child: Image.asset(
                                AppImage.backArrowIcon,
                                fit: BoxFit.cover,
                                height:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                width:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                color: AppColor.secondryColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 60 / 100,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        10 /
                                        100,
                                    height: MediaQuery.of(context).size.width *
                                        10 /
                                        100,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        // border: Border.all(
                                        //     color: AppColor.secondaryColor,
                                        //     width: 1),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            widget.image,
                                          ),
                                          fit: BoxFit.cover,
                                        ))),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        2 /
                                        100),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(widget.name,
                                        style: TextStyle(
                                            color: AppColor.secondryColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppFont.fontFamily)),
                                    Text(
                                        AppLanguage
                                            .activeTwominuteAgotext[language],
                                        style: TextStyle(
                                            height: 1,
                                            color: AppColor.textcolor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppFont.fontFamily)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // SizedBox(
                          //     width:
                          //         MediaQuery.of(context).size.width * 1 / 100),
                          Container(
                            height: size.height * 4.5 / 100,
                            width: size.width * 4.5 / 100,
                            child: Image.asset(
                              AppImage.callIcon,
                              color: AppColor.secondryColor,
                            ),
                          ),
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 3 / 100),
                          Container(
                            height: size.height * 6 / 100,
                            width: size.width * 5 / 100,
                            child: Image.asset(
                              AppImage.vedioCallicon,
                              color: AppColor.secondryColor,
                            ),
                          ),
                          SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 3 / 100),
                          GestureDetector(
                            onTap: () {
                              reportBottomSheet(context);
                            },
                            child: Image.asset(
                              AppImage.threedotIcon,
                              color: AppColor.secondryColor,
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.5 /
                                  100),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          reverse: true,
                          child: Column(
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      1 /
                                      100),
                              Wrap(
                                runSpacing: 2.0,
                                children:
                                    List.generate(messageList.length, (index) {
                                  return SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        92 /
                                        100,
                                    child: Column(
                                      crossAxisAlignment:
                                          messageList[index]['id'] % 2 != 1
                                              ? CrossAxisAlignment.start
                                              : CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              messageList[index]['id'] % 2 != 1
                                                  ? MainAxisAlignment.start
                                                  : MainAxisAlignment.end,
                                          children: [
                                            if (messageList[index]['id'] % 2 !=
                                                1)
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      10 /
                                                      100,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      10 /
                                                      100,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      // border: Border.all(
                                                      //     color: AppColor.secondaryColor,
                                                      //     width: 1),
                                                      image: DecorationImage(
                                                        image: AssetImage(
                                                          AppImage.profilephoto,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      ))),
                                            if (messageList[index]['id'] % 2 ==
                                                0)
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      2 /
                                                      100),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height *
                                                          2 /
                                                          100,
                                                  horizontal:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          3 /
                                                          100),
                                              decoration: BoxDecoration(
                                                  color: messageList[index]['id'] % 2 == 0
                                                      ? AppColor.washpressColor
                                                      : AppColor.buttonColor,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                  borderRadius: BorderRadius.only(
                                                      topLeft: messageList[index]['id'] % 2 == 1
                                                          ? const Radius.circular(
                                                              25)
                                                          : const Radius.circular(
                                                              0),
                                                      topRight: messageList[index]
                                                                      ['id'] %
                                                                  2 ==
                                                              1
                                                          ? const Radius.circular(
                                                              0)
                                                          : const Radius.circular(
                                                              25),
                                                      bottomLeft: messageList[index]
                                                                      ['id'] %
                                                                  2 ==
                                                              1
                                                          ? const Radius.circular(25)
                                                          : const Radius.circular(25),
                                                      bottomRight: messageList[index]['id'] % 2 == 1 ? const Radius.circular(25) : const Radius.circular(25))),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  SizedBox(
                                                    // width: MediaQuery.of(context)
                                                    //         .size
                                                    //         .width *
                                                    //     55 /
                                                    //     100,
                                                    child: Text(
                                                      messageList[index]
                                                          ['message'],
                                                      style: TextStyle(
                                                          color: messageList[index]
                                                                          [
                                                                          'id'] %
                                                                      2 !=
                                                                  0
                                                              ? AppColor
                                                                  .secondryColor
                                                              : AppColor
                                                                  .secondryColor,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily: AppFont
                                                              .fontFamily),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                              SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      4 /
                                      100),
                              SlideTransition(
                                position: _offsetAnimation,
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.asset(
                                            AppImage.msgCardicon, 
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.70,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.40,
                                          ),
                                        ),
                                      ),
                                    ),

                                    Positioned(
                                      left: size.width*24/100,
                                      right: 0,
                                      bottom: size.height*2/100,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Bass Drop Fridays",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.schedule,
                                                  color: AppColor.buttonColor,
                                                  size: 16),
                                              SizedBox(width: 6),
                                              Text(
                                                "Fri, 10 PM – 4 AM",
                                                style: TextStyle(
                                                    color: AppColor.buttonColor,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on,
                                                  color: Colors.white,
                                                  size: 16),
                                              SizedBox(width: 6),
                                              Text(
                                                "Club Neon, Downtown • 2.3 km",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 5 / 100,
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    1 /
                                    100,
                              ),
                              SlideTransition(
                                position: _offsetAnimation,
                                child: Column(
                                  children: [
                                    // Accept Button
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isApproved = true;
                                            });
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.70,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.06,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color: isApproved
                                                  ? AppColor.greenColor1
                                                  : AppColor.statusbar,
                                            ),
                                            child: Center(
                                              child: Text(
                                                isApproved
                                                    ? "Approved"
                                                    : "Accept",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 15),

                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          90 /
                                          100,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.70,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.06,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            color: Colors.grey.shade900,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Reject',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 4 / 100,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 90 / 100,
                              height:
                                  MediaQuery.of(context).size.height * 7 / 100,
                              child: TextFormField(
                                cursorColor: AppColor.secondryColor,
                                style: const TextStyle(
                                    height: 1, color: AppColor.secondryColor),
                                textAlignVertical: TextAlignVertical.center,
                                keyboardType: TextInputType.name,
                                maxLength: AppConstant.describeLength,
                                controller: messageTextEditingController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  suffixIconConstraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            30 /
                                            100,
                                  ),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 9.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                            decoration: BoxDecoration(
                                              color: AppColor.buttonColor,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Image.asset(
                                                AppImage.cameraIcon,
                                                fit: BoxFit.contain,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.026,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1 /
                                                100),
                                      ],
                                    ),
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Image.asset(
                                          AppImage.shareImg,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          color: AppColor.secondryColor
                                              .withOpacity(0.5),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                1 /
                                                100),
                                        Image.asset(
                                          AppImage.microphone,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              6 /
                                              100,
                                          color: AppColor.secondryColor
                                              .withOpacity(0.5),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                2 /
                                                100),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isBottomSheetOpen =
                                                  !isBottomSheetOpen;
                                            });

                                            if (isBottomSheetOpen) {
                                              plusiconsBottomSheet(context)
                                                  .whenComplete(() {
                                                setState(() {
                                                  isBottomSheetOpen = false;
                                                });
                                              });
                                            }
                                          },
                                          child: Image.asset(
                                            AppImage.plusIcon,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                6 /
                                                100,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                6 /
                                                100,
                                            color: AppColor.secondryColor
                                                .withOpacity(0.5),
                                          ),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3 /
                                                100),
                                      ],
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColor.washpressColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40)),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColor.washpressColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40)),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColor.washpressColor),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(40)),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 15),
                                  fillColor: AppColor.washpressColor,
                                  filled: true,
                                  counterText: '',
                                  hintText: AppLanguage.messageText[language],
                                  hintStyle: const TextStyle(
                                      color: AppColor.textcolor,
                                      fontFamily: AppFont.fontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    )
                  ],
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Future<void> plusiconsBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return Container(
            height: MediaQuery.of(context).size.height * 28 / 100,
            width: MediaQuery.of(context).size.width * 90 / 100,
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width * 32 / 100,
                    height: MediaQuery.of(context).size.height * 18 / 100,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColor.washpressColor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 10 / 100,
                              child: Image.asset(
                                AppImage.vedioIcon,
                                width:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                color: AppColor.secondryColor,
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                AppLanguage.videoText[language],
                                style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: AppColor.secondryColor,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        Row(
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 10 / 100,
                              child: Image.asset(
                                AppImage.gifIcon,
                                width:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 4 / 100,
                                color: AppColor.secondryColor,
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                AppLanguage.gifText[language],
                                style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: AppColor.secondryColor,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        Row(
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 10 / 100,
                              child: Image.asset(
                                AppImage.eventIcon,
                                width:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                color: AppColor.secondryColor,
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                AppLanguage.eventsText[language],
                                style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: AppColor.secondryColor,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).size.height * 1 / 100),
                        Row(
                          children: [
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 10 / 100,
                              child: Image.asset(
                                AppImage.locationBlackicon,
                                width:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                height:
                                    MediaQuery.of(context).size.width * 5 / 100,
                                color: AppColor.secondryColor,
                              ),
                            ),
                            SizedBox(
                              child: Text(
                                AppLanguage.locationText[language],
                                style: TextStyle(
                                  fontSize: 15,
                                  decoration: TextDecoration.none,
                                  color: AppColor.secondryColor,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          );
        });
      },
    );
  }

  Future<void> reportBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setStateBottomSheet) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    top: MediaQuery.of(context).size.height * 10 / 100,
                    right: MediaQuery.of(context).size.width * 5 / 100,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width * 40 / 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColor.washpressColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                // Handle Open Share date action
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Text(
                                  'Open Share date',
                                  style: TextStyle(
                                    fontSize: 15,
                                    decoration: TextDecoration.none,
                                    color: AppColor.secondryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.5 /
                                    100),
                            InkWell(
                              onTap: () {
                                // Handle Report action
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Text(
                                  "Report",
                                  style: TextStyle(
                                    fontSize: 15,
                                    decoration: TextDecoration.none,
                                    color: AppColor.secondryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.5 /
                                    100),
                            InkWell(
                              onTap: () {
                                // Handle Unmatch action
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                child: Text(
                                  "Unmatch",
                                  style: TextStyle(
                                    fontSize: 15,
                                    decoration: TextDecoration.none,
                                    color: AppColor.secondryColor,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: MediaQuery.of(context).size.height *
                                    0.5 /
                                    100),
                            InkWell(
                              onTap: () {
                                // Handle Did you meet action
                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                // child: Text(
                                //   "Did you meet?",
                                //   style: TextStyle(
                                //     fontSize: 15,
                                //     decoration: TextDecoration.none,
                                //     color: AppColor.secondryColor,
                                //     fontFamily: AppFont.fontFamily,
                                //     fontWeight: FontWeight.w400,
                                //   ),
                                // ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
