import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';
import 'api_config.dart';

/// Returned by every API method — either data or an error message.
sealed class ApiResult<T> {}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  ApiSuccess(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final String message;
  ApiError(this.message);
}

/// Paginated wrapper for the property listing endpoint.
class PropertyPage {
  final List<Property> properties;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PropertyPage({
    required this.properties,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });
}

/// HTTP service for the Hi Pando backend property endpoints.
/// Never connect Flutter directly to MongoDB — all calls go through this class.
class PropertyService {
  PropertyService._();
  static final PropertyService instance = PropertyService._();

  final _client = http.Client();

  Duration get _connectTimeout =>
      const Duration(seconds: ApiConfig.connectTimeoutSeconds);

  // ── GET /api/v1/properties ───────────────────────────────────────────────

  Future<ApiResult<PropertyPage>> fetchProperties({
    int page = 1,
    int limit = 20,
    String? purpose,
  }) async {
    try {
      final params = {
        'page':  page.toString(),
        'limit': limit.toString(),
        if (purpose != null) 'purpose': purpose,
      };
      final uri = Uri.parse('${ApiConfig.baseUrl}/properties')
          .replace(queryParameters: params);

      final response = await _client
          .get(uri, headers: _headers())
          .timeout(_connectTimeout);

      return _handleListResponse(response);
    } catch (e) {
      return ApiError(_networkErrorMessage(e));
    }
  }

  // ── GET /api/v1/properties/featured ─────────────────────────────────────

  Future<ApiResult<List<Property>>> fetchFeatured() async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/properties/featured');

      final response = await _client
          .get(uri, headers: _headers())
          .timeout(_connectTimeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          final list = (body['data'] as List)
              .map((e) => Property.fromJson(e as Map<String, dynamic>))
              .toList();
          return ApiSuccess(list);
        }
        return ApiError(body['message']?.toString() ?? 'Unknown error');
      }
      return ApiError('Server returned status ${response.statusCode}');
    } catch (e) {
      return ApiError(_networkErrorMessage(e));
    }
  }

  // ── GET /api/v1/properties/:id ───────────────────────────────────────────

  Future<ApiResult<Property>> fetchPropertyById(String id) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/properties/$id');

      final response = await _client
          .get(uri, headers: _headers())
          .timeout(_connectTimeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        if (body['success'] == true) {
          return ApiSuccess(
              Property.fromJson(body['data'] as Map<String, dynamic>));
        }
        return ApiError(body['message']?.toString() ?? 'Unknown error');
      }
      if (response.statusCode == 404) {
        return ApiError('Property not found');
      }
      return ApiError('Server returned status ${response.statusCode}');
    } catch (e) {
      return ApiError(_networkErrorMessage(e));
    }
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  ApiResult<PropertyPage> _handleListResponse(http.Response response) {
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        final rawList = body['data'] as List;
        final properties = rawList
            .map((e) => Property.fromJson(e as Map<String, dynamic>))
            .toList();
        final pagination = body['pagination'] as Map<String, dynamic>? ?? {};
        return ApiSuccess(PropertyPage(
          properties:  properties,
          page:        (pagination['page']       as num?)?.toInt() ?? 1,
          limit:       (pagination['limit']      as num?)?.toInt() ?? 20,
          total:       (pagination['total']      as num?)?.toInt() ?? 0,
          totalPages:  (pagination['totalPages'] as num?)?.toInt() ?? 0,
        ));
      }
      return ApiError(body['message']?.toString() ?? 'Unknown error');
    }
    return ApiError('Server returned status ${response.statusCode}');
  }

  String _networkErrorMessage(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('timeout')) return 'Request timed out. Check your connection.';
    if (msg.contains('socketexception') || msg.contains('connection refused')) {
      return 'Cannot reach the server. Make sure the backend is running.';
    }
    return 'Network error. Please try again.';
  }
}
