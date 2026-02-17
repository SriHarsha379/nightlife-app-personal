import 'package:flutter/material.dart';

import '../utilities/app_color.dart';
import '../utilities/app_font.dart';

class BookingSuccessDialog extends StatefulWidget {
  final String message;
  final VoidCallback onDone;

  const BookingSuccessDialog({
    super.key,
    required this.message,
    required this.onDone,
  });

  @override
  State<BookingSuccessDialog> createState() => _BookingSuccessDialogState();
}

class _BookingSuccessDialogState extends State<BookingSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _popupCtrl;
  late AnimationController _checkCtrl;
  late Animation<double> _popupScale;
  late Animation<double> _popupFade;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _popupCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _popupScale = CurvedAnimation(parent: _popupCtrl, curve: Curves.elasticOut);
    _popupFade = CurvedAnimation(parent: _popupCtrl, curve: Curves.easeIn);
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.easeOutBack);

    _popupCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _checkCtrl.forward();
    });
  }

  @override
  void dispose() {
    _popupCtrl.dispose();
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 8 / 100,
        ),
        child: FadeTransition(
          opacity: _popupFade,
          child: ScaleTransition(
            scale: _popupScale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              decoration: BoxDecoration(
                color: const Color(0xff1E1A24),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppColor.buttonColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.buttonColor.withOpacity(0.25),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _checkScale,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xff4CAF50).withOpacity(0.12),
                        border: Border.all(
                          color: const Color(0xff4CAF50),
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Color(0xff4CAF50),
                        size: 48,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Booking Confirmed!',
                    style: TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppColor.pinkColor,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: widget.onDone,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColor.buttonColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Done',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppFont.fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
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
