import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'app_color.dart';
import 'app_constant.dart';
import 'app_font.dart';
import 'app_image.dart';


class CustomTextFieldInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final TextInputType keyboardType;
  final String? prefixIcon;

  const CustomTextFieldInput({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    required this.keyboardType,
    this.prefixIcon,
  }) : super(key: key);

  @override
  State<CustomTextFieldInput> createState() => _CustomTextFieldInputState();
}

class _CustomTextFieldInputState extends State<CustomTextFieldInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: AppColor.secondryColor),
      keyboardType: widget.keyboardType,
      controller: widget.controller,
      maxLength: widget.maxLength,
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
          borderSide: const BorderSide(
            color: AppColor.textfieldcontainercolor,
            width: 1, // Changed from 0 to 1 for consistency
          ),
        ),
        fillColor: AppColor.textfieldcontainercolor,
        filled: true,
        counterText: '',
        hintText: widget.hintText,
        hintStyle: AppConstant.textFilledStyle,
      ),
    );
  }
}

// kalash

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
      style: const TextStyle(color: AppColor.primaryColor),
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
                            color: AppColor.greyLightColor,
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
        hintStyle: AppConstant.textFilledStyle,
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
  
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
  }) : super(key: key);
  
  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}


class _CustomTextFieldState extends State<CustomTextField> {
  bool isPasswordVisible = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: AppColor.secondryColor),
      keyboardType: TextInputType.text,
      controller: widget.controller,
      focusNode: _focusNode, // Add focus node
      maxLength: widget.maxLength,
      // obscureText: isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 1, right: 5), 
          child: SizedBox(
            height: 24,
            width: 24,
            // child: Image.asset(
            //   AppImage.changePasswordIcon,
            //   color: AppColor.greyLightColor,
            // ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 30, 
          minHeight: 40,
        ),
        fillColor: _isFocused ? Colors.black : AppColor.themeColor, // Dynamic color
        filled: true,
        counterText: '',
        suffixIcon: IconButton(
          icon: isPasswordVisible
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  // child: Image.asset(
                  //   AppImage.visibleIcon,
                  //   color: AppColor.greyLightColor,
                  // ),
                )
              : SizedBox(
                  height: 24,
                  width: 24,
                  // child: Image.asset(
                  //   AppImage.visibleoffIcon,
                  //   color: AppColor.greyLightColor,
                  // ),
                ),
          onPressed: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppColor.buttonColor,
            width: 0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppColor.buttonColor,
            width: 1.5,
          ),
        ),
        hintText: widget.hintText,
        hintStyle: AppConstant.textFilledStyle,
        contentPadding: const EdgeInsets.only(
          left: 10,  
          right: 20,
          top: 15,
          bottom: 15,
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
                style: const TextStyle(
                    color: AppColor.secondryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    fontFamily: AppFont.fontFamily),
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
          color: AppColor.secondryColor,
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
  final TextInputType keyboardType;

  final EdgeInsets? contentPadding;
  final int? maxLines;
  final Widget? prefixIcon;
  final String? prefixText;
  const CustomTextAreaField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.maxLength,
    required this.keyboardType,
    this.maxLines,
    this.prefixIcon,
    this.prefixText,
    required this.readOnly,
    this.contentPadding,
  });
  @override
 Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: AppColor.primaryColor),
      // keyboardType: widget.keyboardType,
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        prefixIcon: prefixText != null || prefixIcon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(width: MediaQuery.of(context).size.width*3.5/100),
                  if (prefixIcon != null) ...[
                    prefixIcon!,
                    SizedBox(width: MediaQuery.of(context).size.width*3/100),
                  ],
                  if (prefixText != null) ...[
                    Text(
                      prefixText!,
                      style: const TextStyle(
                        color: AppColor.primaryColor,
                        fontFamily: AppFont.fontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*3/100),

                    // Container(
                    //   height: 20,
                    //   width: 1,
                    //   color: AppColor.primaryColor.withOpacity(0.5),
                    // ),
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
        hintStyle: AppConstant.textFilledStyle,
        
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
// class AppButtonsmalltext extends StatefulWidget {
//   final String text;
//   final Function onPress;

//   const AppButtonsmalltext({
//     Key? key,
//     required this.text,
//     required this.onPress,
//   }) : super(key: key);

//   @override
//   State<AppButtonsmalltext> createState() => _AppButtonsmalltextState();
// }

// class _AppButtonsmalltextState extends State<AppButtonsmalltext> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         widget.onPress();
//       },
//       child: Container(
//         width: MediaQuery.of(context).size.width * 90 / 100,
//         height: MediaQuery.of(context).size.height * 7 / 100,
//         decoration: const BoxDecoration(
//           color: AppColor.themeColor,
//           borderRadius: BorderRadius.all(Radius.circular(40)),
//         ),
//         alignment: Alignment.center,
//         child: Text(
//           widget.text,
//           style: const TextStyle(
//               color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
