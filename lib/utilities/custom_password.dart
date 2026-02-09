import 'package:flutter/material.dart';
import '../utilities/app_color.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_font.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final bool readOnly;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? iconColor;
  final EdgeInsets? contentPadding;
  final String? prefixText;
  final Widget? prefixIcon;

  const CustomPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    this.readOnly = false,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.borderColor,
    this.iconColor,
    this.contentPadding,
    this.prefixText,
    this.prefixIcon,
  });

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        color: widget.textColor ?? AppColor.primaryColor(context),
      ),
      keyboardType: TextInputType.visiblePassword,
      controller: widget.controller,
      cursorColor: widget.textColor ?? AppColor.primaryColor(context),
      maxLength: widget.maxLength,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        prefixIcon: widget.prefixText != null || widget.prefixIcon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 3.5 / 100),
                  if (widget.prefixIcon != null) ...[
                    widget.prefixIcon!,
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 3 / 100),
                  ],
                  if (widget.prefixText != null) ...[
                    Text(
                      widget.prefixText!,
                      style: TextStyle(
                        color:
                            widget.textColor ?? AppColor.primaryColor(context),
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 3 / 100),
                  ],
                ],
              )
            : null,
        suffixIcon: Padding(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 5 / 100,
          ),
          child: GestureDetector(
            onTap: _togglePasswordVisibility,
            child: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.black.withOpacity(0.6),
              size: 22,
            ),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColor.textfieldfillColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: widget.borderColor ?? AppColor.textfieldfillColor,
            width: 1.5,
          ),
        ),
        fillColor: widget.fillColor ?? AppColor.textfieldfillColor,
        filled: true,
        counterText: '',
        hintText: widget.hintText,
        hintStyle: widget.hintColor != null
            ? TextStyle(
                color: widget.hintColor,
                fontFamily: AppFont.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              )
            : TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontFamily: AppFont.fontFamily,
                fontSize: 14,
              ),
        contentPadding: widget.contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
      ),
    );
  }
}

// Wrapper for Password Field with Label
class PasswordFieldWrapper extends StatelessWidget {
  final String label;
  final CustomPasswordField child;
  final bool hasGapBelow;

  const PasswordFieldWrapper({
    super.key,
    required this.label,
    required this.child,
    this.hasGapBelow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            fontFamily: AppFont.fontFamily,
            color: AppColor.bottomsheettextcolor,
          ),
        ),
        const SizedBox(height: 6.0),
        child,
        if (hasGapBelow) const SizedBox(height: 12.0),
      ],
    );
  }
}
