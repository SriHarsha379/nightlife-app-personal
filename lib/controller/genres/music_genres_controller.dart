import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';

class MusicGenresController with ChangeNotifier {
  List<dynamic> _genresList = [];
  List<dynamic> get getGenresList => _genresList;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  // Store selected genre IDs
  List<String> _selectedGenreIds = [];
  List<String> get getSelectedGenreIds => _selectedGenreIds;

  int maxSelection = 5;

  // Fetch genres from API
  Future<void> fetchGenresData(BuildContext context) async {
    String token = AppConstant.token;

    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    if (_genresList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      print("======================================");
      print("CALLING API: auth/music-genres");
      print("======================================");

      final response = await getFormData(
        'auth/music-genres',
        context,
        headers: headers,
      );

      print("======================================");
      print("FULL API RESPONSE");
      print(response);
      print("======================================");

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'] is List) {
          final rawGenres = List<dynamic>.from(response['data']);
          _genresList = rawGenres.where(_isMusicGenreRecord).toList();

          print("======================================");
          print("TOTAL GENRES RECEIVED: ${_genresList.length}");
          print("DROPPED NON-GENRE RECORDS: "
              "${rawGenres.length - _genresList.length}");
          print("======================================");

          for (int i = 0; i < _genresList.length; i++) {
            final genre = _genresList[i];

            print(
              "[$i] "
              "ID: ${genre['_id']} | "
              "NAME: ${genre['genre_name'] ?? genre['name']} | "
              "CATEGORY: ${genre['category']}",
            );
          }

          print("======================================");
          print("END OF GENRE LIST");
          print("======================================");
        } else {
          _genresList = [];
          print("No genres data found");
        }

        notifyListeners();
      } else {
        _genresList = [];

        print("======================================");
        print("API FAILED OR RETURNED FALSE");
        print(response);
        print("======================================");

        if (response != null) {
          // CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e, stackTrace) {
      print("======================================");
      print("EXCEPTION IN fetchGenresData");
      print(e);
      print(stackTrace);
      print("======================================");

      _genresList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isMusicGenreRecord(dynamic item) {
    if (item is! Map) return false;

    final genreName =
        (item['genre_name'] ?? item['name'] ?? '').toString().trim();
    if (genreName.isEmpty) return false;
    if (_looksLikeEventPreference(genreName)) return false;

    final category = item['category']?.toString().trim().toLowerCase() ?? '';
    return !_isBlockedEventCategory(category);
  }

  bool _isBlockedEventCategory(String category) {
    const blockedCategories = {
      'dance',
      'comedy',
      'theater',
      'theatre',
      'concert',
    };
    return blockedCategories.contains(category);
  }

  bool _looksLikeEventPreference(String value) {
    final normalized = value.toLowerCase();
    const blockedTokens = [
      'festival',
      'event',
      'concert',
      'battle',
      'drama',
      'theater',
      'theatre',
      'comedy',
      'adventure',
      'special',
    ];
    return blockedTokens.any(normalized.contains);
  }

  // Toggle genre selection
  void toggleGenreSelection(String genreId) {
    if (_selectedGenreIds.contains(genreId)) {
      _selectedGenreIds.remove(genreId);
    } else {
      if (_selectedGenreIds.length < maxSelection) {
        _selectedGenreIds.add(genreId);
      }
    }
    notifyListeners();
  }

  bool isGenreSelected(String genreId) {
    return _selectedGenreIds.contains(genreId);
  }

  int get selectedCount => _selectedGenreIds.length;

  String getSelectedGenresString() {
    return _selectedGenreIds.join(',');
  }

  // Get genre image URL
  String getGenreImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${AppConfigProvider.imageUrl}$imagePath';
  }

  void clearSelections() {
    _selectedGenreIds.clear();
    notifyListeners();
  }

  void clearData() {
    _genresList = [];
    _selectedGenreIds = [];
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedGenres(List<String> genreIds) {
    _selectedGenreIds = genreIds;
    notifyListeners();
  }
}
