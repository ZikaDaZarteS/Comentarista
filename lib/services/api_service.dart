import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // Headers padrão para todas as requisições
  static Map<String, String> get _defaultHeaders =>
      Map<String, String>.from(ApiConfig.defaultHeaders);

  // Cliente HTTP reutilizável
  static final http.Client _client = http.Client();

  // Cache de token JWT
  static String? _authToken;
  static DateTime? _tokenExpiry;

  /// Obtém o token de autenticação (do cache ou das preferências)
  static Future<String?> getAuthToken() async {
    // Verifica se o token em memória ainda é válido
    if (_authToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return _authToken;
    }

    // Tenta obter o token das preferências
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final expiryString = prefs.getString('token_expiry');

    if (token != null && expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isBefore(expiry)) {
        _authToken = token;
        _tokenExpiry = expiry;
        return token;
      }
    }

    return null;
  }

  /// Salva o token de autenticação
  static Future<void> saveAuthToken(String token, DateTime expiry) async {
    _authToken = token;
    _tokenExpiry = expiry;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('token_expiry', expiry.toIso8601String());
  }

  /// Remove o token de autenticação
  static Future<void> clearAuthToken() async {
    _authToken = null;
    _tokenExpiry = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('token_expiry');
  }

  /// Obtém headers com autenticação se disponível
  static Future<Map<String, String>> getAuthHeaders() async {
    final headers = Map<String, String>.from(_defaultHeaders);
    final token = await getAuthToken();

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Faz uma requisição GET
  static Future<http.Response> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    final headers = await getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
        .replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri, headers: headers);
      _handleResponse(response);
      return response;
    } catch (e) {
      throw ApiException('Erro na requisição GET: $e');
    }
  }

  /// Faz uma requisição POST
  static Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw ApiException('Erro na requisição POST: $e');
    }
  }

  /// Faz uma requisição PUT
  static Future<http.Response> put(String endpoint, {Object? body}) async {
    final headers = await getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client.put(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      _handleResponse(response);
      return response;
    } catch (e) {
      throw ApiException('Erro na requisição PUT: $e');
    }
  }

  /// Faz uma requisição DELETE
  static Future<http.Response> delete(String endpoint) async {
    final headers = await getAuthHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client.delete(uri, headers: headers);
      _handleResponse(response);
      return response;
    } catch (e) {
      throw ApiException('Erro na requisição DELETE: $e');
    }
  }

  /// Trata a resposta da API
  static void _handleResponse(http.Response response) {
    if (response.statusCode >= 400) {
      String errorMessage = 'Erro na API';

      try {
        final errorData = jsonDecode(response.body);
        errorMessage =
            errorData['message'] ?? errorData['error'] ?? errorMessage;
      } catch (e) {
        // Se não conseguir decodificar, usa a mensagem padrão
      }

      switch (response.statusCode) {
        case 401:
          throw UnauthorizedException(errorMessage);
        case 403:
          throw ForbiddenException(errorMessage);
        case 404:
          throw NotFoundException(errorMessage);
        case 429:
          throw RateLimitException(errorMessage);
        case 500:
          throw ServerException(errorMessage);
        default:
          throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    }
  }

  /// Fecha o cliente HTTP
  static void dispose() {
    _client.close();
  }
}

/// Exceções específicas da API
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  NotFoundException(super.message) : super(statusCode: 404);
}

class RateLimitException extends ApiException {
  RateLimitException(super.message) : super(statusCode: 429);
}

class ServerException extends ApiException {
  ServerException(super.message) : super(statusCode: 500);
}
