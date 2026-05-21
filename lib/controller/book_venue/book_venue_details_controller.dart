import 'package:flutter/material.dart';
import 'package:night_life/utilities/page_transition.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_config_provider.dart';
import '../../utilities/app_constant.dart';
import '../../utilities/app_footer.dart';
import '../../utilities/app_snack_bar_toast_message.dart';

class VenuesBookingDetailsController with ChangeNotifier {
  Map<String, dynamic>? _venuesDetail;
  Map<String, dynamic>? get getVenuesDetail => _venuesDetail;
  bool _isVenuesDetailLoading = false;
  bool get isVenuesDetailLoading => _isVenuesDetailLoading;

  bool _secondaryLoading = false;
  bool get secondaryLoading => _secondaryLoading;

  void setSecondaryLoading(bool value) {
    _secondaryLoading = value;
    notifyListeners();
  }

  // Fetch venue details from API
  Future<Map<String, dynamic>?> fetchVenuesBookingDetail(
    BuildContext context, {
    required String venueId,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty || venueId.isEmpty) {
      return null;
    }

    _isVenuesDetailLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'venue/booking_summary/$venueId',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          _venuesDetail = data;
          _isVenuesDetailLoading = false;
          notifyListeners();
          return _venuesDetail;
        }
        _venuesDetail = null;
        _isVenuesDetailLoading = false;
        notifyListeners();
      } else if (response != null) {
        // CommonHelper.handleInactiveUserRedirect(context, response);
        // _isVenuesDetailLoading = false;
        notifyListeners();
      }
    } catch (e) {
      print("Exception in fetchVenuesDetail: $e");
      _isVenuesDetailLoading = false;
      notifyListeners();
    }
    return null;
  }

  // Get image URL
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${AppConfigProvider.imageUrl}$imagePath';
  }

//=============== Rating venue Api=================//

  ratingApiCalling(
    BuildContext context,
    String bookingId,
    int rating,
    String review,
  ) async {
    setSecondaryLoading(true);

    final Map<String, String> fields = {
      'booking_id': bookingId.toString(),
      'rating': rating.toString(),
      'review': review.toString(),
    };

    print("Line 105 $fields");

    final res = await postJsonData(
      'rating/add',
      fields,
      context,
      headers: {
        'authorization': 'Bearer ${AppConstant.token}',
      },
    );

    if (res != null) {
      if (res['success'] == true && res['data'] != "NA") {
        setSecondaryLoading(false);
        TopNotification.success(
            context, "Your feedback submitted successfully");

        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeftWithFade,
            child: const MyAppFooter(initialIndex: 0),
            duration: const Duration(milliseconds: 400),
          ),
        );
      }
    }

    setSecondaryLoading(false);
  }

  // Clear all data (useful for logout)
  void clearData() {
    _venuesDetail = null;
    _isVenuesDetailLoading = false;
    notifyListeners();
  }
}
