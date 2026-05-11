import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controller/my_profile/get_my_profile.dart';
import '../../../controller/vibe_preference/vibe_prefernce_controller.dart';
import '../../../provider/darkmode_provider.dart';
import '../../../provider/post_api_provider.dart';
import '../../../utilities/app_button.dart';
import '../../../utilities/app_color.dart';
import '../../../utilities/app_constant.dart';
import '../../../utilities/app_font.dart';
import '../../../utilities/app_image.dart';
import '../../../utilities/app_language.dart';
import '../../../utilities/app_snack_bar_toast_message.dart';

class EditVibePreference extends StatefulWidget {
  static String routeName = './EditVibePreference';
  final Set<String> initialSelectedVibeIds;

  const EditVibePreference({
    super.key,
    Set<String>? initialSelectedVibeIds,
  }) : initialSelectedVibeIds = initialSelectedVibeIds ?? const {};

  @override
  State<EditVibePreference> createState() => _EditVibePreferenceState();
}

class _EditVibePreferenceState extends State<EditVibePreference> {
  bool _initialSelectionApplied = false;
  Set<String> _selectedVibeIds = {};

  String _vibeIdFrom(dynamic vibe) {
    if (vibe is Map) {
      return (vibe['_id'] ?? vibe['vibe_id'] ?? vibe['id'] ?? '').toString();
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller =
          Provider.of<VibePreferenceController>(context, listen: false);
      await controller.fetchVibesData(context);

      if (_initialSelectionApplied) return;

      final Set<String> initialIds =
          Set<String>.from(widget.initialSelectedVibeIds);
      final Set<String> normalizedSelectedIds = controller.getVibesList
          .map((vibe) {
            if (vibe is! Map) return '';
            final String normalizedId = _vibeIdFrom(vibe);
            final String vibeId = (vibe['vibe_id'] ?? '').toString();
            final String rawId = (vibe['_id'] ?? vibe['id'] ?? '').toString();
            if (normalizedId.isEmpty) return '';
            if (initialIds.contains(normalizedId) ||
                (vibeId.isNotEmpty && initialIds.contains(vibeId)) ||
                (rawId.isNotEmpty && initialIds.contains(rawId))) {
              return normalizedId;
            }
            return '';
          })
          .where((id) => id.isNotEmpty)
          .toSet();

      if (mounted) {
        setState(() {
          _selectedVibeIds = normalizedSelectedIds;
        });
      } else {
        _selectedVibeIds = normalizedSelectedIds;
      }
      _initialSelectionApplied = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
      ),
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Consumer<VibePreferenceController>(
          builder: (context, controller, child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: AppButton(
                text: AppLanguage.continueText[language],
                onPress: () async {
                  final List<String> selectedVibeIds =
                      _selectedVibeIds.toSet().toList();

                  if (selectedVibeIds.isEmpty) {
                    SnackBarToastMessage.info(
                        context, "Please select at least one vibe");
                    return;
                  }

                  final postProvider =
                      Provider.of<PostApiProvider>(context, listen: false);
                  final profileController =
                      Provider.of<ProfileController>(context, listen: false);
                  final isSuccess = await postProvider.addVibesApi(
                    context,
                    vibeIds: selectedVibeIds,
                  );

                  if (!isSuccess || !mounted) return;

                  await profileController.fetchProfileData(context);
                  if (!mounted) return;

                  Navigator.pop(context, {
                    'selectedVibes': selectedVibeIds.join(','),
                  });
                },
              ),
            );
          },
        ),
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              gradient: AppColor.backgroundGradientcolor(context)),
          child: Consumer<VibePreferenceController>(
            builder: (context, controller, child) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 3 / 100),
                    SizedBox(
                      width: size.width * 90 / 100,
                      height: size.height * 8 / 100,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: SizedBox(
                              width: size.width * 4 / 100,
                              child: SizedBox(
                                height: size.height * 5 / 100,
                                child: Image.asset(
                                  AppImage.backArrowIcon,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: size.width * 80 / 100,
                            child: Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                AppLanguage.vibePreferenceText[language],
                                style: TextStyle(
                                  fontFamily: AppFont.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColor.secondryColor(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: size.width * 92 / 100,
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          AppLanguage.whatKindofVibeText[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 1 / 100),
                    SizedBox(
                      width: size.width * 90 / 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLanguage.vibeTypetext[language],
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                          Text(
                            '${_selectedVibeIds.length}/${controller.maxSelection}',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColor.buttonColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 1 / 100),
                    SizedBox(
                      width: size.width * 90 / 100,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppLanguage.select1to5Text[language],
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColor.filledText(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 2 / 100),
                    if (controller.getIsLoading)
                      SizedBox(
                        height: size.height * 40 / 100,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.buttonColor,
                          ),
                        ),
                      )
                    else if (controller.getVibesList.isEmpty)
                      SizedBox(
                        height: size.height * 40 / 100,
                        child: Center(
                          child: Text(
                            'No vibes available',
                            style: TextStyle(
                              fontFamily: AppFont.fontFamily,
                              fontSize: 16,
                              color: AppColor.secondryColor(context),
                            ),
                          ),
                        ),
                      )
                    else
                      _buildVibesFromAPI(controller, size),
                    SizedBox(height: size.height * 20 / 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildVibesFromAPI(VibePreferenceController controller, Size size) {
    final apiVibes = controller.getVibesList;

    return Wrap(
      runSpacing: 12,
      spacing: size.width * 4 / 100,
      children: List.generate(
        apiVibes.length,
        (index) {
          final vibe = apiVibes[index];
          final String vibeId = _vibeIdFrom(vibe);
          final String vibeName =
              (vibe['vibe'] ?? vibe['name'] ?? 'Unknown').toString();
          final String vibeDescription =
              (vibe['description'] ?? vibe['subtitle'] ?? '').toString();
          final String imagePath = (vibe['image'] ?? '').toString();
          final bool isSelected = _selectedVibeIds.contains(vibeId);

          return GestureDetector(
            onTap: () {
              if (vibeId.isEmpty) return;
              if (!isSelected &&
                  _selectedVibeIds.length >= controller.maxSelection) {
                SnackBarToastMessage.info(context,
                    "Max ${controller.maxSelection} selections allowed");
                return;
              }

              setState(() {
                if (isSelected) {
                  _selectedVibeIds.remove(vibeId);
                } else {
                  _selectedVibeIds.add(vibeId);
                }
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.032,
                vertical: size.height * 0.012,
              ),
              width: size.width * 43 / 100,
              decoration: BoxDecoration(
                color: AppColor.filledcolor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? AppColor.buttonColor : AppColor.borderColor,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColor.buttonColor.withOpacity(0.35),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: size.width * 8 / 100,
                    height: size.width * 8 / 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.borderColor,
                        width: .5,
                      ),
                    ),
                    child: ClipOval(
                      child: imagePath.isNotEmpty
                          ? Image.network(
                              controller.getVibeImageUrl(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                  SizedBox(width: size.width * 2 / 100),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vibeName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 13.2,
                            fontWeight: FontWeight.w500,
                            color: AppColor.secondryColor(context),
                          ),
                        ),
                        SizedBox(height: size.height * 0.1 / 100),
                        Text(
                          vibeDescription,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppFont.fontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: AppColor.lightGreyColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColor.filledcolor(context),
      child: Center(
        child: Icon(
          Icons.music_note,
          size: 15,
          color: AppColor.secondryColor(context).withOpacity(0.3),
        ),
      ),
    );
  }
}
