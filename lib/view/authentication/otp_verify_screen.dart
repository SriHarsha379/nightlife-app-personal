import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/login_screen.dart';
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
import '../../utilities/firebase_otp_service.dart';

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
  static const int _otpExpirySeconds = 120;
  static const int _maxOtpRetries = 5;
  Timer? _timer;
  int _remainingSeconds = _otpExpirySeconds;
  bool _canResend = false;
  bool _isOtpExpired = false;
  int _retryCount = 0;

  bool _isSendingInitialOtp = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _sendInitialFirebaseOtp();
  }

  Future<void> _sendInitialFirebaseOtp() async {
    setState(() => _isSendingInitialOtp = true);
    await FirebaseOtpService.sendOtp(
      phoneNumber: widget.mobile.toString(),
      context: context,
      onError: (error) {
        if (!mounted) return;
        setState(() => _isSendingInitialOtp = false);
        SnackBarToastMessage.error(context, error);
      },
      onCodeSent: () {
        if (!mounted) return;
        setState(() => _isSendingInitialOtp = false);
      },
    );
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
      _remainingSeconds = _otpExpirySeconds;
      _canResend = false;
      _isOtpExpired = false;
      _retryCount = 0;
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
          _isOtpExpired = true;
        });
        timer.cancel();
      }
    });
  }

  // Resend OTP
  Future<void> _resendOTP() async {
    if (!_canResend) return;
    setState(() => _isSendingInitialOtp = true);
    final sent = await FirebaseOtpService.resendOtp(
      phoneNumber: widget.mobile.toString(),
      context: context,
      onError: (error) {
        if (!mounted) return;
        setState(() => _isSendingInitialOtp = false);
        SnackBarToastMessage.error(context, error);
      },
      onCodeSent: () {
        if (!mounted) return;
        setState(() => _isSendingInitialOtp = false);
      },
    );
    if (sent) {
      _startTimer();
    }
  }

  // Verify OTP
  Future<void> _verifyOTP() async {
    if (Validation.isFieldEmpty(
      context,
      value: pinputInputController.text,
      fieldName: "OTP",
    )) return;

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

    if (!Validation.isOtpLength(context, pinputInputController.text, minLength: 4)) return;

    print("Verifying OTP: ${pinputInputController.text}");

    final firebaseVerified = await FirebaseOtpService.verifyOtp(
      otp: pinputInputController.text,
      onError: (error) {
        if (!mounted) return;
        SnackBarToastMessage.error(context, error);
      },
    );

    if (!firebaseVerified) {
      if (!mounted) return;
      setState(() {
        _retryCount++;
      });
      return;
    }

    if (!mounted) return;
    final apiProvider = Provider.of<PostApiProvider>(context, listen: false);
    final isVerified = await apiProvider.otpVerificationApiCalling(
      context,
      pinputInputController.text,
      widget.mobile.toString(),
    );
    if (!mounted) return;
    if (isVerified) return;

    setState(() {
      _retryCount++;
    });
  }

  // Format timer display (00:30 format)
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
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
                          style: TextStyle(
                            color: AppColor.secondryColor(context),
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
                          "We have sent a 4-digit verification code to",
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

                      // OTP Input Pinput
                      Pinput(
                        length: 4,
                        controller: pinputInputController,
                        defaultPinTheme: PinTheme(
                          width: MediaQuery.of(context).size.width * 12 / 100,
                          height: MediaQuery.of(context).size.width * 12 / 100,
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
                                  MediaQuery.of(context).size.width * 0.6 / 100),
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
                              width:
                                  MediaQuery.of(context).size.width * 1 / 100,
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
                                onTap: () async {
                                  await _resendOTP();
                                },
                                child: Text(
                                  context.watch<PostApiProvider>().secondaryLoading
                                      ? "Sending..."
                                      : AppLanguage.resend[language],
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
                              style: TextStyle(
                                color: AppColor.secondryColor(context),
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
                                    // decoration: TextDecoration.underline,
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
      ),
    );
  }
}
