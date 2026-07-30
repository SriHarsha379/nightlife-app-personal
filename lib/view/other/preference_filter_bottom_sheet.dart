// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/genres/music_genres_controller.dart';
import '../../controller/event_preference/event_preference_controller.dart';
import '../../utilities/app_color.dart';
import '../../utilities/app_font.dart';

// The curated Vibe collection (a fixed picker list like "Chill pill",
// "High Energy") has been removed entirely, and this filter sheet had no
// backend support for filtering the feed by vibes in the first place (no
// consumer ever called this widget either) - so the Vibes tab is gone
// rather than rebuilt, leaving Music/Events as the two filter categories.
class PreferenceFilterResult {
  final List<String> selectedMusicGenreIds;
  final List<String> selectedEventPreferenceIds;

  const PreferenceFilterResult({
    required this.selectedMusicGenreIds,
    required this.selectedEventPreferenceIds,
  });

  bool get isEmpty =>
      selectedMusicGenreIds.isEmpty && selectedEventPreferenceIds.isEmpty;
}

class PreferenceFilterBottomSheet extends StatefulWidget {
  final List<String> initialMusicGenreIds;
  final List<String> initialEventPreferenceIds;

  const PreferenceFilterBottomSheet({
    super.key,
    this.initialMusicGenreIds = const [],
    this.initialEventPreferenceIds = const [],
  });

  @override
  State<PreferenceFilterBottomSheet> createState() =>
      _PreferenceFilterBottomSheetState();
}

class _PreferenceFilterBottomSheetState
    extends State<PreferenceFilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<String> _selectedMusicIds = [];
  List<String> _selectedEventIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedMusicIds = List.from(widget.initialMusicGenreIds);
    _selectedEventIds = List.from(widget.initialEventPreferenceIds);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicGenresController>().fetchGenresData(context);
      context.read<EventPreferenceController>().fetchEventsData(context);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _totalSelected => _selectedMusicIds.length + _selectedEventIds.length;

  void _toggleItem(List<String> list, String id) {
    setState(() {
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedMusicIds.clear();
      _selectedEventIds.clear();
    });
  }

  String _itemName(dynamic item) {
    return (item['genre_name'] ?? item['category_name'] ?? item['name'] ?? '').toString();
  }

  String _itemId(dynamic item) {
    return (item['_id'] ?? item['id'] ?? '').toString();
  }

  Widget _buildChipGrid(List<dynamic> items, List<String> selected, bool isLoading) {
    if (isLoading) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColor.buttonColor)));
    }
    if (items.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('No options available', style: TextStyle(color: Colors.white54, fontFamily: AppFont.fontFamily, fontSize: 14))));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((item) {
          final id = _itemId(item);
          final name = _itemName(item);
          final isSelected = selected.contains(id);
          return GestureDetector(
            onTap: () => _toggleItem(selected, id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: isSelected ? AppColor.buttonColor.withOpacity(0.2) : Colors.white.withOpacity(0.06),
                border: Border.all(color: isSelected ? AppColor.buttonColor : Colors.white.withOpacity(0.2), width: isSelected ? 1.5 : 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[Icon(Icons.check_circle, size: 14, color: AppColor.buttonColor), const SizedBox(width: 6)],
                  Text(name, style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? Colors.white : Colors.white70)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _badge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColor.buttonColor, fontFamily: AppFont.fontFamily)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.75,
      decoration: BoxDecoration(color: const Color(0xff1a1a2e), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter', style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                if (_totalSelected > 0)
                  GestureDetector(
                    onTap: _clearAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white24)),
                      child: Text('Clear all ($_totalSelected)', style: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 12, color: Colors.white60)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: AppColor.buttonColor, borderRadius: BorderRadius.circular(10)),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(fontFamily: AppFont.fontFamily, fontSize: 12, fontWeight: FontWeight.w400),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Music'), if (_selectedMusicIds.isNotEmpty) ...[const SizedBox(width: 4), _badge(_selectedMusicIds.length)]])),
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('Events'), if (_selectedEventIds.isNotEmpty) ...[const SizedBox(width: 4), _badge(_selectedEventIds.length)]])),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Consumer<MusicGenresController>(builder: (context, controller, _) => SingleChildScrollView(child: _buildChipGrid(controller.getGenresList, _selectedMusicIds, controller.getIsLoading))),
                Consumer<EventPreferenceController>(builder: (context, controller, _) => SingleChildScrollView(child: _buildChipGrid(controller.getEventsList, _selectedEventIds, controller.getIsLoading))),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColor.buttonColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                onPressed: () {
                  Navigator.pop(context, PreferenceFilterResult(selectedMusicGenreIds: List.from(_selectedMusicIds), selectedEventPreferenceIds: List.from(_selectedEventIds)));
                },
                child: Text(_totalSelected > 0 ? 'Apply Filters ($_totalSelected selected)' : 'Apply Filters', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: AppFont.fontFamily)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}