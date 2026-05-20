import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import '../../utilities/app_button.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_language.dart';
import '../../utilities/widgets.dart';

class AppPopup extends StatelessWidget {
  final String dialogHeading;
  final String dialogSubHeading;
  final String mainButtonText;
  final String secondaryButtonText;
  final Function() onPressMainButton;
  final Function() onPressSecondaryButton;
  final String? icon;
  const AppPopup({
    super.key,
    required this.dialogHeading,
    required this.dialogSubHeading,
    required this.mainButtonText,
    required this.secondaryButtonText,
    required this.onPressMainButton,
    required this.onPressSecondaryButton,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: size.width * 90 / 100,
            padding: EdgeInsets.all(size.width * 4 / 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColor.secondryColor(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: size.height * 3 / 100,
                ),
                Text(
                  dialogHeading,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 1 / 100),
                Text(
                  dialogSubHeading,
                  style:  TextStyle(
                    color: AppColor.primaryColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFont.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 2 / 100),
                SizedBox(
                  width: size.width * 90 / 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            child: AppButtonwithoutcolour(
                              text: mainButtonText,
                              onPress: () {
                                onPressMainButton();
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 4 / 100,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            child: AppButton(
                              text: secondaryButtonText,
                              onPress: () {
                                onPressSecondaryButton();
                              },
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
          icon != null
              ? Positioned(
                  top: -(size.height * 4 / 100),
                  child: Container(
                    padding: EdgeInsets.all(size.width * 1 / 100),
                    decoration:  BoxDecoration(
                        shape: BoxShape.circle, color: AppColor.secondryColor(context)),
                    child: Image.asset(
                      icon!,
                      width: size.width * 18 / 100,
                      height: size.width * 18 / 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class CustomPopup {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    Color? cancelColor,
    IconData? icon,
    Color? iconColor,
    bool isDanger = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => ModernPopupDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        cancelColor: cancelColor,
        icon: icon,
        iconColor: iconColor,
        isDanger: isDanger,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  static Future<void> showExitConfirmation(BuildContext context) {
    return show(
        context: context,
        title: AppLanguage.exitAppText[language],
        message: AppLanguage.logoutText[language],
        confirmText: AppLanguage.exitAppText[language],
        cancelText: AppLanguage.saaveText[language],
        icon: Icons.exit_to_app_rounded,
        isDanger: true,
        onConfirm: () {
          SystemNavigator.pop();
        },
        onCancel: () {
          Navigator.pop(context);
        });
  }
}

class ModernPopupDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final Color? cancelColor;
  final IconData? icon;
  final Color? iconColor;
  final bool isDanger;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const ModernPopupDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
    this.cancelColor,
    this.icon,
    this.iconColor,
    this.isDanger = false,
    this.onConfirm,
    this.onCancel,
  }) : super(key: key);

  @override
  State<ModernPopupDialog> createState() => _ModernPopupDialogState();
}

class _ModernPopupDialogState extends State<ModernPopupDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _primaryColor =>
      widget.isDanger ? AppColor.thirdColor : AppColor.themeColor;

  Color get _confirmButtonColor => widget.confirmColor ?? _primaryColor;
  Color get _cancelButtonColor => widget.cancelColor ?? AppColor
                                                        .greyLightColor(context);
  Color get _iconColor => widget.iconColor ?? _primaryColor;

  void _handleConfirm() {
    widget.onConfirm?.call();
  }

  void _handleCancel() {
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Dialog(
              elevation: 24,
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      if (widget.icon != null) ...[
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: _iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 32,
                            color: _iconColor,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Title
                      Text(
                        widget.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.white : Colors.grey.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Message
                      Text(
                        widget.message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDarkMode
                              ? Colors.grey.shade300
                              : Colors.grey.shade600,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          // Cancel Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _handleCancel,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _cancelButtonColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          _cancelButtonColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.cancelText,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _cancelButtonColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Confirm Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _handleConfirm,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _confirmButtonColor,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _confirmButtonColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.confirmText,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
