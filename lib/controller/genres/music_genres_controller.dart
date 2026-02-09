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
    // String token = AppConstant.token;
    String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5NzQ2NDhjNzUzMDc2MDY5MDg0ZmIzNCIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTc2OTIzNjUzOSwiZXhwIjoxNzcxODI4NTM5fQ.AC6BJrsvAvqoAFhwWWDR8AuKkaVr5k4ShjdNlFWDw2A";
    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    // Show loading only if list is empty
    if (_genresList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'auth/music-genres',
        context,
        headers: headers,
      );

      print("API Response: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'] is List) {
          _genresList = response['data'];
          print("Genres List: $_genresList");
        } else {
          _genresList = [];
          print("No genres data found");
        }
        notifyListeners();
      } else {
        _genresList = [];
        if (response != null) {
          CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchGenresData: $e");
      _genresList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
