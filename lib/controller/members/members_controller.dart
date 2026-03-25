import 'package:flutter/material.dart';
import '../../provider/common_api_helper.dart';
import '../../utilities/app_constant.dart';

class MembersController with ChangeNotifier {
  bool _isLikedMembersLoading = false;
  bool _isConnectedMembersLoading = false;
  bool _isLikedMembersLoadingMore = false;
  bool _isConnectedMembersLoadingMore = false;
  List<dynamic> _likedMembers = [];
  List<dynamic> _connectedMembers = [];
  int _likedCurrentPage = 0;
  int _connectedCurrentPage = 0;
  bool _likedHasMore = true;
  bool _connectedHasMore = true;

  bool get isLikedMembersLoading => _isLikedMembersLoading;
  bool get isConnectedMembersLoading => _isConnectedMembersLoading;
  bool get isLikedMembersLoadingMore => _isLikedMembersLoadingMore;
  bool get isConnectedMembersLoadingMore => _isConnectedMembersLoadingMore;
  List<dynamic> get likedMembers => _likedMembers;
  List<dynamic> get connectedMembers => _connectedMembers;
  bool get likedHasMore => _likedHasMore;
  bool get connectedHasMore => _connectedHasMore;

  Future<void> fetchMyMembers(
    BuildContext context, {
    String type = 'liked',
    int page = 1,
    int limit = 10,
    bool loadMore = false,
  }) async {
    final token = AppConstant.token;
    if (token.isEmpty) return;
    final isConnectedType = type == 'connected';
    final isLoadMoreRequest = loadMore || page > 1;

    if (isLoadMoreRequest) {
      final isAlreadyLoadingMore = isConnectedType
          ? _isConnectedMembersLoadingMore
          : _isLikedMembersLoadingMore;
      final hasMore = isConnectedType ? _connectedHasMore : _likedHasMore;
      if (isAlreadyLoadingMore || !hasMore) return;
    }

    if (isLoadMoreRequest) {
      if (isConnectedType) {
        _isConnectedMembersLoadingMore = true;
      } else {
        _isLikedMembersLoadingMore = true;
      }
    } else {
      if (isConnectedType) {
        _isConnectedMembersLoading = true;
        _connectedHasMore = true;
      } else {
        _isLikedMembersLoading = true;
        _likedHasMore = true;
      }
    }
    notifyListeners();

    try {
      final response = await getData(
        'common/my_members?type=$type&page=$page&limit=$limit',
        context,
        headers: {
          'authorization': 'Bearer $token',
        },
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        List<dynamic> parsed = [];
        int currentPage = page;
        int totalPages = 0;
        int totalRecords = 0;
        if (data is List) {
          parsed = data;
        } else if (data is Map && data['list'] is List) {
          parsed = List<dynamic>.from(data['list']);
          currentPage = (data['current_page'] as num?)?.toInt() ?? page;
          totalPages = (data['total_pages'] as num?)?.toInt() ?? 0;
          totalRecords = (data['total_records'] as num?)?.toInt() ?? 0;
        }

        if (isConnectedType) {
          _connectedCurrentPage = currentPage;
          _connectedMembers = isLoadMoreRequest
              ? [..._connectedMembers, ...parsed]
              : parsed;
          _connectedHasMore = _computeHasMore(
            currentPage: currentPage,
            totalPages: totalPages,
            totalRecords: totalRecords,
            loadedItems: _connectedMembers.length,
            lastPageCount: parsed.length,
            limit: limit,
          );
        } else {
          _likedCurrentPage = currentPage;
          _likedMembers =
              isLoadMoreRequest ? [..._likedMembers, ...parsed] : parsed;
          _likedHasMore = _computeHasMore(
            currentPage: currentPage,
            totalPages: totalPages,
            totalRecords: totalRecords,
            loadedItems: _likedMembers.length,
            lastPageCount: parsed.length,
            limit: limit,
          );
        }
      } else if (response != null) {
        if (isConnectedType) {
          if (!isLoadMoreRequest) {
            _connectedMembers = [];
            _connectedCurrentPage = 0;
            _connectedHasMore = false;
          }
        } else {
          if (!isLoadMoreRequest) {
            _likedMembers = [];
            _likedCurrentPage = 0;
            _likedHasMore = false;
          }
        }
        // CommonHelper.handleInactiveUserRedirect(context, response);
      }
    } catch (_) {
      if (isConnectedType) {
        if (!isLoadMoreRequest) {
          _connectedMembers = [];
          _connectedCurrentPage = 0;
          _connectedHasMore = false;
        }
      } else {
        if (!isLoadMoreRequest) {
          _likedMembers = [];
          _likedCurrentPage = 0;
          _likedHasMore = false;
        }
      }
    } finally {
      if (isLoadMoreRequest) {
        if (isConnectedType) {
          _isConnectedMembersLoadingMore = false;
        } else {
          _isLikedMembersLoadingMore = false;
        }
      } else {
        if (isConnectedType) {
          _isConnectedMembersLoading = false;
        } else {
          _isLikedMembersLoading = false;
        }
      }
      notifyListeners();
    }
  }

  Future<void> loadMoreMembers(
    BuildContext context, {
    String type = 'liked',
    int limit = 10,
  }) async {
    final isConnectedType = type == 'connected';
    final hasMore = isConnectedType ? _connectedHasMore : _likedHasMore;
    final isLoadingMore = isConnectedType
        ? _isConnectedMembersLoadingMore
        : _isLikedMembersLoadingMore;

    if (!hasMore || isLoadingMore) return;

    final nextPage =
        (isConnectedType ? _connectedCurrentPage : _likedCurrentPage) + 1;
    if (nextPage <= 1) return;

    await fetchMyMembers(
      context,
      type: type,
      page: nextPage,
      limit: limit,
      loadMore: true,
    );
  }

  bool _computeHasMore({
    required int currentPage,
    required int totalPages,
    required int totalRecords,
    required int loadedItems,
    required int lastPageCount,
    required int limit,
  }) {
    if (totalPages > 0) {
      // API is 1-based: hasMore while current_page < total_pages.
      return currentPage < totalPages;
    }
    if (totalRecords > 0) {
      return loadedItems < totalRecords;
    }
    return lastPageCount >= limit;
  }
}
