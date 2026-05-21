import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/app_snack_bar_toast_message.dart';
import '../../../utilities/app_validation.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_image.dart';
import 'create_new_password.dart';

class ForgotOtpverify extends StatefulWidget {
  static String routeName = './OtpVerify';
  const ForgotOtpverify({
    super.key,
    required this.isEmail,
    required this.identifier,
  });

  final bool isEmail;
  final String identifier;

  @override
  State<ForgotOtpverify> createState() => _ForgotOtpverifyState();
}

class _ForgotOtpverifyState extends State<ForgotOtpverify> {
  static const int _otpExpirySeconds = 120;
  static const int _maxOtpRetries = 5;
  final TextEditingController pinputInputController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = _otpExpirySeconds;
  bool _canResend = false;
  bool _isOtpExpired = false;
  int _retryCount = 0;

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

  void _startTimer() {
    setState(() {
      _remainingSeconds = _otpExpirySeconds;
      _canResend = false;
      _isOtpExpired = false;
      _retryCount = 0;
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
          _isOtpExpired = true;
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

  Future<void> _verifyForgotOtp() async {
    final otp = pinputInputController.text.trim();
    if (Validation.isFieldEmpty(context, value: otp, fieldName: "OTP")) return;
    if (_isOtpExpired) {
      SnackBarToastMessage.error(
        context,
        "OTP expired. Please resend and try again.",
      );
      return;
    }
    if (_retryCount >= _maxOtpRetries) {
      SnackBarToastMessage.error(
        context,
        "Retry limit reached. Please resend OTP.",
      );
      return;
    }
    if (!Validation.isOtpLength(context, otp)) return;

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    final res = await apiProvider.forgotOtpVerificationApiCalling(
      context,
      otp: otp,
      email: widget.isEmail ? widget.identifier : null,
      phoneNumber: widget.isEmail ? null : widget.identifier,
    );

    if (!mounted) return;
    if (res != null && res['success'] == true) {
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftWithFade,
          child: const CreateNewPasswordScreen(),
          duration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      setState(() {
        _retryCount++;
      });
      if (_retryCount >= _maxOtpRetries) {
        SnackBarToastMessage.error(
          context,
          "Retry limit reached. Please resend OTP.",
        );
      }
    }
  }

  Future<void> _resendForgotOtp() async {
    if (!_canResend) return;

    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    final res = await apiProvider.forgotResendotpApiCalling(
      context,
      email: widget.isEmail ? widget.identifier : null,
      phoneNumber: widget.isEmail ? null : widget.identifier,
    );

    if (!mounted) return;
    if (res != null && res['success'] == true) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: GestureDetector(
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
                            "We have sent a 6-digit verification code to",
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
                          width: MediaQuery.of(context).size.width * 80 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  widget.identifier,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColor.secondryColor(context),
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: AppFont.fontFamily,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 7 / 100,
                        ),
                        Pinput(
                          length: 6,
                          controller: pinputInputController,
                          defaultPinTheme: PinTheme(
                            width:
                                MediaQuery.of(context).size.width * 12 / 100,
                            height:
                                MediaQuery.of(context).size.width * 12 / 100,
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
                                horizontal: MediaQuery.of(context).size.width *
                                    0.6 /
                                    100),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 3 / 100,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 80 / 100,
                          height:
                              MediaQuery.of(context).size.height * 4.5 / 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLanguage.didntOtpText[language],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
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
                                Consumer<PostApiProvider>(
                                  builder: (context, apiProvider, child) {
                                    if (apiProvider.secondaryLoading) {
                                      return const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColor.buttonColor,
                                        ),
                                      );
                                    }
                                    return GestureDetector(
                                      onTap: _resendForgotOtp,
                                      child: Text(
                                        AppLanguage.resend[language],
                                        style: const TextStyle(
                                          color: AppColor.buttonColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColor.buttonColor,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 39 / 100,
                        ),
                        Consumer<PostApiProvider>(
                          builder: (context, apiProvider, child) {
                            if (apiProvider.loading) {
                              return const CircularProgressIndicator(
                                color: AppColor.pinkColor,
                              );
                            }
                            return AppButton(
                              text: AppLanguage.verifyButtonText[language],
                              onPress: () {
                                _verifyForgotOtp();
                              },
                            );
                          },
                        ),
                      ],
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
