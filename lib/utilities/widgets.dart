import 'package:flutter/material.dart';
import 'app_color.dart';
import 'app_constant.dart';
import 'app_font.dart';

class CustomTextFieldInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final TextInputType keyboardType;
  final String? prefixIcon;
  final Color? fillColor;
  final bool readOnly;

  const CustomTextFieldInput({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    required this.keyboardType,
    this.fillColor,
    this.prefixIcon,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<CustomTextFieldInput> createState() => _CustomTextFieldInputState();
}

class _CustomTextFieldInputState extends State<CustomTextFieldInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(color: AppColor.secondryColor(context)),
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ), // Added spacing
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 8 / 100,
                      width: MediaQuery.of(context).size.width * 8 / 100,
                      child: Image.asset(
                        widget.prefixIcon!,
                        color: AppColor.textcolor,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppColor.transparentColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: AppColor.textfieldcontainercolor(context),
            width: 1,
          ),
        ),
        fillColor:
            widget.fillColor ?? AppColor.textfieldcontainercolor(context),
        filled: true,
        counterText: '',
        hintText: widget.hintText,
        hintStyle: AppConstant.textFilledStyle(context),
      ),
    );
  }
}

class CustomDescriptionBox extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? prefixIcon;

  const CustomDescriptionBox({
    Key? key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      style: TextStyle(color: AppColor.primaryColor(context)),
      decoration: InputDecoration(
        prefixIcon: prefixIcon != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 15 / 100,
                    height: MediaQuery.of(context).size.height * 15 / 100,
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 1 / 100),
                      child: Column(
                        children: [
                          Image.asset(
                            prefixIcon!,
                            color: AppColor
                                                        .greyLightColor(context),
                            width: MediaQuery.of(context).size.width * 10 / 100,
                            height:
                                MediaQuery.of(context).size.height * 3 / 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : null,
        filled: true,
        fillColor: AppColor.textfieldfillColor,
        hintText: hintText,
        hintStyle: AppConstant.textFilledStyle(context),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColor.textfieldfillColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColor.textfieldfillColor,
            width: 0,
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final bool readOnly;
  final bool isPassword;
  final Widget? prefixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    this.readOnly = false,
    this.isPassword = false,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = false;
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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      maxLength: widget.maxLength,
      readOnly: widget.readOnly,
      obscureText: widget.isPassword && !isPasswordVisible,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : TextInputType.text,
      cursorColor: AppColor.secondryColor(context),
      style: TextStyle(
        color: AppColor.secondryColor(context),
        fontSize: 14,
      ),
      decoration: InputDecoration(
        filled: true,

        /// ✅ FIX: Theme aware fill color
        fillColor: _isFocused
            ? AppColor.whiteBlackcolor(context)
            : AppColor.textFieldColor(context),

        counterText: '',

        hintText: widget.hintText,

        /// ✅ FIX: Theme aware hint
        hintStyle: TextStyle(
          color: AppColor.hinttextcolor(context),
          fontWeight: FontWeight.w400,
          fontFamily: AppFont.fontFamily,
          fontSize: 14,
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 14,
        ),

        /// PREFIX ICON
        prefixIcon: widget.prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: IconTheme(
                  data: IconThemeData(
                    color: AppColor.hinttextcolor(context),
                  ),
                  child: widget.prefixIcon!,
                ),
              )
            : null,

        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),

        /// PASSWORD ICON
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColor.hinttextcolor(context),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: isDark ? AppColor.buttonColor : AppColor
                                                        .greyLightColor(context),
            width: 1,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppColor.buttonColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class AppIconButton extends StatefulWidget {
  final Widget icon;
  final String? text;
  final VoidCallback onPress;

  const AppIconButton({
    Key? key,
    required this.icon,
    required this.onPress,
    this.text,
  }) : super(key: key);

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: Container(
        width: MediaQuery.of(context).size.width * 11 / 100,
        height: MediaQuery.of(context).size.height * 5 / 100,
        decoration: const BoxDecoration(
          color: AppColor.themeColor,
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.icon,
            if (widget.text != null) ...[
              SizedBox(width: MediaQuery.of(context).size.width * 0.1 / 100),
              Text(
                widget.text!,
                style: TextStyle(
                    color: AppColor.secondryColor(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    fontFamily: AppFont.lexendFontFamily),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// Kalash

class AppButtonwithoutcolour extends StatefulWidget {
  final String text;
  final Function onPress;

  const AppButtonwithoutcolour({
    Key? key,
    required this.text,
    required this.onPress,
  }) : super(key: key);

  @override
  State<AppButtonwithoutcolour> createState() => _AppButtonwithoutcolourState();
}

class _AppButtonwithoutcolourState extends State<AppButtonwithoutcolour> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onPress();
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 90 / 100,
        height: MediaQuery.of(context).size.height * 7 / 100,
        decoration: BoxDecoration(
          border: Border.all(color: AppColor.themeColor),
          color: AppColor.secondryColor(context),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.text,
          style: const TextStyle(
              color: AppColor.themeColor,
              fontWeight: FontWeight.w600,
              fontSize: 18),
        ),
      ),
    );
  }
}

class CustomTextAreaField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final bool readOnly;
  final TextInputType keyboardtype;

  final EdgeInsets? contentPadding;
  final int? maxLines;
  final Widget? prefixIcon;
  final String? prefixText;
  const CustomTextAreaField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    required this.keyboardtype,
    this.maxLines,
    this.prefixIcon,
    this.prefixText,
    required this.readOnly,
    this.contentPadding,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        color: Colors.black,
      ),
      keyboardType: keyboardtype,
      controller: controller,
      cursorColor: Colors.black,
      maxLength: maxLength,
      decoration: InputDecoration(
        prefixIcon: prefixText != null || prefixIcon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 3.5 / 100),
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 3 / 100),
                  ],
                  if (prefixText != null) ...[
                    Text(
                      prefixText!,
                      style: TextStyle(
                        color: Colors.black,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppColor.textfieldfillColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppColor.textfieldfillColor,
            width: 0,
          ),
        ),
        fillColor: AppColor.textfieldfillColor,
        filled: true,
        counterText: '',
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontFamily: AppFont.fontFamily,
          fontSize: 14,
        ),
      ),
    );
  }
}

class InputFieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;
  final bool hasGapBelow;
  const InputFieldWrapper(
      {super.key,
      required this.label,
      required this.child,
      this.hasGapBelow = true});

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
              color: AppColor.bottomsheettextcolor),
        ),
        const SizedBox(
          height: 6.0,
        ),
        child,
        if (hasGapBelow)
          const SizedBox(
            height: 12.0,
          ),
      ],
    );
  }
}

class CustomLoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final bool readOnly;
  final TextInputType keyboardType;
  final Color? fillColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? borderColor;
  final Color? cursorColor;
  final EdgeInsets? contentPadding;
  final int? maxLines;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final bool? enabled;

  const CustomLoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    this.keyboardType = TextInputType.text,
    this.readOnly = false,
    this.fillColor,
    this.textColor,
    this.hintColor,
    this.borderColor,
    this.cursorColor,
    this.contentPadding,
    this.maxLines,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: TextStyle(
        color: textColor ?? AppColor.primaryColor(context),
        fontFamily: AppFont.fontFamily,
      ),
      keyboardType: keyboardType,
      controller: controller,
      cursorColor: cursorColor ?? textColor ?? AppColor.primaryColor(context),
      maxLength: maxLength,
      maxLines: maxLines ?? 1,
      readOnly: readOnly,
      enabled: enabled,
      onChanged: onChanged,
      validator: validator,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        prefixIcon: prefixText != null || prefixIcon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 3.5 / 100),
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 3 / 100),
                  ],
                  if (prefixText != null) ...[
                    Text(
                      prefixText!,
                      style: TextStyle(
                        color: textColor ?? AppColor.primaryColor(context),
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    // SizedBox(
                    //     width: MediaQuery.of(context).size.width * 3 / 100),
                  ],
                ],
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 5 / 100,
                ),
                child: suffixIcon,
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: borderColor ?? AppColor.textfieldfillColor,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: borderColor ?? AppColor.textfieldfillColor,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: borderColor ?? AppColor.textfieldfillColor,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        fillColor: fillColor ?? AppColor.textfieldfillColor,
        filled: true,
        counterText: '',
        hintText: hintText,
        hintStyle: hintColor != null
            ? TextStyle(
                color: hintColor,
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
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 15,
            ),
      ),
    );
  }
}
