import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_language.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';

class ChatSupport extends StatefulWidget {
  static String routeName = './ChatSupport';
  const ChatSupport({super.key});

  @override
  State<ChatSupport> createState() => _ChatSupportState();
}

class _ChatSupportState extends State<ChatSupport> {
  int selectedIndex = 0;
  TextEditingController messageTextEditingController = TextEditingController();

  List<String> issues = [
    "How do I create an account?",
    "What are the community guidelines?",
    "How do I report a user?",
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColor.primaryColor(context),
        body: Column(
          children: [
            SizedBox(height: size.height * 5 / 100),
            AppHeader(
              text: AppLanguage.chatSupportText[language],
              onPress: () => Navigator.pop(context),
            ),
            SizedBox(height: size.height * 4 / 100),

            /// ---------------- CHAT BODY ----------------
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 4 / 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Bot message
                    _botBubble("Hi! This is chat support."),
                    _botBubble("How may I help you?"),

                    SizedBox(height: size.height * 3 / 100),

                    const Center(
                      child: Text(
                        "Please select your issue from the list",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 2 / 100),

                    /// Selectable issues
                    Column(
                      children: List.generate(issues.length, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: size.width * 80 / 100,
                                margin: EdgeInsets.only(
                                  bottom: size.height * 1.2 / 100,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 1.8 / 100,
                                  horizontal: size.width * 4 / 100,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.toggleColor(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        issues[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontFamily: AppFont.fontFamily,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: selectedIndex == index
                                              ? AppColor.hintPlaceHolderText
                                              : Colors.white38,
                                        ),
                                      ),
                                      child: selectedIndex == index
                                          ? Center(
                                              child: Container(
                                                height: 8,
                                                width: 8,
                                                decoration: const BoxDecoration(
                                                  color: Color.fromARGB(
                                                      255, 178, 132, 223),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: size.height * 2 / 100),

                    /// User messages
                    _userBubble("Oh nice! Didn't know 😍"),
                    _userBubble("Checking now."),
                    _userBubble("You going too?"),
                  ],
                ),
              ),
            ),

            /// ---------------- INPUT FIELD ----------------
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
                      width: MediaQuery.of(context).size.width * 90 / 100,
                      height: MediaQuery.of(context).size.height * 7 / 100,
                      child: TextFormField(
                        cursorColor: AppColor.secondryColor(context),
                        style:  TextStyle(
                            height: 1, color: AppColor.secondryColor(context)),
                        textAlignVertical: TextAlignVertical.center,
                        keyboardType: TextInputType.name,
                        maxLength: AppConstant.describeLength,
                        controller: messageTextEditingController,
                        decoration: InputDecoration(
                          isDense: true,
                          suffixIconConstraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 30 / 100,
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      // isBottomSheetOpen = !isBottomSheetOpen;
                                    });

                                    // if (isBottomSheetOpen) {
                                    //   plusiconsBottomSheet(context)
                                    //       .whenComplete(() {
                                    //     setState(() {
                                    //       isBottomSheetOpen = false;
                                    //     });
                                    //   });
                                    // }
                                  },
                                  child: Image.asset(
                                    AppImage.plusIcon,
                                    height: MediaQuery.of(context).size.width *
                                        7 /
                                        100,
                                    width: MediaQuery.of(context).size.width *
                                        7 /
                                        100,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        3 /
                                        100),
                              ],
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColor.washpressColor),
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColor.washpressColor),
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColor.washpressColor),
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 15),
                          fillColor: AppColor.washpressColor,
                          filled: true,
                          counterText: '',
                          hintText: AppLanguage.messageText[language],
                          hintStyle:  TextStyle(
                              color: AppColor.chatSupportcolor(context),
                              fontFamily: AppFont.fontFamily,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- Widgets ----------------

  Widget _botBubble(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xff262626),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: AppFont.fontFamily,
            fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _userBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.purple,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: AppFont.fontFamily,
          ),
        ),
      ),
    );
  }
}
