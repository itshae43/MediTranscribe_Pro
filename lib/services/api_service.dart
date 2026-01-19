import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../models/consultation.dart';
import '../config/environment.dart';
import '../config/constants.dart';

/// API Service
/// Handles all HTTP communication with the backend server

class ApiService {
  late final Dio _dio;
  final Logger _logger = Logger();

  ApiService({String? baseUrl}) {
    _dio = Dio();
    _dio.options.baseUrl = baseUrl ?? Environment.backendUrl;
    _dio.options.connectTimeout = AppConstants.connectionTimeout;
    _dio.options.receiveTimeout = AppConstants.receiveTimeout;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add logging interceptor in development
    if (Environment.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  /// Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Create new consultation
  Future<Consultation?> createConsultation({
    required String patientId,
    required String doctorId,
  }) async {
    try {
      _logger.i('Creating consultation...');

      final response = await _dio.post(
        AppConstants.createConsultation,
        data: {
          'patient_id': patientId,
          'doctor_id': doctorId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final consultation = Consultation.fromJson(response.data);
        _logger.i('Consultation created: ${consultation.id}');
        return consultation;
      } else {
        _logger.e('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      _logger.e('Create consultation error: $e');
    }
    return null;
  }

  /// Finalize consultation and generate notes
  Future<Map<String, dynamic>?> finalizeConsultation({
    required String consultationId,
    required String transcript,
    required List<dynamic> speakerLabels,
  }) async {
    try {
      _logger.i('Finalizing consultation: $consultationId');

      final endpoint = AppConstants.finalizeConsultation
          .replaceAll('{id}', consultationId);

      final response = await _dio.post(
        endpoint,
        data: {
          'transcript': transcript,
          'speaker_labels': speakerLabels,
        },
      );

      if (response.statusCode == 200) {
        _logger.i('Consultation finalized');
        return response.data;
      } else {
        _logger.e('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      _logger.e('Finalize consultation error: $e');
    }
    return null;
  }

  /// Get consultation details
  Future<Consultation?> getConsultation(String consultationId) async {
    try {
      _logger.i('Fetching consultation: $consultationId');

      final endpoint = AppConstants.getConsultation
          .replaceAll('{id}', consultationId);

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        return Consultation.fromJson(response.data);
      } else {
        _logger.e('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      _logger.e('Get consultation error: $e');
    }
    return null;
  }

  /// Get all consultations
  Future<List<Consultation>?> getAllConsultations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      _logger.i('Fetching all consultations: page=$page, limit=$limit');

      final response = await _dio.get(
        '/api/v1/consultations',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['consultations'] ?? response.data;
        return data.map((json) => Consultation.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      _logger.e('Get all consultations error: $e');
    }
    return null;
  }

  /// Get audit logs for a consultation
  Future<List<Map<String, dynamic>>?> getAuditLogs(String consultationId) async {
    try {
      _logger.i('Fetching audit logs: $consultationId');

      final endpoint = AppConstants.getAuditLogs
          .replaceAll('{id}', consultationId);

      final response = await _dio.get(endpoint);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['logs'] ?? []);
      } else {
        _logger.e('Unexpected status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      _logger.e('Get audit logs error: $e');
    }
    return null;
  }

  /// Delete consultation
  Future<bool> deleteConsultation(String consultationId) async {
    try {
      _logger.i('Deleting consultation: $consultationId');

      final response = await _dio.delete(
        '/api/v1/consultation/$consultationId',
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      _logger.e('DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      _logger.e('Delete consultation error: $e');
    }
    return false;
  }

  /// Health check
  Future<bool> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Health check failed: $e');
      return false;
    }
  }

  void _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        _logger.e('Connection timeout');
        break;
      case DioExceptionType.receiveTimeout:
        _logger.e('Receive timeout');
        break;
      case DioExceptionType.badResponse:
        _logger.e('Bad response: ${e.response?.statusCode}');
        _logger.e('Response data: ${e.response?.data}');
        break;
      case DioExceptionType.connectionError:
        _logger.e('Connection error - check if backend is running');
        break;
      case DioExceptionType.unknown:
        _logger.e('Unknown error: ${e.error}');
        break;
      default:
        _logger.e('DioException: ${e.message}');
    }
  }
}
