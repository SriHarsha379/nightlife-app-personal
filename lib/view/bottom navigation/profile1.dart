import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:night_life/view/authentication/edit_Swipe_profile.dart';
import 'package:night_life/view/authentication/edit_profile_screen.dart';
import 'package:night_life/view/other/MySplashSection/EventSection/Liked/liked_event_details.dart';
import 'package:night_life/view/other/city_Preference/edit_vibes.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import '../../controller/my_profile/get_my_profile.dart';
import '../../provider/post_api_provider.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_font.dart';
import '../../utilities/app_image.dart';
import '../../utilities/app_language.dart';
import '../../utilities/media_picker_helper.dart';
import '../authentication/profile.dart';
import '../other/city_Preference/edit_event_prefrence.dart';
import '../../helper/ImagePreviewScreen.dart';

class Profile1 extends StatefulWidget {
  static String routeName = './Profile1';
  const Profile1({super.key});

  @override
  State<Profile1> createState() => _Profile1State();
}

class _Profile1State extends State<Profile1> {
  List<Map<String, String>> _selectedMediaList = [];
  final Set<String> _hiddenRemoteGalleryUrls = {};

  Future<bool> _confirmDeleteMedia() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Media'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _openMediaPicker() {
    if (_selectedMediaList.length >= MediaPickerHelper.maxMediaItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Maximum ${MediaPickerHelper.maxMediaItems} items can be selected"),
          backgroundColor: AppColor.pinkColor,
        ),
      );
      return;
    }

    MediaPickerHelper.showMediaPickerBottomSheet(
      context,
      currentMediaCount: _selectedMediaList.length,
      selectOptionText: AppLanguage.selectoptionText[language],
      galleryText: AppLanguage.gallerySelectText[language],
      cameraText: AppLanguage.cameraSelectText[language],
      videoText: AppLanguage.videoSelectText[language],
      cancelText: AppLanguage.cancelText[language],
      onImageFromCamera: (imageData) {
        final profileController =
            Provider.of<ProfileController>(context, listen: false);
        setState(() {
          _selectedMediaList.add(imageData);
        });
        profileController.uploadGallery(context, [imageData]).then((success) {
          if (!mounted) return;
          if (success) {
            setState(() {
              _selectedMediaList.remove(imageData);
            });
            return;
          }
          setState(() {
            _selectedMediaList.remove(imageData);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to upload media"),
              backgroundColor: AppColor.pinkColor,
            ),
          );
        });
      },
      onVideoFromCamera: (videoData) {
        final profileController =
            Provider.of<ProfileController>(context, listen: false);
        setState(() {
          _selectedMediaList.add(videoData);
        });
        profileController.uploadGallery(context, [videoData]).then((success) {
          if (!mounted) return;
          if (success) {
            setState(() {
              _selectedMediaList.remove(videoData);
            });
            return;
          }
          setState(() {
            _selectedMediaList.remove(videoData);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to upload media"),
              backgroundColor: AppColor.pinkColor,
            ),
          );
        });
      },
      onMediaFromGallery: (mediaList) {
        final profileController =
            Provider.of<ProfileController>(context, listen: false);
        int remainingSlots =
            MediaPickerHelper.maxMediaItems - _selectedMediaList.length;
        int itemsToAdd = mediaList.length > remainingSlots
            ? remainingSlots
            : mediaList.length;
        final toAdd = mediaList.take(itemsToAdd).toList();

        setState(() {
          _selectedMediaList.addAll(toAdd);
        });

        profileController.uploadGallery(context, toAdd).then((success) {
          if (!mounted) return;
          if (success) {
            setState(() {
              _selectedMediaList.removeWhere((item) => toAdd.contains(item));
            });
            return;
          }
          setState(() {
            _selectedMediaList.removeWhere((item) => toAdd.contains(item));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to upload media"),
              backgroundColor: AppColor.pinkColor,
            ),
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileController =
          Provider.of<ProfileController>(context, listen: false);
      profileController.fetchProfileData(context);
    });
  }

  int selectedId = 1;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final profileController = Provider.of<ProfileController>(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          setState(() {
            AppConstant.selectFooterIndex = 0;
          });
        },
        child: Scaffold(
          body: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(color: AppColor.primaryColor(context)),
            child: profileController.getIsLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColor.themeColor,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () =>
                        profileController.refreshProfileData(context),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.05,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: size.height * 0.04),

                            //! Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppLanguage.yourProfileText[language],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppFont.fontFamily,
                                    color: AppColor.secondryColor(context),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: const Profile(),
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  },
                                  child: Image.asset(
                                    AppImage.settingIcon,
                                    color: AppColor.secondryColor(context),
                                    width: size.width * 0.05,
                                    height: size.height * 0.06,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: size.height * 0.01),

                            //! Profile Section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Profile Image
                                Container(
                                  width: size.width * 0.35,
                                  height: size.height * 0.20,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                    child: profileController
                                                .getProfileImageUrl() !=
                                            null
                                        ? Image.network(
                                            profileController
                                                .getProfileImageUrl()!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                AppImage.placeHolder2Icon,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            AppImage.placeHolder2Icon,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),

                                // Profile Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: size.height * 0.03),
                                      Text(
                                        profileController.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: AppFont.fontFamily,
                                          color:
                                              AppColor.secondryColor(context),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: size.height * 0.002),
                                      profileController.hobbies.isNotEmpty
                                          ? Text(
                                              profileController
                                                  .getHobbiesDisplayText(),
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: AppFont.fontFamily,
                                                color: AppColor.buttonColor,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          : SizedBox(),
                                      SizedBox(height: size.height * 0.01),
                                      Row(
                                        children: [
                                          Text(
                                            '${profileController.totalFriends}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.005),
                                          Text(
                                            AppLanguage.friends[language],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.005),
                                      Row(
                                        children: [
                                          Text(
                                            '${profileController.totalLikes}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                          Text(
                                            AppLanguage.likes[language],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            //! Edit Buttons
                            SizedBox(height: size.height * 0.02),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          child: const EditProfile(),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: size.height * 0.05,
                                      decoration: BoxDecoration(
                                        color: AppColor.statusbar,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            AppImage.editIcon,
                                            height: 20,
                                            width: 20,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                          SizedBox(width: size.width * 0.01),
                                          Text(
                                            AppLanguage
                                                .editDetailsText[language],
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: AppFont.fontFamily,
                                              color: AppColor.secondryColor(
                                                  context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.03),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      final galleryItems = profileController
                                          .getGalleryItems()
                                          .map((item) => {
                                                'type':
                                                    item['type']?.toString() ??
                                                        'image',
                                                'url':
                                                    item['url']?.toString() ??
                                                        '',
                                                'thumbnail': item['thumbnail']
                                                        ?.toString() ??
                                                    '',
                                              })
                                          .toList();
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          child: EditSwipeProfile(
                                            galleryItems: galleryItems,
                                          ),
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: size.height * 0.05,
                                      decoration: BoxDecoration(
                                        color: AppColor.buttonColor,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                          color: AppColor.transparentColor,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          AppLanguage
                                              .editSwipeprofileText[language],
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppFont.fontFamily,
                                            color:
                                                AppColor.secondryColor(context),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            profileController.bio.isNotEmpty
                                ? SizedBox(height: size.height * 0.02)
                                : SizedBox(),
                            profileController.bio.isNotEmpty
                                ? Text(
                                    AppLanguage.basicdetailstext[language],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.secondryColor(context)),
                                  )
                                : SizedBox(),
                            profileController.bio.isNotEmpty
                                ? SizedBox(height: size.height * 0.01)
                                : SizedBox(),
                            profileController.bio.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(30),
                                      top: Radius.circular(30),
                                    ),
                                    child: Image.asset(
                                      AppImage.lineIcon,
                                      fit: BoxFit.cover,
                                      color: AppColor.secondryColor(context),
                                    ),
                                  )
                                : SizedBox(),
                            profileController.bio.isNotEmpty
                                ? SizedBox(height: size.height * 0.01)
                                : SizedBox(),

                            //! Bio Section
                            profileController.bio.isNotEmpty
                                ? Text(
                                    AppLanguage.bioText[language],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.secondryColor(context)),
                                  )
                                : SizedBox(),
                            profileController.bio.isNotEmpty
                                ? SizedBox(height: size.height * 0.01)
                                : SizedBox(),
                            Text(
                              profileController.bio.isNotEmpty
                                  ? profileController.bio
                                  : "",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.greyLightColor),
                            ),
                            profileController.bio.isNotEmpty
                                ? SizedBox(height: size.height * 0.01)
                                : SizedBox(),
                            profileController.bio.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(30),
                                      top: Radius.circular(30),
                                    ),
                                    child: Image.asset(
                                      AppImage.lineIcon,
                                      color: AppColor.secondryColor(context),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : SizedBox(),
                            profileController.bio.isNotEmpty
                                ? SizedBox(height: size.height * 0.02)
                                : SizedBox(),

                            //! Event Preferences Section
                            Text(
                              AppLanguage.eventPreferencetext[language],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.secondryColor(context)),
                            ),
                            SizedBox(height: size.height * 0.01),
                            _buildEventPreferences(context, profileController),
                            SizedBox(height: size.height * 0.02),
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(30),
                                top: Radius.circular(30),
                              ),
                              child: Image.asset(
                                AppImage.lineIcon,
                                fit: BoxFit.cover,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),

                            //! Vibes Section
                            Text(
                              AppLanguage.vibe[language],
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.secondryColor(context)),
                            ),
                            SizedBox(height: size.height * 0.01),
                            _buildVibesSection(context, profileController),
                            SizedBox(height: size.height * 0.01),
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(30),
                                top: Radius.circular(30),
                              ),
                              child: Image.asset(
                                AppImage.lineIcon,
                                fit: BoxFit.cover,
                                color: AppColor.secondryColor(context),
                              ),
                            ),
                            SizedBox(height: size.height * 0.02),

                            //! Gallery Section
                            Text(
                              AppLanguage.GalleryText[language],
                              style: TextStyle(
                                  fontSize: 18,
                                  fontFamily: AppFont.fontFamily,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.secondryColor(context)),
                            ),
                            SizedBox(height: size.height * 0.02),
                            _buildGallerySection(context, profileController),
                            SizedBox(height: size.height * 0.03),

                            //! Social Media Section (Instagram)
                            if (profileController.hasInstagram)
                              _buildInstagramSection(
                                  context, profileController),

                            SizedBox(height: size.height * 0.02),

                            //! Liked Events Section
                            if (profileController.hasLikedEvents) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLanguage.likedEvents[language],
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w600,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          child: const LikedEventDetail(),
                                          duration:
                                              const Duration(milliseconds: 400),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      AppLanguage.viewAlltext[language],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontFamily: AppFont.fontFamily,
                                          fontWeight: FontWeight.w500,
                                          color: AppColor.pinkColor),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.02),
                              _buildLikedEventsSection(
                                  context, profileController),
                              SizedBox(height: size.height * 0.03),
                            ],

                            //! Followed Venues Section
                            if (profileController.hasFollowedVenues) ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLanguage.followedVenuestext[language],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.secondryColor(context)),
                                  ),
                                  Text(
                                    AppLanguage.viewAlltext[language],
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: AppFont.fontFamily,
                                        fontWeight: FontWeight.w500,
                                        color: AppColor.pinkColor),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.002),
                              _buildFollowedVenuesSection(
                                  context, profileController),
                            ],

                            //! Top Artist Section
                            if (profileController.hasTopArtist) ...[
                              Text(
                                AppLanguage.mytopArtistonspotifyText[language],
                                style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: AppFont.fontFamily,
                                    fontWeight: FontWeight.w500,
                                    color: AppColor.secondryColor(context)),
                              ),
                              SizedBox(height: size.height * 0.02),
                              _buildTopArtistSection(
                                  context, profileController),
                            ],
                            SizedBox(height: size.height * 0.15),
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

  Widget _buildEventPreferences(
      BuildContext context, ProfileController controller) {
    final eventPreferences = controller.getEventPreferenceNames();
    final displayList = ['Add new', ...eventPreferences];
    final preSelectedEventIds = controller.eventPreferences
        .map((pref) {
          if (pref is Map) {
            final dynamic rawId = pref['event_id'] ?? pref['_id'] ?? pref['id'];
            return rawId?.toString() ?? '';
          }
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toSet();
    final String initialCustomEvent = controller.customEventPreferences
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .join(', ');

    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children: List.generate(
        displayList.length,
        (index) {
          bool isAddNew = index == 0;
          String title = displayList[index];
          bool isSelected = selectedId == index;

          return GestureDetector(
            onTap: isAddNew
                ? () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: EditEventPreference(
                          initialSelectedEventIds: preSelectedEventIds,
                          initialCustomEvent: initialCustomEvent,
                        ),
                        duration: const Duration(milliseconds: 400),
                      ),
                    );
                  }
                : () {
                    setState(() {
                      selectedId = index;
                    });
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.primaryColor(context),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isAddNew
                      ? AppColor.greyLightColor
                      : (isSelected
                          ? AppColor.buttonColor
                          : AppColor.buttonColor),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppFont.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isAddNew
                      ? Colors.grey
                      : (isSelected
                          ? AppColor.buttonColor
                          : AppColor.buttonColor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVibesSection(
      BuildContext context, ProfileController controller) {
    final vibeItems = controller.getVibesWithImages();
    final customVibes = controller.getCustomVibeNames();
    final preSelectedVibeIds = controller.vibes
        .map((vibe) {
          if (vibe is Map) {
            final dynamic rawId = vibe['vibe_id'] ?? vibe['_id'] ?? vibe['id'];
            return rawId?.toString() ?? '';
          }
          return '';
        })
        .where((id) => id.isNotEmpty)
        .toSet();

    final allItems = [
      ...vibeItems.map((vibe) => {
            'name': vibe['name']?.toString() ?? '',
            'image': vibe['image']?.toString() ?? '',
          }),
      ...customVibes.map((name) => {
            'name': name,
            'image': '',
          }),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: allItems.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.rightToLeftWithFade,
                        child: EditVibePreference(
                          initialSelectedVibeIds: preSelectedVibeIds,
                        ),
                        duration: const Duration(milliseconds: 400),
                      ),
                    );
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.themeColor,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 70,
                  child: Text(
                    'Add new',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w400,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                ),
              ],
            );
          }

          final item = allItems[index - 1];
          final name = item['name'] ?? '';
          final imageUrl = item['image'] ?? '';

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.themeColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.music_note,
                                size: 15,
                                color: AppColor.secondryColor(context)
                                    .withOpacity(0.3),
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.music_note,
                          size: 15,
                          color:
                              AppColor.secondryColor(context).withOpacity(0.3),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 70,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontFamily: AppFont.fontFamily,
                    fontWeight: FontWeight.w400,
                    color: AppColor.secondryColor(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGallerySection(
      BuildContext context, ProfileController controller) {
    final size = MediaQuery.of(context).size;
    final galleryItems = controller
        .getGalleryItems()
        .where((item) =>
            !_hiddenRemoteGalleryUrls.contains((item['url'] ?? '').toString()))
        .toList();
    final localItems = _selectedMediaList;
    final totalGalleryCount = localItems.length + galleryItems.length;
    final bool shouldShowAddTile =
        totalGalleryCount < MediaPickerHelper.maxMediaItems;

    final previewImages = <String>[
      ...localItems.map((item) {
        final isVideo = item['type'] == 'video';
        final thumb = item['thumbnail'] ?? '';
        return isVideo && thumb.isNotEmpty ? thumb : (item['file'] ?? '');
      }).where((path) => path.isNotEmpty),
      ...galleryItems.map((item) {
        final isVideo = item['type'] == 'video';
        final thumb = item['thumbnail'] ?? '';
        return isVideo && thumb.isNotEmpty ? thumb : (item['url'] ?? '');
      }).where((path) => path.isNotEmpty),
    ];
    final previewMedia = <Map<String, String>>[
      ...localItems.map((item) {
        final type = item['type'] ?? 'image';
        final file = item['file'] ?? '';
        final thumb = item['thumbnail'] ?? '';
        return {
          'type': type,
          'url': type == 'video' && thumb.isNotEmpty ? thumb : file,
          'thumbnail': thumb,
          'source': file,
        };
      }).where(
          (m) => (m['url'] ?? '').isNotEmpty || (m['source'] ?? '').isNotEmpty),
      ...galleryItems.map((item) {
        final type = item['type']?.toString() ?? 'image';
        final url = item['url']?.toString() ?? '';
        final thumb = item['thumbnail']?.toString() ?? '';
        return {
          'type': type,
          'url': type == 'video' && thumb.isNotEmpty ? thumb : url,
          'thumbnail': thumb,
          'source': url,
        };
      }).where(
          (m) => (m['url'] ?? '').isNotEmpty || (m['source'] ?? '').isNotEmpty),
    ];

    return SizedBox(
      height: size.height * 0.18,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          if (shouldShowAddTile)
            GestureDetector(
              onTap: _openMediaPicker,
              child: Container(
                width: size.width * 0.3,
                margin: const EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    AppImage.plusImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ...localItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isVideo = item['type'] == 'video';
            final thumb = item['thumbnail'] ?? '';
            final displayPath =
                isVideo && thumb.isNotEmpty ? thumb : (item['file'] ?? '');
            final hasFile =
                displayPath.isNotEmpty && File(displayPath).existsSync();

            return GestureDetector(
              onTap: () {
                if (previewMedia.isEmpty) return;
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ImagePreviewScreen(
                      images: previewImages,
                      media: previewMedia,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: Container(
                width: size.width * 0.3,
                margin: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: hasFile
                          ? Image.file(
                              File(displayPath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : Image.asset(
                              AppImage.dogImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (isVideo)
                      const Positioned.fill(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    Positioned(
                      right: 8,
                      top: 4,
                      child: GestureDetector(
                        onTap: () async {
                          final shouldDelete = await _confirmDeleteMedia();
                          if (!shouldDelete || !mounted) return;
                          setState(() {
                            if (index >= 0 &&
                                index < _selectedMediaList.length) {
                              _selectedMediaList.removeAt(index);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          ...galleryItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isVideo = item['type'] == 'video';
            final displayUrl = isVideo && item['thumbnail'] != null
                ? item['thumbnail']
                : item['url'];
            final sourceUrl = (item['url'] ?? '').toString();
            final previewIndex = localItems.length + index;
            final apiUrl = sourceUrl.startsWith(AppConfigProvider.imageUrl)
                ? sourceUrl.replaceFirst(AppConfigProvider.imageUrl, '')
                : sourceUrl;

            return GestureDetector(
              onTap: () {
                if (previewMedia.isEmpty) return;
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: ImagePreviewScreen(
                      images: previewImages,
                      media: previewMedia,
                      initialIndex: previewIndex,
                    ),
                  ),
                );
              },
              child: Container(
                width: size.width * 0.3,
                margin: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: displayUrl != null && displayUrl.isNotEmpty
                          ? Image.network(
                              displayUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  AppImage.dogImage,
                                  fit: BoxFit.cover,
                                );
                              },
                            )
                          : Image.asset(
                              AppImage.dogImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                    if (isVideo)
                      const Positioned.fill(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    Positioned(
                      right: 8,
                      top: 4,
                      child: GestureDetector(
                        onTap: () async {
                          if (apiUrl.isEmpty) return;
                          final shouldDelete = await _confirmDeleteMedia();
                          if (!shouldDelete || !mounted) return;
                          final res = await Provider.of<PostApiProvider>(
                                  context,
                                  listen: false)
                              .deleteGalleryItemApi(context, apiUrl);
                          if (!mounted) return;
                          if (res != null && res['success'] == true) {
                            setState(() {
                              _hiddenRemoteGalleryUrls.add(sourceUrl);
                            });
                            await controller.refreshProfileData(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInstagramSection(
      BuildContext context, ProfileController controller) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.07,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.capsuleColor(context),
        boxShadow: [
          BoxShadow(
            color: AppColor.grayColor.withOpacity(0.4),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(200),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: Row(
          children: [
            Image.asset(
              AppImage.instagramIcon,
              color: AppColor.secondryColor(context),
              width: size.width * 0.05,
              height: size.height * 0.06,
            ),
            SizedBox(width: size.width * 0.02),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLanguage.instagramText[language],
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w500,
                      color: AppColor.secondryColor(context),
                    ),
                  ),
                  Text(
                    controller.instagram,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: AppFont.fontFamily,
                      fontWeight: FontWeight.w500,
                      color: AppColor.buttonColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColor.buttonColor,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: AppColor.transparentColor),
              ),
              child: Text(
                AppLanguage.connectedText[language],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFont.fontFamily,
                  color: AppColor.secondryColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedEventsSection(
      BuildContext context, ProfileController controller) {
    final size = MediaQuery.of(context).size;

    if (!controller.hasLikedEvents) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: size.height * 0.28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: controller.likedEvents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final event = controller.likedEvents[index];
          final eventImage = event['event_image'] ?? event['image'] ?? '';
          final imageUrl = eventImage.isNotEmpty
              ? '${AppConfigProvider.imageUrl}$eventImage'
              : '';
          final eventName =
              event['name'] ?? event['event_name'] ?? event['title'] ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeftWithFade,
                  child: const LikedEventDetail(),
                  duration: const Duration(milliseconds: 400),
                ),
              );
            },
            child: SizedBox(
              width: size.width * 0.4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  AppImage.aroundmeIcon,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              },
                            )
                          : Image.asset(
                              AppImage.aroundmeIcon,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    eventName.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFont.fontFamily,
                      color: AppColor.secondryColor(context),
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

  Widget _buildFollowedVenuesSection(
      BuildContext context, ProfileController controller) {
    final size = MediaQuery.of(context).size;

    if (!controller.hasFollowedVenues) {
      return const SizedBox.shrink();
    }

    final firstVenue = controller.followedVenues.first;
    final venueImage = firstVenue['venue_image'] ?? firstVenue['image'] ?? '';
    final imageUrl =
        venueImage.isNotEmpty ? '${AppConfigProvider.imageUrl}$venueImage' : '';

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.17,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    AppImage.followedVenueIcon,
                    fit: BoxFit.cover,
                  );
                },
              )
            : Image.asset(
                AppImage.followedVenueIcon,
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  Widget _buildTopArtistSection(
      BuildContext context, ProfileController controller) {
    final size = MediaQuery.of(context).size;

    final topArtist = controller.topArtist;

    if (topArtist == null || topArtist.isEmpty) {
      return const SizedBox.shrink();
    }

    final artistName = topArtist['name'] ?? '';

    if (artistName.isEmpty || artistName == 'Unknown Artist') {
      return const SizedBox.shrink();
    }

    final artists = [
      {'name': artistName},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: artists.map((artist) {
        return _buildArtistChip(
          context,
          artist['name'] ?? 'Unknown',
        );
      }).toList(),
    );
  }

  Widget _buildArtistChip(
    BuildContext context,
    String artistName,
  ) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: 40,
      padding: const EdgeInsets.only(left: 2, right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D3D),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFF1CC0),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          // Artist Name
          Text(
            artistName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: AppFont.fontFamily,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
