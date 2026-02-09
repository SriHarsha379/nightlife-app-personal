import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_button.dart';
import 'package:night_life/utilities/app_language.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_header.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';

class ReportProblemScreen extends StatefulWidget {
  static String routeName = './ReportProblemScreen';
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  TextEditingController messageTextEditingController = TextEditingController();

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
        body: Container(
          width: size.width,
          height: size.height,
          color: AppColor.primaryColor(context),
          child: Column(
            children: [
              SizedBox(height: size.height * 5 / 100),
              AppHeader(
                text: AppLanguage.reportAproblemText[language],
                onPress: () => Navigator.pop(context),
              ),
              SizedBox(height: size.height * 2 / 100),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 5 / 100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Description Heading
                      Container(
                        width: size.width * 90 / 100,
                        child: Text(
                          AppLanguage.descriptionText[language],
                          style:  TextStyle(
                            color: AppColor.secondryColor(context),
                            fontSize: 18,
                            fontFamily: AppFont.fontFamily,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 2 / 100),

                      /// Description Field
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 4 / 100,
                          vertical: size.height * .5 / 100,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xff36214A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: messageTextEditingController,
                          maxLines: 5,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: AppFont.fontFamily,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                AppLanguage.describeYourIssueText[language],
                            hintStyle:  TextStyle(
                                color: AppColor.filledText(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w400),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 3 / 100),

                      /// Add Screenshots
                      Text(
                        AppLanguage.addScreenshotsText[language],
                        style:  TextStyle(
                          color: AppColor.secondryColor(context),
                          fontSize: 17,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: size.height * 0.1 / 100),

                      Text(
                        AppLanguage.addScreenshotsHintText[language],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      SizedBox(height: size.height * 1.5 / 100),

                      /// Screenshot Boxes
                      Row(
                        children: [
                          _uploadBox(size, isAdd: true),
                          SizedBox(width: size.width * 3 / 100),
                          _uploadSecondBox(size),
                        ],
                      ),
                      SizedBox(height: size.height * 15 / 100),

                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: AppFont.fontFamily,
                              color: Colors.white.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                            ),
                            children:  [
                              TextSpan(
                                text: "By submitting, you allow ",
                                style: TextStyle(
                                    color: AppColor.spancolor(context),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                              ),
                              TextSpan(
                                text: "Hii App",
                                style: TextStyle(
                                    color: AppColor.spancolor(context),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12),
                              ),
                              TextSpan(
                                text:
                                    " to preview related technical info to help address your feedback",
                                style: TextStyle(
                                    color: AppColor.spancolor(context),
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 3 / 100),

                      Center(
                        child: AppButton(
                            text: AppLanguage.submitText[language],
                            onPress: () {
                              Navigator.pop(context);
                            }),
                      ),

                      SizedBox(height: size.height * 2 / 100),

                      /// Footer Text
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _uploadBox(Size size, {bool isAdd = false}) {
    return Container(
      height: size.width * 32 / 100,
      width: size.width * 27 / 100,
      decoration: BoxDecoration(
        // color: const Color(0xff2C1B3A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColor.buttonColor,
          width: .7,
        ),
      ),
      child: isAdd
          ? Center(
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: size.width * 6 / 100,
              ),
            )
          : null,
    );
  }

  Widget _uploadSecondBox(Size size, {bool isAdd = false}) {
    return Container(
      height: size.width * 32 / 100,
      width: size.width * 27 / 100,
      decoration: BoxDecoration(
        // color: const Color(0xff2C1B3A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColor.textTapColor(context),
          width: .7,
        ),
      ),
      // child: isAdd
      //     ? Center(
      //         child: Icon(
      //           Icons.add,
      //           color: Colors.white,
      //           size: size.width * 6 / 100,
      //         ),
      //       )
      //     : null,
    );
  }
}
