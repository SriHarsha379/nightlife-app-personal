import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_font.dart';

/// A labelled text field that keeps its label visible after typing.
/// Fixes audit point #05 — labels disappearing after entry.
/// Drop-in replacement for CustomTextField everywhere.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLength;
  final bool readOnly;
  final bool isPassword;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLength = 100,
    this.readOnly = false,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      obscureText: widget.isPassword && _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      validator: widget.validator,
      cursorColor: AppColor.buttonColor,
      style: TextStyle(
        color: AppColor.secondryColor(context),
        fontSize: 15,
        fontFamily: AppFont.fontFamily,
      ),
      decoration: InputDecoration(
        // ✅ FIX: labelText stays visible after typing
        labelText: widget.label,
        labelStyle: TextStyle(
          color: _isFocused
              ? AppColor.buttonColor
              : AppColor.hinttextcolor(context),
          fontSize: 14,
          fontFamily: AppFont.fontFamily,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: TextStyle(
          color: _isFocused
              ? AppColor.buttonColor
              : AppColor.hinttextcolor(context),
          fontSize: 12,
          fontFamily: AppFont.fontFamily,
          fontWeight: FontWeight.w600,
        ),
        hintText: widget.hint ?? widget.label,
        hintStyle: TextStyle(
          color: AppColor.hinttextcolor(context).withValues(alpha: 0.5),
          fontSize: 14,
          fontFamily: AppFont.fontFamily,
        ),
        counterText: '',
        filled: true,
        fillColor: _isFocused
            ? AppColor.whiteBlackcolor(context)
            : AppColor.textFieldColor(context),
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: IconTheme(
                  data: IconThemeData(
                    color: AppColor.hinttextcolor(context),
                    size: 20,
                  ),
                  child: widget.prefixIcon!,
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColor.hinttextcolor(context),
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,
        contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark
                ? AppColor.buttonColor.withValues(alpha: 0.4)
                : AppColor.greyLightColor(context),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColor.buttonColor,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColor.greyLightColor(context).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
