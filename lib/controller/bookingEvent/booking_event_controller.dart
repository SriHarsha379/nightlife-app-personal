import 'dart:developer';

import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class BookingEventDetails extends ChangeNotifier {
  List<dynamic> _singleDayPassList = [];
  List<dynamic> get getSingleDayPassList => _singleDayPassList;

  List<dynamic> _multiDayPassList = [];
  List<dynamic> get getMultiDayPassList => _multiDayPassList;

  List<dynamic> _selectedList = [];
  List<dynamic> get getSelectedList => _selectedList;

  bool _isLoading = false;
  bool get getIsLoading => _isLoading;

  //! Pricing state
  double _gstAmount = 0;
  double get getGstAmount => _gstAmount;

  double _gstAddedPrice = 0;
  double get getGstAddedPrice => _gstAddedPrice;

  double _couponDiscountAmount = 0;
  double get getCouponDiscountAmount => _couponDiscountAmount;

  double _finalPrice = 0;
  double get getFinalPrice => _finalPrice;

  double _appliedCouponPercent = 0;
  double get getAppliedCouponPercent => _appliedCouponPercent;

  bool _isCouponApplied = false;
  bool get isCouponApplied => _isCouponApplied;

  //!================COUPON FIELDS==========================
  bool _isCouponSelected = false;
  bool get isCouponSelected => _isCouponSelected;

  String? _couponErrorMessage;
  String? get couponErrorMessage => _couponErrorMessage;

  bool _isCouponLoading = false;
  bool get isCouponLoading => _isCouponLoading;
  bool _isBookingLoading = false;
  bool get isBookingLoading => _isBookingLoading;

  String _appliedCouponCode = '';
  String get appliedCouponCode => _appliedCouponCode;

  //!==============TOTAL GUESTS COUNT===============
  num _totalGuest = 0;
  num get getTotalGuest => _totalGuest;

  Future<double?> fetchCouponDiscountPercentage(
    BuildContext context, {
    required String couponCode,
    String? eventId,
    String? vendoreId,
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
        'booking/get_coupon_percentage?coupon_code=$sanitizedCode&vendor_id=$vendoreId&event_id=$eventId',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final dynamic rawPercentage = data['discount_percentage'] ?? 0;
          double couponDiscountPercentage =
              double.tryParse(rawPercentage.toString()) ?? 0;
          _isCouponLoading = false;
          notifyListeners();
          return couponDiscountPercentage;
        }
      }
    } catch (_) {
      return null;
      // Keep previous values untouched if API throws.
    }
    _appliedCouponCode = '';
    _isCouponLoading = false;
    notifyListeners();
    return null;
  }

  void clearCoupon() {
    _appliedCouponCode = '';
    _isCouponLoading = false;
    notifyListeners();
  }

  //! Store selected tickets with their counts using ticket ID
  final Map<String, int> _selectedTicketsMap = {};
  Map<String, int> get getSelectedTicketsMap => _selectedTicketsMap;

  //! Map to store base prices
  final Map<String, double> _ticketBasePriceMap = {};
  Map<String, double> get getTicketBasePriceMap => _ticketBasePriceMap;

  //! Map to store title
  final Map<String, String> _ticketTitleMap = {};
  Map<String, String> get getTicketTitleMap => _ticketTitleMap;

  //! Map to store oneday/multiday
  final Map<String, int> _isOneDayTicketMap = {};
  Map<String, int> get getIsOneDayTicketMap => _isOneDayTicketMap;

  //! Get base price of a specific ticket
  double getTicketBasePrice(String ticketId) {
    return _ticketBasePriceMap[ticketId] ?? 0.0;
  }

  //! Get grand total of all selected tickets (base price only, before GST/coupon)
  double get getGrandTotal {
    return _selectedTicketsMap.entries.fold(0.0, (sum, entry) {
      double basePrice = _ticketBasePriceMap[entry.key] ?? 0.0;
      return sum + (basePrice * entry.value);
    });
  }

  //! Get selected tickets as list format with base price
  List<dynamic> get getSelectedTicketsList {
    return _selectedTicketsMap.entries
        .map((entry) => {
              "_id": entry.key,
              "count": entry.value,
              "base_price": _ticketBasePriceMap[entry.key] ?? 0.0,
              "total_price":
                  (_ticketBasePriceMap[entry.key] ?? 0.0) * entry.value,
              "title": _ticketTitleMap[entry.key],
              "isOneDay": _isOneDayTicketMap[entry.key],
            })
        .toList();
  }

  //! Get only one day pass tickets (isOneDay == 0)
  List<Map<String, dynamic>> get getSelectedOneDayTicketsList {
    return _selectedTicketsMap.entries
        .where((entry) => _isOneDayTicketMap[entry.key] == 0)
        .map((entry) => {
              "_id": entry.key,
              "count": entry.value,
              "base_price": _ticketBasePriceMap[entry.key] ?? 0.0,
              "total_price":
                  (_ticketBasePriceMap[entry.key] ?? 0.0) * entry.value,
              "title": _ticketTitleMap[entry.key],
              "isOneDay": 0,
            })
        .toList();
  }

  //! Get only multi day pass tickets (isOneDay == 1)
  List<Map<String, dynamic>> get getSelectedMultiDayTicketsList {
    return _selectedTicketsMap.entries
        .where((entry) => _isOneDayTicketMap[entry.key] == 1)
        .map((entry) => {
              "_id": entry.key,
              "count": entry.value,
              "base_price": _ticketBasePriceMap[entry.key] ?? 0.0,
              "total_price":
                  (_ticketBasePriceMap[entry.key] ?? 0.0) * entry.value,
              "title": _ticketTitleMap[entry.key],
              "isOneDay": 1,
            })
        .toList();
  }

  void selectPassList(int status) {
    if (status == 0) {
      _selectedList = List.from(_singleDayPassList);
    } else if (status == 1) {
      _selectedList = List.from(_multiDayPassList);
    }
    notifyListeners();
  }

  //! Add or update ticket selection
  void addTicket(
    String ticketId, {
    required double basePrice,
    required String ticketTitle,
    required int isOneDay,
  }) {
    if (_selectedTicketsMap.containsKey(ticketId)) {
      _selectedTicketsMap[ticketId] = _selectedTicketsMap[ticketId]! + 1;
    } else {
      _selectedTicketsMap[ticketId] = 1;
      _ticketBasePriceMap[ticketId] = basePrice;
      _ticketTitleMap[ticketId] = ticketTitle;
      _isOneDayTicketMap[ticketId] = isOneDay;
    }
    recalculatePricing();
    notifyListeners();
  }

  //! Remove or decrease ticket count
  void removeTicket(String ticketId) {
    if (_selectedTicketsMap.containsKey(ticketId)) {
      if (_selectedTicketsMap[ticketId]! > 1) {
        _selectedTicketsMap[ticketId] = _selectedTicketsMap[ticketId]! - 1;
      } else {
        _selectedTicketsMap.remove(ticketId);
        _ticketBasePriceMap.remove(ticketId);
        _ticketTitleMap.remove(ticketId);
        _isOneDayTicketMap.remove(ticketId);
      }
      recalculatePricing();
      notifyListeners();
    }
  }

  //! Increase ticket count with limit
  void increaseTicketCount(String ticketId, int availableTickets) {
    if (_selectedTicketsMap.containsKey(ticketId)) {
      int currentCount = _selectedTicketsMap[ticketId]!;
      if (currentCount < availableTickets) {
        _selectedTicketsMap[ticketId] = currentCount + 1;
        recalculatePricing();
        notifyListeners();
      }
    }
  }

  //! Calculate total guests
  void calculateTotalGuest() {
    _totalGuest = 0;
    if (getSelectedTicketsList.isEmpty) return;
    for (int i = 0; i < getSelectedTicketsList.length; i++) {
      _totalGuest += getSelectedTicketsList[i]['count'];
    }
  }

  //! Check if ticket is selected
  bool isTicketSelected(String ticketId) {
    return _selectedTicketsMap.containsKey(ticketId);
  }

  //! Get ticket count
  int getTicketCount(String ticketId) {
    return _selectedTicketsMap[ticketId] ?? 0;
  }

  //! Apply coupon by percentage
  //! Call this when user applies a coupon code
  void applyCoupon(double percent) {
    if (percent <= 0 || percent > 100) return;
    _appliedCouponPercent = percent;
    _isCouponApplied = true;
    recalculatePricing();
    log('afadfasdfadfasfaf');
    notifyListeners();
  }

  /// Central pricing calculator.
  /// Flow: grandTotal → +GST → -coupon discount → finalPrice
  ///
  /// grandTotal          = sum of (basePrice × count) for all tickets
  /// gstAmount           = 18% of grandTotal
  /// gstAddedPrice       = grandTotal + gstAmount
  /// couponDiscountAmount= appliedCouponPercent% of gstAddedPrice (0 if no coupon)
  /// finalPrice          = gstAddedPrice - couponDiscountAmount
  void recalculatePricing() {
    final double baseTotal = getGrandTotal;

    // GST: 18% of base total
    _gstAmount = ((18 / 100) * baseTotal).roundToDouble();

    // Price after adding GST
    _gstAddedPrice = (baseTotal + _gstAmount).roundToDouble();

    // Coupon discount applied on GST-inclusive price
    if (_isCouponApplied && _appliedCouponPercent > 0) {
      _couponDiscountAmount =
          ((_appliedCouponPercent / 100) * _gstAddedPrice).roundToDouble();
    } else {
      _couponDiscountAmount = 0;
    }

    // Final price after coupon deduction
    _finalPrice = (_gstAddedPrice - _couponDiscountAmount).roundToDouble();

    notifyListeners();
  }

  //! Clear all selections and reset pricing
  void clearSelections() {
    _selectedTicketsMap.clear();
    _ticketBasePriceMap.clear();
    _ticketTitleMap.clear();
    _isOneDayTicketMap.clear();
    _gstAmount = 0;
    _gstAddedPrice = 0;
    _couponDiscountAmount = 0;
    _finalPrice = 0;
    _appliedCouponPercent = 0;
    _isCouponApplied = false;
    _totalGuest = 0;
    notifyListeners();
  }

  //!========================COUPON METHODS=============================/// Toggle coupon checkbox visibility
  void toggleCouponCheckbox(bool value) {
    _isCouponSelected = value;
    _couponErrorMessage = null;
    notifyListeners();
  }

  /// Validates the coupon code and applies discount if valid
  /// Validates the coupon code and applies discount if valid
  Future<void> validateAndApplyCoupon(BuildContext context, String code,
      String vendorId, String eventId) async {
    if (code.isEmpty) {
      _couponErrorMessage = "Please enter a coupon code";
      notifyListeners();
      return;
    }

    // Fetch the discount percentage from API
    final double? percent = await fetchCouponDiscountPercentage(context,
        couponCode: code, vendoreId: vendorId, eventId: eventId);

    if (percent == null || percent <= 0) {
      // _couponErrorMessage = "";
      _isCouponApplied = false;
      _appliedCouponPercent = 0;
      _appliedCouponCode = '';
      recalculatePricing();
      notifyListeners();
      return;
    }

    // Valid coupon
    _couponErrorMessage = null;
    _isCouponApplied = true;
    _appliedCouponPercent = percent;
    _appliedCouponCode = code;
    recalculatePricing();
    notifyListeners();
  }

  /// Remove applied coupon and reset coupon state
  void removeCoupon() {
    _isCouponApplied = false;
    _isCouponSelected = false;
    _appliedCouponPercent = 0;
    _couponDiscountAmount = 0;
    _couponErrorMessage = null;
    recalculatePricing();
  }

  //! Fetch passes data from API
  Future<void> fetchPassesData(BuildContext context, String eventId) async {
    String token = AppConstant.token;
    if (token.isEmpty) {
      print("Token is missing!");
      return;
    }

    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    if (_singleDayPassList.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final response = await getFormData(
        'booking/get_event_tickets/$eventId',
        context,
        headers: headers,
      );

      print("API Response: $response");

      if (response != null && response['success'] == true) {
        if (response['data'] != null && response['data'].isNotEmpty) {
          _singleDayPassList = response['data']['one_day_pass'] ?? [];
          _selectedList = response['data']['one_day_pass'] ?? [];
          _multiDayPassList = response['data']['multi_day_pass'] ?? [];
        } else {
          _singleDayPassList = [];
          _multiDayPassList = [];
          print("No passes data found");
        }
        notifyListeners();
      } else {
        _singleDayPassList = [];
        _multiDayPassList = [];
        if (response != null) {
          // CommonHelper.handleInactiveUserRedirect(context, response);
        }
      }
    } catch (e) {
      print("Exception in fetchPassesData: $e");
      _singleDayPassList = [];
      _multiDayPassList = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
