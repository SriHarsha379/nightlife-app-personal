// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
import 'package:night_life/utilities/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../provider/darkmode_provider.dart';
import '../../provider/post_api_provider.dart';
import '../../provider/user_controller.dart';

class EditHobbiesScreen extends StatefulWidget {
  const EditHobbiesScreen({super.key});
  static String routeName = './EditInfoScreen';
  @override
  State<EditHobbiesScreen> createState() => EditHobbiesScreenState();
}

class EditHobbiesScreenState extends State<EditHobbiesScreen> {
  List<Map<String, dynamic>> hobbies = [];

  int _nextId = 1;

  TextEditingController hobbiesTextController = TextEditingController();
  TextEditingController hobbyInputController = TextEditingController();
  late FocusNode _hobbiesFocusNode;
  bool _isHobbiesFocusNode = false;

  @override
  void initState() {
    super.initState();
    _loadLocalHobbies();
    _hobbiesFocusNode = FocusNode();
    _hobbiesFocusNode.addListener(() {
      setState(() {
        _isHobbiesFocusNode = _hobbiesFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _hobbiesFocusNode.dispose();
    hobbiesTextController.dispose();
    hobbyInputController.dispose();
    super.dispose();
  }

  void _updateHobbiesDisplay() {
    if (hobbies.isEmpty) {
      hobbiesTextController.text = "";
    } else {
      hobbiesTextController.text = hobbies.map((h) => h['hobby']).join(", ");
    }
  }

  Future<void> _loadLocalHobbies() async {
    final userController = Provider.of<UserController>(context, listen: false);
    await userController.getUserDetails();

    final List<String> hobbyNames = userController.getHobbies
        .map((hobby) {
      if (hobby is Map) {
        return (hobby['name'] ?? hobby['title'] ?? hobby['hobby'] ?? '')
            .toString()
            .trim();
      }
      return hobby.toString().trim();
    })
        .where((name) => name.isNotEmpty)
        .toList();

    if (!mounted) return;

    setState(() {
      if (hobbyNames.isNotEmpty) {
        hobbies = List<Map<String, dynamic>>.generate(hobbyNames.length,
                (index) => {"id": index + 1, "hobby": hobbyNames[index]});
      }
      _updateHobbiesDisplay();
      _nextId = hobbies.isNotEmpty ? hobbies.length + 1 : 1;
    });
  }

  void _addHobby(String hobby) {
    if (hobby.trim().isEmpty) {
      SnackBarToastMessage.error(context, "Please enter a hobby");
      return;
    }

    if (hobbies.any((h) =>
    h['hobby'].toString().toLowerCase() == hobby.trim().toLowerCase())) {
      SnackBarToastMessage.info(context, "This hobby already exists");
      return;
    }

    setState(() {
      hobbies.add({
        "id": _nextId,
        "hobby": hobby.trim(),
      });
      _nextId++;
      _updateHobbiesDisplay();
    });
    hobbyInputController.clear();
  }

  void _editHobby(int id, String newHobby) {
    if (newHobby.trim().isEmpty) {
      SnackBarToastMessage.error(context, "Please enter a hobby");
      return;
    }

    if (hobbies.any((h) =>
    h['id'] != id &&
        h['hobby'].toString().toLowerCase() == newHobby.trim().toLowerCase())) {
      SnackBarToastMessage.info(context, "This hobby already exists");
      return;
    }

    setState(() {
      final index = hobbies.indexWhere((h) => h['id'] == id);
      if (index != -1) {
        hobbies[index]['hobby'] = newHobby.trim();
        _updateHobbiesDisplay();
      }
    });
    hobbyInputController.clear();
  }

  void _deleteHobby(int id) {
    setState(() {
      hobbies.removeWhere((h) => h['id'] == id);
      _updateHobbiesDisplay();
    });
  }

  // ── helpers ──────────────────────────────────────────────────────────────
  /// Light mode mein dark text, dark mode mein white text
  Color _textColor(BuildContext context) => AppColor.secondryColor(context);

  /// Light mode ke liye hint text thoda zyada visible
  Color _hintColor(bool isDark) => isDark ? Colors.white54 : Colors.black45;

  /// TextField ki fill – light mode mein slightly off-white/grey
  Color _fieldFill(bool isDark) =>
      isDark ? AppColor.primaryColor(context) : const Color(0xFFF0F0F0);

  /// Bottom sheet background
  Color _sheetBg(bool isDark) => isDark ? AppColor.themeColor : Colors.white;

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                gradient: AppColor.backgroundGradientcolor(context)),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        children: [
                          // ── Header ──────────────────────────────────────
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width * 0.04,
                                  height:
                                  MediaQuery.of(context).size.height * 0.05,
                                  child: Image.asset(
                                    AppImage.backArrowIcon,
                                    // FIX: light mode mein arrow visible ho
                                    color: _textColor(context),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    AppLanguage.editHobbiesText[language],
                                    style: TextStyle(
                                      fontFamily: AppFont.fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      // FIX: theme-aware color
                                      color: _textColor(context),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                  width:
                                  MediaQuery.of(context).size.width * 0.04),
                            ],
                          ),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.015),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.04),

                          // ── Hobbies display field ────────────────────────
                          TextFormField(
                            // FIX: theme-aware input text color
                            style: TextStyle(
                                color: _textColor(context),
                                fontFamily: AppFont.fontFamily),
                            controller: hobbiesTextController,
                            focusNode: _hobbiesFocusNode,
                            readOnly: true,
                            decoration: InputDecoration(
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.06),
                                  Image.asset(
                                    AppImage.hobbiesImage,
                                    width: MediaQuery.of(context).size.width *
                                        0.06,
                                    height: MediaQuery.of(context).size.width *
                                        0.06,
                                    // FIX: icon color theme-aware
                                    color: isDark
                                        ? AppColor.greyLightColor(context)
                                        : Colors.black54,
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.03),
                                ],
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                  minWidth: 0, minHeight: 0),
                              suffixIconConstraints: const BoxConstraints(
                                  minWidth: 35, minHeight: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: BorderSide(
                                  // FIX: light mode mein border visible
                                  color: isDark
                                      ? AppColor.buttonColor
                                      : Colors.grey.shade300,
                                  width: isDark ? 0 : 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                    color: AppColor.buttonColor, width: 1.5),
                              ),
                              // FIX: fill color theme-aware
                              fillColor: _isHobbiesFocusNode
                                  ? AppColor.primaryColor(context)
                                  : (isDark
                                  ? AppColor.themeColor
                                  : const Color(0xFFF5F5F5)),
                              filled: true,
                              counterText: '',
                              hintText: AppLanguage.yourHobbiesText[language],
                              // FIX: hint style theme-aware
                              hintStyle: TextStyle(
                                color: _hintColor(isDark),
                                fontFamily: AppFont.fontFamily,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            onTap: () => _showAddHobbyBottomSheet(isDark),
                          ),
                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.02),

                          // ── Hobbies list ─────────────────────────────────
                          if (hobbies.isNotEmpty)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: hobbies.length,
                              itemBuilder: (context, index) {
                                final hobby = hobbies[index];
                                final id = hobby['id'] as int;
                                final hobbyName = hobby['hobby'] as String;

                                return Container(
                                  width:
                                  MediaQuery.of(context).size.width * 0.9,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    // FIX: card bg theme-aware
                                    color: isDark
                                        ? AppColor.primaryColor(context)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(isDark ? 0.05 : 0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // ID Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          // FIX: badge bg
                                          color: isDark
                                              ? AppColor.themeColor
                                              : const Color(0xFFEEEEEE),
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '#$id',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFont.fontFamily,
                                            color: _textColor(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          hobbyName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: AppFont.fontFamily,
                                            // FIX: hobby text color
                                            color: _textColor(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showEditHobbyBottomSheet(
                                            id, hobbyName, isDark),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          // FIX: edit icon theme-aware
                                          color: _textColor(context),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () =>
                                            _showDeleteConfirmationDialog(
                                                id, hobbyName, isDark),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                          SizedBox(
                              height:
                              MediaQuery.of(context).size.height * 0.38),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Continue Button ──────────────────────────────────────
                AppButton(
                    text: AppLanguage.continueText[language],
                    onPress: () async {
                      if (hobbies.isEmpty) {
                        SnackBarToastMessage.info(
                            context, "Please add at least one hobby");
                        return;
                      }

                      final List<String> hobbyNames = hobbies
                          .map((h) => h['hobby'].toString().trim())
                          .where((name) => name.isNotEmpty)
                          .toList();

                      final res = await Provider.of<PostApiProvider>(context,
                          listen: false)
                          .updateHobbiesApi(context, hobbyNames);

                      if (res != null) {
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeftWithFade,
                            child: const MyAppFooter(initialIndex: 4),
                            duration: const Duration(milliseconds: 400),
                          ),
                        );
                      }
                    }),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Add Hobby Bottom Sheet ────────────────────────────────────────────────
  // Chip-based multi-select using the same preset options shown at signup
  // (AppConstant.hobbyOptions), with a custom-entry fallback for hobbies
  // not in the preset list. Mirrors additional_info.dart's picker so both
  // screens stay in sync.
  void _showAddHobbyBottomSheet(bool isDark) {
    hobbyInputController.clear();

    // Working copy so Cancel doesn't affect the real list until "Done".
    final Set<String> tempSelected =
    hobbies.map((h) => h['hobby'].toString()).toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void toggle(String label) {
              final alreadySelected = tempSelected
                  .any((h) => h.toLowerCase() == label.toLowerCase());
              if (alreadySelected) {
                setSheetState(() {
                  tempSelected.removeWhere(
                          (h) => h.toLowerCase() == label.toLowerCase());
                });
                return;
              }
              if (tempSelected.length >= AppConstant.maxHobbies) {
                SnackBarToastMessage.info(context,
                    "You can select up to ${AppConstant.maxHobbies} hobbies");
                return;
              }
              setSheetState(() => tempSelected.add(label));
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  // FIX: sheet bg
                  color: _sheetBg(isDark),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select your hobbies",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFont.fontFamily,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pick up to ${AppConstant.maxHobbies}, or add your own",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: AppFont.fontFamily,
                        color: _hintColor(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: AppConstant.hobbyOptions.map((option) {
                            final label = option['label']!;
                            final isSelected = tempSelected.any(
                                    (h) => h.toLowerCase() == label.toLowerCase());
                            return GestureDetector(
                              onTap: () => toggle(label),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColor.pinkColor.withOpacity(0.18)
                                      : (isDark
                                      ? AppColor.primaryColor(context)
                                      : const Color(0xFFF0F0F0)),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColor.pinkColor
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(option['emoji']!,
                                        style: const TextStyle(fontSize: 15)),
                                    const SizedBox(width: 6),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontFamily: AppFont.fontFamily,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.check,
                                          size: 14, color: AppColor.pinkColor),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            hint: "Not listed? Type your own...",
                            controller: hobbyInputController,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            final custom = hobbyInputController.text.trim();
                            if (custom.isEmpty) return;
                            final alreadySelected = tempSelected.any((h) =>
                            h.toLowerCase() == custom.toLowerCase());
                            if (alreadySelected) {
                              SnackBarToastMessage.info(
                                  context, "This hobby already exists");
                              return;
                            }
                            if (tempSelected.length >=
                                AppConstant.maxHobbies) {
                              SnackBarToastMessage.info(context,
                                  "You can select up to ${AppConstant.maxHobbies} hobbies");
                              return;
                            }
                            setSheetState(() => tempSelected.add(custom));
                            hobbyInputController.clear();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: AppColor.pinkColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                // FIX: cancel btn bg
                                color: isDark
                                    ? AppColor.primaryColor(context)
                                    : const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFont.fontFamily,
                                  color:
                                  isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                // Keep existing ids for hobbies that are
                                // still selected, drop ones that were
                                // removed, and assign fresh ids to newly
                                // picked hobbies.
                                final List<Map<String, dynamic>> updated = [];
                                for (final h in hobbies) {
                                  final name = h['hobby'].toString();
                                  if (tempSelected.any((s) =>
                                  s.toLowerCase() == name.toLowerCase())) {
                                    updated.add(h);
                                  }
                                }
                                for (final label in tempSelected) {
                                  final exists = updated.any((h) =>
                                  h['hobby'].toString().toLowerCase() ==
                                      label.toLowerCase());
                                  if (!exists) {
                                    updated
                                        .add({"id": _nextId, "hobby": label});
                                    _nextId++;
                                  }
                                }
                                hobbies = updated;
                                _updateHobbiesDisplay();
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColor.pinkColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFont.fontFamily,
                                  color: AppColor.secondryColor(context),
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
            );
          },
        );
      },
    );
  }

  // ── Edit Hobby Bottom Sheet ───────────────────────────────────────────────
  void _showEditHobbyBottomSheet(int id, String currentHobby, bool isDark) {
    hobbyInputController.text = currentHobby;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              // FIX: sheet bg
              color: _sheetBg(isDark),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Edit hobby",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppFont.fontFamily,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColor.primaryColor(context)
                            : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: $id',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFont.fontFamily,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hint: "Type here...",
                  controller: hobbyInputController,
                  // inputFormatters: AppConstant.alphabetFormatter,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColor.primaryColor(context)
                                : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _editHobby(id, hobbyInputController.text);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColor.pinkColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Update",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppFont.fontFamily,
                              color: AppColor.secondryColor(context),
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
        );
      },
    );
  }

  // ── Delete Confirmation Dialog ────────────────────────────────────────────
  void _showDeleteConfirmationDialog(int id, String hobbyName, bool isDark) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // FIX: dialog bg theme-aware
          backgroundColor: isDark ? AppColor.themeColor : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Hobby",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFont.fontFamily,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Are you sure you want to delete this hobby?",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFont.fontFamily,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColor.primaryColor(context)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColor.themeColor
                            : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$id',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFont.fontFamily,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hobbyName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFont.fontFamily,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  // FIX: cancel text color
                  color: isDark ? Colors.white : Colors.black87,
                  fontFamily: AppFont.fontFamily,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _deleteHobby(id);
                Navigator.pop(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: AppFont.fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Build TextField ───────────────────────────────────────────────────────
  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
    required bool isDark,
  }) {
    return TextField(
      style: TextStyle(
        // FIX: typed text color
        color: isDark ? Colors.white : Colors.black87,
        fontFamily: AppFont.fontFamily,
      ),
      controller: controller,
      inputFormatters: inputFormatters,
      maxLength: 30,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          // FIX: hint color
          color: _hintColor(isDark),
          fontFamily: AppFont.fontFamily,
        ),
        // FIX: counter text color
        counterStyle: TextStyle(
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        filled: true,
        // FIX: fill color
        fillColor:
        isDark ? AppColor.primaryColor(context) : const Color(0xFFF0F0F0),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        // FIX: light mode mein subtle border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: isDark
              ? BorderSide.none
              : BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.buttonColor, width: 1.5),
        ),
      ),
    );
  }
}