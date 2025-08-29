import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  /// Login usando ID do evento do DataRodeo
  static Future<Map<String, dynamic>> login({required String eventId}) async {
    try {
      debugPrint('🔍 Iniciando login com ID: $eventId');

      // Valida o ID do evento na API do DataRodeo
      final eventInfo = await _validateEventId(eventId);

      if (eventInfo != null && eventInfo['isValid'] == true) {
        // Evento válido confirmado - cria token de acesso
        final tempToken =
            'valid_${DateTime.now().millisecondsSinceEpoch}_$eventId';
        await _saveToken(tempToken);

        debugPrint('✅ Login bem-sucedido para evento: ${eventInfo['name']}');

        return {
          'success': true,
          'message': 'Login realizado com sucesso',
          'data': {
            'event_id': eventId,
            'event_name': eventInfo['name'],
            'event_status': eventInfo['status'],
            'has_competitors': eventInfo['hasCompetitors'],
            'has_animals': eventInfo['hasAnimals'],
            'has_rounds': eventInfo['hasRounds'],
            'token': tempToken,
          }
        };
      } else {
        // Evento inválido
        debugPrint('❌ ID inválido: $eventId');
        return {
          'success': false,
          'message': 'ID do evento inválido ou não encontrado',
          'data': null
        };
      }
    } catch (e) {
      debugPrint('❌ Erro no login: $e');
      return {
        'success': false,
        'message': 'Erro na validação: $e',
        'data': null
      };
    }
  }

  /// Valida o ID do evento na API do DataRodeo
  static Future<Map<String, dynamic>?> _validateEventId(String eventId) async {
    try {
      debugPrint('🔍 Validando evento ID: $eventId');

      // Endpoint principal da API do DataRodeo para mobile
      final mainEndpoint = '/api/mobile?id=$eventId';
      final fullUrl = 'https://datarodeo.com.br$mainEndpoint';

      debugPrint('🌐 Fazendo requisição para: $fullUrl');
      debugPrint(
          '📱 Headers: Content-Type: application/json, Accept: application/json, User-Agent: Comentarista/1.0.0');

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'User-Agent': 'Comentarista/1.0.0'
        },
      ).timeout(const Duration(seconds: 20));

      debugPrint('📡 Resposta recebida - Status: ${response.statusCode}');
      debugPrint(
          '📄 Conteúdo (primeiros 300 chars): ${response.body.length > 300 ? "${response.body.substring(0, 300)}..." : response.body}');

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data != null && data is Map) {
            // Verifica se tem dados válidos
            final hasEvento = data['evento'] != null;
            final hasRound = data['round'] != null && data['round'] is List;
            final hasCompetitors =
                hasRound && (data['round'] as List).isNotEmpty;
            final hasAnimals =
                data['animals'] != null && data['animals'] is List;
            final hasRounds = data['rounds'] != null && data['rounds'] is List;

            debugPrint('✅ Evento encontrado: ${data['evento']}');
            debugPrint(
                '📊 Dados: evento=$hasEvento, round=$hasRound, competidores=$hasCompetitors');

            return {
              'isValid': hasEvento && hasRound,
              'name': data['evento'] is String
                  ? data['evento'] as String
                  : (data['evento'] is Map
                      ? (data['evento'] as Map)['nome'] ?? 'Evento'
                      : 'Evento'),
              'status': data['evento'] is Map
                  ? (data['evento'] as Map)['status'] ?? 'Ativo'
                  : 'Ativo',
              'hasCompetitors': hasCompetitors,
              'hasAnimals': hasAnimals,
              'hasRounds': hasRounds,
            };
          }
        } catch (e) {
          debugPrint('❌ Erro ao decodificar JSON: $e');
        }
      } else if (response.statusCode == 400) {
        debugPrint('❌ ID inválido - Status 400: ${response.body}');
        return {
          'isValid': false,
          'name': 'ID Inválido',
          'status': 'Erro',
          'hasCompetitors': false,
          'hasAnimals': false,
          'hasRounds': false,
        };
      } else {
        debugPrint('❌ Status HTTP inválido: ${response.statusCode}');
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erro na validação: $e');
      return null;
    }
  }

  /// Salva o token nas preferências
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('token_expiry',
        DateTime.now().add(const Duration(hours: 24)).toIso8601String());
  }

  /// Valida se o token atual é válido
  static Future<bool> validateToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final expiryString = prefs.getString('token_expiry');

      if (token == null || expiryString == null) {
        return false;
      }

      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isAfter(expiry)) {
        await logout();
        return false;
      }

      // Se for um token válido do DataRodeo, sempre retorna true
      if (token.startsWith('valid_')) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Erro na validação do token: $e');
      return false;
    }
  }

  /// Renova o token se necessário
  static Future<String?> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.startsWith('valid_')) {
        // Para tokens válidos do DataRodeo, renova por mais 24 horas
        final newToken =
            'valid_${DateTime.now().millisecondsSinceEpoch}_${token.split('_').last}';
        await _saveToken(newToken);
        return newToken;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erro ao renovar token: $e');
      return null;
    }
  }

  /// Faz logout e remove o token
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('token_expiry');
      debugPrint('✅ Logout realizado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro no logout: $e');
    }
  }

  /// Verifica se o usuário está autenticado
  static Future<bool> isAuthenticated() async {
    return await validateToken();
  }

  /// Obtém informações do usuário atual
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.startsWith('valid_')) {
        final parts = token.split('_');
        if (parts.length >= 3) {
          return {
            'eventId': parts[2],
            'loginTime':
                DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1])),
            'tokenType': 'DataRodeo'
          };
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Erro ao obter usuário atual: $e');
      return null;
    }
  }

  /// Obtém o ID da rodada atual
  static Future<String?> getCurrentRound() async {
    try {
      final user = await getCurrentUser();
      return user?['eventId'];
    } catch (e) {
      debugPrint('❌ Erro ao obter rodada atual: $e');
      return null;
    }
  }
}
