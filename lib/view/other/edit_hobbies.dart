// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/utilities/app_footer.dart';
import 'package:night_life/utilities/app_snack_bar_toast_message.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
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

    // Check if hobby name already exists
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
      _nextId++; // Increment for next hobby
      _updateHobbiesDisplay();
    });
    hobbyInputController.clear();
  }

  void _editHobby(int id, String newHobby) {
    if (newHobby.trim().isEmpty) {
      SnackBarToastMessage.error(context, "Please enter a hobby");
      return;
    }

    // Check if the new hobby name already exists (excluding current hobby)
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
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
                          // Header
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
                                    color: AppColor.secondryColor(context),
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
                                      color: AppColor.secondryColor(context),
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

                          // Hobbies Input Field
                          TextFormField(
                            style: TextStyle(
                                color: AppColor.secondryColor(context)),
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
                                    color: AppColor.greyLightColor,
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
                                borderSide: const BorderSide(
                                    color: AppColor.buttonColor, width: 0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                    color: AppColor.buttonColor, width: 1.5),
                              ),
                              fillColor: _isHobbiesFocusNode
                                  ? AppColor.primaryColor(context)
                                  : AppColor.themeColor,
                              filled: true,
                              counterText: '',
                              hintText: AppLanguage.yourHobbiesText[language],
                              hintStyle: AppConstant.textFilledStyle(context),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            onTap: () => _showAddHobbyBottomSheet(),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.02),

                          // Hobbies List
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
                                    color: AppColor.primaryColor(context),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // ID Badge (Optional - can be removed if not needed in UI)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColor.themeColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          '#$id',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: AppFont.fontFamily,
                                            color:
                                                AppColor.secondryColor(context),
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
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _showEditHobbyBottomSheet(
                                            id, hobbyName),
                                        child: Icon(
                                          Icons.edit_outlined,
                                          color:
                                              AppColor.secondryColor(context),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () =>
                                            _showDeleteConfirmationDialog(
                                                id, hobbyName),
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

                // Continue Button
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
                            child: const MyAppFooter(
                              initialIndex: 4,
                            ),
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

  // Add Hobby Bottom Sheet
  void _showAddHobbyBottomSheet() {
    hobbyInputController.clear();
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
            decoration: const BoxDecoration(
              color: AppColor.themeColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add a hobby",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFont.fontFamily,
                    color: AppColor.secondryColor(context),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hint: "Type here...",
                  controller: hobbyInputController,
                  inputFormatters: AppConstant.alphabetFormatter,
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
                            color: AppColor.primaryColor(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Cancel",
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _addHobby(hobbyInputController.text);
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
                            "Add",
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

  // Edit Hobby Bottom Sheet
  void _showEditHobbyBottomSheet(int id, String currentHobby) {
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
            decoration: const BoxDecoration(
              color: AppColor.themeColor,
              borderRadius: BorderRadius.only(
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
                        color: AppColor.secondryColor(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ID: $id',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFont.fontFamily,
                          color: AppColor.secondryColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hint: "Type here...",
                  controller: hobbyInputController,
                  inputFormatters: AppConstant.alphabetFormatter,
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
                            color: AppColor.primaryColor(context),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Cancel",
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

  // Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(int id, String hobbyName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.themeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Delete Hobby",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFont.fontFamily,
              color: AppColor.secondryColor(context),
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
                  color: AppColor.secondryColor(context),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor(context),
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
                        color: AppColor.themeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$id',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          fontFamily: AppFont.fontFamily,
                          color: AppColor.secondryColor(context),
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
                          color: AppColor.secondryColor(context),
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
                  color: AppColor.secondryColor(context),
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

  // Build TextField Widget
  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      style: TextStyle(
        color: AppColor.secondryColor(context),
        fontFamily: AppFont.fontFamily,
      ),
      controller: controller,
      inputFormatters: inputFormatters,
      maxLength: 30,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppColor.primaryColor(context),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
