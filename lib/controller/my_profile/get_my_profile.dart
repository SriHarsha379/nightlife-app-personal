import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:mime/mime.dart';
import 'package:night_life/utilities/app_config_provider.dart';
import 'package:night_life/utilities/url_utils.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class ProfileController with ChangeNotifier {
  // Profile Data
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get getProfileData => _profileData;

  // Loading state
  bool _isLoading = false;
  bool get getIsLoading => _isLoading;
  bool _isUploading = false;
  bool get isUploading => _isUploading;

  // Individual getters for easy access
  String get userId => _profileData?['user_id'] ?? '';
  String get name => _profileData?['name'] ?? 'User';
  String? get profileImage => _profileData?['profile_image'];
  String get bio => _profileData?['bio'] ?? '';
  String get interestedIn => _profileData?['interested_in'] ?? '';
  bool get hasInterestedIn => interestedIn.trim().isNotEmpty;
  List<dynamic> get hobbies => _profileData?['hobbies'] ?? [];
  List<dynamic> get interests => _profileData?['interests'] ?? [];
  List<dynamic> get eventPreferences =>
      _profileData?['event_preferences'] ?? [];
  List<dynamic> get customEventPreferences =>
      _profileData?['custom_event_preferences'] ?? [];
  List<dynamic> get vibes => _profileData?['vibes'] ?? [];
  List<dynamic> get customVibes => _profileData?['custom_vibes'] ?? [];
  List<dynamic> get userGallery => _profileData?['user_gallery'] ?? [];
  String get instagram => _profileData?['instagram'] ?? '';
  String get spotify => _profileData?['spotify'] ?? '';
  String get snapchat => _profileData?['snapchat'] ?? '';
  List<dynamic> get likedEvents => _profileData?['liked_events'] ?? [];
  List<dynamic> get followedVenues => _profileData?['followed_venues'] ?? [];
  Map<String, dynamic>? get topArtist => _profileData?['top_artist'];
  int get totalLikes => _profileData?['total_likes'] ?? 0;
  int get totalFriends => _profileData?['total_friends'] ?? 0;

  // Check if profile has data
  bool get hasProfileData => _profileData != null;

  // Fetch profile data from API
  Future<void> fetchProfileData(BuildContext context) async {
    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    // Show loading only if profile data is not loaded
    if (_profileData == null) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'user/my_profile_data',
        context,
        headers: headers,
      );

      print("Profile API Response: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null) {
          _profileData = response['data'];
          print("Profile Data loaded successfully");
        } else {
          _profileData = null;
          print("No profile data found");
        }
        notifyListeners();
      } else {
        _profileData = null;
        if (response != null) {
          // CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchProfileData: $e");
      _profileData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh profile data
  Future<void> refreshProfileData(BuildContext context) async {
    await fetchProfileData(context);
  }

  // Get profile image URL
  String? getProfileImageUrl() {
    if (profileImage != null && profileImage!.isNotEmpty) {
      return resolveImageUrl(profileImage, AppConfigProvider.imageUrl);
    }
    return null;
  }

  // Get gallery item URL
  String getGalleryItemUrl(String url) {
    if (url.isNotEmpty) {
      return resolveImageUrl(url, AppConfigProvider.imageUrl);
    }
    return '';
  }

  // Get top artist image URL
  String? getTopArtistImageUrl() {
    if (topArtist != null && topArtist!['image'] != null) {
      String image = topArtist!['image'];
      if (image != 'default-artist.jpg') {
        return resolveImageUrl(image, AppConfigProvider.imageUrl);
      }
    }
    return null;
  }

  // Get event preferences as list of strings
  List<String> getEventPreferenceNames() {
    final prefNames = eventPreferences
        .map((pref) => pref['category_name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    final customNames = customEventPreferences
        .map((pref) => pref.toString())
        .where((name) => name.isNotEmpty)
        .toList();
    return [...prefNames, ...customNames];
  }

  // Get custom vibes.
  // Curated Vibe collection removed - these are now already plain
  // free-text strings coming straight from the backend, not {name,
  // image} objects, so this just normalizes to String.
  List<String> getCustomVibeNames() {
    return customVibes
        .map((vibe) => vibe.toString())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  // Get gallery items with type
  List<Map<String, dynamic>> getGalleryItems() {
    return userGallery.map((item) {
      return {
        'type': item['type'] ?? 'image',
        'url': getGalleryItemUrl(item['url'] ?? ''),
        'thumbnail': item['thumbnail'] != null
            ? getGalleryItemUrl(item['thumbnail'])
            : null,
      };
    }).toList();
  }

  // Check if user has Instagram connected
  bool get hasInstagram => instagram.isNotEmpty;

  // Check if user has Spotify connected
  bool get hasSpotify => spotify.isNotEmpty;

  // Check if user has Snapchat connected
  bool get hasSnapchat => snapchat.isNotEmpty;

  // Check if user has liked events
  bool get hasLikedEvents => likedEvents.isNotEmpty;

  // Check if user has followed venues
  bool get hasFollowedVenues => followedVenues.isNotEmpty;

  // Check if user has top artist
  bool get hasTopArtist => topArtist != null;

  // Get display name for vibes section.
  // Curated Vibe collection removed - `vibes` and `customVibes` are now
  // both just plain free-text strings (and in fact carry the same
  // content from the backend), so this dedupes them and reads directly
  // rather than treating entries as {name, image} objects.
  String getVibesDisplayText() {
    final Set<String> allVibes = {
      ...vibes.map((v) => v.toString()),
      ...customVibes.map((v) => v.toString()),
    }..removeWhere((name) => name.isEmpty);

    if (allVibes.isEmpty) return 'Add your vibes';

    return allVibes.take(3).join(' · ');
  }

  // Get display text for hobbies section
  String getHobbiesDisplayText() {
    if (hobbies.isEmpty) return 'Add your hobbies';

    final hobbyNames = hobbies
        .map((hobby) => hobby.toString())
        .where((name) => name.isNotEmpty)
        .take(6)
        .toList();

    return hobbyNames.join(' · ');
  }

  Future<bool> uploadGallery(
      BuildContext context, List<Map<String, String>> mediaList) async {
    if (mediaList.isEmpty) return false;
    String token = AppConstant.token;
    if (token.isEmpty) {
      print("Token is missing!");
      return false;
    }

    _isUploading = true;
    notifyListeners();

    try {
      final uri = Uri.parse("${AppConfigProvider.apiUrl}user/upload_gallery");
      final request = http.MultipartRequest('POST', uri);
      request.headers['authorization'] = 'Bearer $token';

      for (final media in mediaList) {
        final type = media['type'] ?? 'image';
        final filePath = media['file'] ?? '';
        if (filePath.isEmpty) continue;

        final mimeType = lookupMimeType(filePath) ??
            (type == 'video' ? 'video/mp4' : 'image/jpeg');
        final contentType = http_parser.MediaType.parse(mimeType);

        if (type == 'video') {
          request.files.add(
            await http.MultipartFile.fromPath(
              'videos',
              filePath,
              contentType: contentType,
            ),
          );

          final thumbnailPath = media['thumbnail'] ?? '';
          if (thumbnailPath.isNotEmpty) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'thumbnails',
                thumbnailPath,
                contentType: http_parser.MediaType.parse('image/jpeg'),
              ),
            );
          }
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              filePath,
              contentType: contentType,
            ),
          );
        }
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        await fetchProfileData(context);
        return true;
      }

      print("Upload gallery failed: ${response.body}");
      return false;
    } catch (e) {
      print("Upload gallery error: $e");
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Update profile locally (after edit)
  void updateProfileLocally(Map<String, dynamic> updatedData) {
    if (_profileData != null) {
      _profileData = {..._profileData!, ...updatedData};
      notifyListeners();
    }
  }

  // Clear profile data (useful for logout)
  void clearProfileData() {
    _profileData = null;
    _isLoading = false;
    notifyListeners();
  }

  // Get event preference by ID
  Map<String, dynamic>? getEventPreferenceById(String id) {
    try {
      return eventPreferences.firstWhere((pref) => pref['_id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get vibe by ID
  Map<String, dynamic>? getVibeById(String id) {
    try {
      return vibes.firstWhere((vibe) => vibe['vibe_id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Check if profile is complete
  bool get isProfileComplete {
    return profileImage != null &&
        bio.isNotEmpty &&
        eventPreferences.isNotEmpty &&
        vibes.isNotEmpty;
  }

  // Get profile completion percentage
  int get profileCompletionPercentage {
    int total = 7; // Total fields to complete
    int completed = 0;

    if (profileImage != null) completed++;
    if (bio.isNotEmpty) completed++;
    if (eventPreferences.isNotEmpty) completed++;
    if (vibes.isNotEmpty) completed++;
    if (userGallery.isNotEmpty) completed++;
    if (hasInstagram || hasSpotify || hasSnapchat) completed++;
    if (interests.isNotEmpty || hobbies.isNotEmpty) completed++;

    return ((completed / total) * 100).round();
  }
}