import 'dart:async';
import 'package:flutter/material.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../provider/post_api_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/app_validation.dart';

class StayConnectedOTPVerify extends StatefulWidget {
  final bool? isEmail;
  final String? email;
  static String routeName = './StayConnectedOTPVerify';
  const StayConnectedOTPVerify({
    super.key,
    this.isEmail,
    this.email,
  });

  @override
  State<StayConnectedOTPVerify> createState() => _StayConnectedOTPVerifyState();
}

class _StayConnectedOTPVerifyState extends State<StayConnectedOTPVerify> {
  TextEditingController pinputInputController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinputInputController.dispose();
    super.dispose();
  }

  void nextField(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
  }

  void previousField(String value, FocusNode focusNode) {
    focusNode.requestFocus();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 30;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> otpValidation(BuildContext context) async {
    final otp = pinputInputController.text.trim();

    if (Validation.isFieldEmpty(
      context,
      value: otp,
      fieldName: "OTP",
    )) {
      return;
    }

    if (!Validation.isOtpLength(
      context,
      otp,
      minLength: 4,
    )) {
      return;
    }

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    final res = await apiProvider.verifyEmailOtpApiCalling(
      context,
      otp: otp,
      email: widget.email,
    );
    if (res == null || !context.mounted) return;

    AppConstant.selectFooterIndex = 0;
    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeftWithFade,
        child: const MyAppFooter(initialIndex: 0),
        duration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<PostApiProvider>(context);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondryColor(context),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 6 / 100,
              ),

              //! App Header
              SizedBox(
                width: MediaQuery.of(context).size.width * 90 / 100,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 5 / 100,
                        height: MediaQuery.of(context).size.width * 5 / 100,
                        child: Image.asset(
                          AppImage.backarrow,
                          color: AppColor.secondryColor(context),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 2 / 100,
                    ),
                    Text(
                      AppLanguage.otpVerificationText[language],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColor.secondryColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFont.fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 10 / 100,
              ),

              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 80 / 100,
                        child: Text(
                          AppLanguage.enter4digitText[language],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                            fontFamily: AppFont.fontFamily,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 1 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 90 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (widget.email != null &&
                                      widget.email!.trim().isNotEmpty)
                                  ? widget.email!
                                  : AppLanguage.xyzgmailText[language],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
                                fontSize: 17,
                                fontWeight: FontWeight.normal,
                                fontFamily: AppFont.fontFamily,
                              ),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 1 / 100,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 7 / 100,
                      ),
                      Pinput(
                        length: 4,
                        controller: pinputInputController,
                        defaultPinTheme: PinTheme(
                          width: MediaQuery.of(context).size.width * 15.8 / 100,
                          height: MediaQuery.of(context).size.width * 14 / 100,
                          textStyle: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white
                                : Color.fromARGB(255, 233, 231, 231),
                            border: Border.all(
                              color: Colors.black,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 0,
                                  color: AppColor.primaryColor(context)
                                      .withOpacity(0.25))
                            ],
                            borderRadius: BorderRadius.circular(13),
                          ),
                          margin: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 1 / 100),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 3 / 100,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 80 / 100,
                        height: MediaQuery.of(context).size.height * 4.5 / 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLanguage.didntOtpText[language],
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12),
                            ),
                            SizedBox(
                              width:
                                  MediaQuery.of(context).size.width * 1 / 100,
                            ),
                            if (!_canResend) ...[
                              Text(
                                _formatTime(_remainingSeconds),
                                style: const TextStyle(
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ] else ...[
                              GestureDetector(
                                onTap: apiProvider.secondaryLoading
                                    ? null
                                    : () async {
                                        final res = await apiProvider
                                            .resendEmailOtpApiCalling(
                                          context,
                                          email: widget.email,
                                        );
                                        if (res != null) {
                                          _startTimer();
                                        }
                                      },
                                child: Text(
                                  apiProvider.secondaryLoading
                                      ? "Sending..."
                                      : AppLanguage.resend[language],
                                  style: const TextStyle(
                                    color: AppColor.buttonColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColor.buttonColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 39 / 100,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 4 / 100,
                      ),
                      AppButton(
                          text: AppLanguage.verifyButtonText[language],
                          onPress: () async {
                            await otpValidation(context);
                          }),
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
}
