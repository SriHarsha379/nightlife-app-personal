import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
import 'package:night_life/view/other/city_Preference/citypreference_screen.dart';
import 'package:page_transition/page_transition.dart';

import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/app_validation.dart';
import '../../provider/post_api_provider.dart';

class OtpVerify extends StatefulWidget {
  final String? mobile;
  static String routeName = './OtpVerify';
  const OtpVerify({super.key, this.mobile});

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final GlobalKey<FormState> _forgotOtpFormKey = GlobalKey<FormState>();
  TextEditingController pinputInputController = TextEditingController();

  // Timer variables
  Timer? _timer;
  int _remainingSeconds = 30; // 30 seconds timer
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

  // Start countdown timer
  void _startTimer() {
    setState(() {
      _remainingSeconds = 30;
      _canResend = false;
    });

    _timer?.cancel(); // Cancel any existing timer
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

  // Resend OTP
  void _resendOTP() {
    if (_canResend) {
      _startTimer();
    }
  }

  // Verify OTP
  void _verifyOTP() {
    if (Validation.isFieldEmpty(
      context,
      value: pinputInputController.text,
      fieldName: "OTP",
    )) return;

    if (!Validation.isOtpLength(
      context,
      pinputInputController.text,
      minLength: 4,
    )) return;

    print("Verifying OTP: ${pinputInputController.text}");

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    apiProvider.otpVerificationApiCalling(
        context, pinputInputController.text, widget.mobile.toString());
  }

  // Format timer display (00:30 format)
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        systemNavigationBarColor: AppColor.transparentColor,
        systemNavigationBarIconBrightness: Brightness.light,
        statusBarColor: AppColor.transparentColor,
        statusBarIconBrightness: Brightness.light));

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColor.secondryColor,
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 100 / 100,
          decoration: BoxDecoration(gradient: AppColor.backgroundGradientcolor),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _forgotOtpFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 6 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 90 / 100,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 70 / 100,
                      child: Text(
                        AppLanguage.otpVerificationText[language],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColor.secondryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFont.fontFamily,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 1 / 100,
                    ),
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
                      // width: MediaQuery.of(context).size.width * 48.5 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "+91 ${widget.mobile}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 1 / 100,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 7 / 100,
                    ),

                    // OTP Input Pinput
                    Pinput(
                      length: 4,
                      controller: pinputInputController,
                      defaultPinTheme: PinTheme(
                        width: MediaQuery.of(context).size.width * 15.8 / 100,
                        height: MediaQuery.of(context).size.width * 14 / 100,
                        textStyle: const TextStyle(
                          fontFamily: AppFont.fontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColor.primaryColor,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.secondryColor,
                          border: Border.all(
                            color: AppColor.secondryColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 0,
                                color: AppColor.primaryColor.withOpacity(0.25))
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

                    // Timer and Resend Logic
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 85 / 100,
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
                            width: MediaQuery.of(context).size.width * 1 / 100,
                          ),

                          // Show Timer or Resend based on _canResend
                          if (!_canResend) ...[
                            // Show Timer
                            Text(
                              _formatTime(_remainingSeconds),
                              style: const TextStyle(
                                  color: AppColor.buttonColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ] else ...[
                            // Show Resend Button
                            GestureDetector(
                              onTap: _resendOTP,
                              child: Text(
                                AppLanguage.resend[language],
                                style: const TextStyle(
                                    color: AppColor.buttonColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColor.buttonColor),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 36 / 100,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 80 / 100,
                      height: MediaQuery.of(context).size.height * 4.5 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [],
                      ),
                    ),

                    // Login with Password Text
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${AppLanguage.cantacessthis[language]} ",
                            style: const TextStyle(
                              color: AppColor.secondryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFont.fontFamily,
                            ),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                AppLanguage.loginwithPassword[language],
                                style: const TextStyle(
                                  color: AppColor.appButtonColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: AppFont.fontFamily,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      textWidthBasis: TextWidthBasis.parent,
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 2 / 100,
                    ),

                    // Verify Button

                    Consumer<PostApiProvider>(
                      builder: (context, apiprovider, child) {
                        return apiprovider.loading
                            ? const CircularProgressIndicator(
                                color: AppColor.pinkColor)
                            : AppButton(
                                text: AppLanguage.verifyButtonText[language],
                                onPress: () {
                                  FocusScope.of(context).unfocus();
                                  _verifyOTP();
                                },
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
