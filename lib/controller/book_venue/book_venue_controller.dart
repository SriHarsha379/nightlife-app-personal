import 'dart:developer';

import 'package:flutter/material.dart';

import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class BookVenueController with ChangeNotifier {
  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;
  bool _isBookingLoading = false;
  bool get isBookingLoading => _isBookingLoading;

  double _couponDiscountPercentage = 0;
  double get couponDiscountPercentage => _couponDiscountPercentage;

  String _appliedCouponCode = '';
  String get appliedCouponCode => _appliedCouponCode;

  Future<double?> fetchCouponDiscountPercentage(
    BuildContext context, {
    required String couponCode,
    required String venueId,
    required String vendoreId,
  }) async {
    final token = AppConstant.token;
    final sanitizedCode = couponCode.trim();
    if (token.isEmpty || sanitizedCode.isEmpty) {
      return null;
    }

    _isCouponLoading = true;
    notifyListeners();

    try {
      final response = await getData(
        'booking/get_coupon_percentage?coupon_code=$sanitizedCode&vendor_id=$vendoreId&venue_id=$venueId',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final dynamic rawPercentage = data['discount_percentage'] ?? 0;
          _couponDiscountPercentage =
              double.tryParse(rawPercentage.toString()) ?? 0;
          _appliedCouponCode =
              (data['coupon_code'] ?? sanitizedCode).toString();
          _isCouponLoading = false;
          notifyListeners();
          return _couponDiscountPercentage;
        }
      }
    } catch (_) {
      // Keep previous values untouched if API throws.
    }

    _couponDiscountPercentage = 0;
    _appliedCouponCode = '';
    _isCouponLoading = false;
    notifyListeners();
    return null;
  }

  void clearCoupon() {
    _couponDiscountPercentage = 0;
    _appliedCouponCode = '';
    _isCouponLoading = false;
    notifyListeners();
  }

//==============book venue api-------------//

  Future<Map<String, dynamic>?> bookingVenueApi(
    BuildContext context, {
    required String venueId,
    required String date,
    required String slot,
    required int numberOfGuests,
    required bool isCover,
    required String specialRequest,
    required String transactionId,
    required num coverCharge,
    required num coverChargePercentage,
    required num discount,
    required num subTotal,
    required num total,
    required String cityName,
    required String countryCode,
    required String phoneNumber,
    required String email,
    required String fullName,
    required num gstPercent,
    required num gstAmount,
    required num couponDiscountPercent,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return null;

    _isBookingLoading = true;
    notifyListeners();

    final Map<String, dynamic> fields = {
      "venue_id": venueId.trim(),
      "date": date.trim(),
      "slot": slot.trim(),
      "number_of_guests": numberOfGuests,
      "is_cover": isCover,
      "special_request": specialRequest.trim(),
      "transaction_id": transactionId.trim(),
      "cover_charge": coverCharge,
      "cover_charge_percentage": coverChargePercentage,
      "discount": discount,
      "sub_total": subTotal,
      "total": total,
      "city_name": cityName.trim(),
      "country_code": countryCode.trim(),
      "phone_number": phoneNumber.trim(),
      "email": email.trim(),
      "full_name": fullName.trim(),
      "gst_amount": gstAmount,
      "gst_percentage": gstPercent,
      "discount_percent": couponDiscountPercentage,
    };
    log("booking field data $fields");
    try {
      final response = await postJsonData(
        'booking/venue_booking',
        fields,
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );
      log("bookingVenueApi fields: $fields");
      return response;
    } catch (_) {
      return null;
    } finally {
      _isBookingLoading = false;
      notifyListeners();
    }
  }
}
