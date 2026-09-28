import 'package:flutter/foundation.dart';
import '../models/property.dart';
import '../services/property_service.dart';

/// Buyer role sentinel — used to mark the active user's role.
/// Not a security boundary; real auth is handled server-side.
const String kBuyerRole = 'buyer';

/// Possible states for an async data fetch.
enum FetchStatus { idle, loading, success, error }

/// ChangeNotifier that holds the property listing state for buyer-facing screens.
///
/// Keeps [PandoProvider] completely separate — this class only manages
/// property API data and buyer role context.
class PropertyProvider extends ChangeNotifier {
  // ── Buyer role ────────────────────────────────────────────────────────────

  /// The current user's role. 'buyer' is set when the user completes sign-in.
  /// This is a development convenience — real role enforcement is server-side.
  String _role = '';
  String get role => _role;
  bool get isBuyer => _role == kBuyerRole;

  void setBuyerRole() {
    _role = kBuyerRole;
    // Fetch properties as soon as buyer role is established
    if (_properties.isEmpty) fetchProperties();
  }

  void clearRole() {
    _role = '';
    notifyListeners();
  }

  // ── Property listing state ────────────────────────────────────────────────

  List<Property> _properties = [];
  FetchStatus _status = FetchStatus.idle;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  List<Property> get properties  => _properties;
  FetchStatus    get status      => _status;
  String         get errorMessage => _errorMessage;
  bool           get isLoading   => _status == FetchStatus.loading;
  bool           get hasError    => _status == FetchStatus.error;
  bool           get hasMore     => _hasMore;

  // ── Fetch all properties (first page / refresh) ──────────────────────────

  Future<void> fetchProperties({bool refresh = false}) async {
    if (_status == FetchStatus.loading) return;

    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _properties = [];
    }

    _setStatus(FetchStatus.loading);

    final result = await PropertyService.instance.fetchProperties(
      page:  _currentPage,
      limit: 20,
    );

    switch (result) {
      case ApiSuccess<PropertyPage>():
        final page = result.data;
        if (refresh || _currentPage == 1) {
          _properties = page.properties;
        } else {
          _properties = [..._properties, ...page.properties];
        }
        _totalPages  = page.totalPages;
        _currentPage = page.page;
        _hasMore     = _currentPage < _totalPages;
        _setStatus(FetchStatus.success);

      case ApiError<PropertyPage>():
        _errorMessage = result.message;
        // Keep existing data visible on refresh failure — don't wipe the list
        _setStatus(FetchStatus.error);
    }
  }

  /// Load the next page for infinite scroll.
  Future<void> fetchNextPage() async {
    if (!_hasMore || isLoading) return;
    _currentPage++;
    await fetchProperties();
  }

  // ── Filtered views (used by ExploreScreen) ───────────────────────────────

  List<Property> get forBuy =>
      _properties.where((p) => p.purpose == PropertyPurpose.buy).toList();

  List<Property> get forRent =>
      _properties.where((p) => p.purpose == PropertyPurpose.rent).toList();

  List<Property> get offPlan =>
      _properties
          .where((p) =>
              p.purpose == PropertyPurpose.offPlan ||
              p.category == PropertyCategory.offPlan)
          .toList();

  List<Property> filteredBy({
    PropertyCategory? category,
    String? query,
    int categoryTab = 3, // 3 = EXPLORE (all)
  }) {
    var results = _properties.toList();

    // Filter by purpose tab
    switch (categoryTab) {
      case 0:
        results = results.where((p) => p.purpose == PropertyPurpose.buy).toList();
      case 1:
        results = results.where((p) => p.purpose == PropertyPurpose.rent).toList();
      case 2:
        results = results
            .where((p) =>
                p.purpose == PropertyPurpose.offPlan ||
                p.category == PropertyCategory.offPlan)
            .toList();
    }

    // Filter by category
    if (category != null) {
      results = results.where((p) => p.category == category).toList();
    }

    // Filter by search query
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      results = results
          .where((p) =>
              p.community.toLowerCase().contains(q) ||
              p.type.toLowerCase().contains(q) ||
              p.title.toLowerCase().contains(q))
          .toList();
    }

    return results;
  }

  // ── Private ───────────────────────────────────────────────────────────────

  void _setStatus(FetchStatus s) {
    _status = s;
    notifyListeners();
  }
}
