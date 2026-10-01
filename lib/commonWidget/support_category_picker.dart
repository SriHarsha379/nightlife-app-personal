import 'package:flutter/material.dart';

import '../provider/common_api_helper.dart';
import '../utilities/app_color.dart';
import '../utilities/app_constant.dart';
import '../utilities/app_font.dart';

/// Category chips for support requests (Report a problem / Contact Us).
/// The list comes from the server (common/support_categories), so admins
/// can change it without an app update; a built-in list is used offline.
class SupportCategoryPicker extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const SupportCategoryPicker({super.key, required this.selected, required this.onChanged});

  @override
  State<SupportCategoryPicker> createState() => _SupportCategoryPickerState();
}

class _SupportCategoryPickerState extends State<SupportCategoryPicker> {
  static const _fallback = ['Reservations', 'Tickets', 'Account', 'Payments', 'Report a bug', 'Other'];
  List<String> _categories = _fallback;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await getFormData(
        'common/support_categories',
        null,
        headers: {'Authorization': 'Bearer ${AppConstant.token}'},
      );
      final data = res?['data'];
      if (data is List && data.isNotEmpty && mounted) {
        setState(() => _categories = data.map((e) => e.toString()).toList());
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _categories.map((c) {
        final active = c == widget.selected;
        return GestureDetector(
          onTap: () => widget.onChanged(c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColor.pinkColor : Colors.transparent,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: active ? AppColor.pinkColor : AppColor.appButtonColor),
            ),
            child: Text(
              c,
              style: TextStyle(
                fontFamily: AppFont.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppColor.secondryColor(context),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
