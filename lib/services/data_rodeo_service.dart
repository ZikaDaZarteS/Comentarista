import 'dart:convert';
import 'api_service.dart';
import '../models/evento.dart';
import '../config/api_config.dart';

class DataRodeoService {
  /// Obtém todos os eventos disponíveis
  static Future<List<Evento>> getEvents({
    int page = 1,
    int limit = 20,
    String? status,
    String? tipo,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (tipo != null) queryParams['tipo'] = tipo;

      final endpoint = ApiConfig.getEndpoint('events', 'list');
      final response = await ApiService.get(endpoint, queryParams: queryParams);
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> eventsJson = data['data'];
        return eventsJson.map((json) => Evento.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw ApiException('Erro ao buscar eventos: $e');
    }
  }

  /// Obtém um evento específico por ID
  static Future<Evento?> getEvent(String eventId) async {
    try {
      final endpoint =
          ApiConfig.getEndpoint('events', 'get').replaceAll('{id}', eventId);
      final response = await ApiService.get(endpoint);
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return Evento.fromJson(data['data']);
      }

      return null;
    } catch (e) {
      throw ApiException('Erro ao buscar evento: $e');
    }
  }

  /// Obtém todas as rodadas de um evento
  static Future<List<Round>> getEventRounds(
    String eventId, {
    String? etapa,
    int? competitorId,
    int? animalId,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (etapa != null) queryParams['etapa'] = etapa;
      if (competitorId != null) {
        queryParams['competitor_id'] = competitorId.toString();
      }
      if (animalId != null) queryParams['animal_id'] = animalId.toString();

      final endpoint = ApiConfig.getEndpoint('rounds', 'list')
          .replaceAll('{event_id}', eventId);
      final response = await ApiService.get(endpoint, queryParams: queryParams);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> roundsJson = data['data'];
        return roundsJson.map((json) => Round.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw ApiException('Erro ao buscar rodadas: $e');
    }
  }

  /// Obtém rodadas filtradas por etapa
  static Future<List<Round>> getRoundsByStage(
      String eventId, String etapa) async {
    return await getEventRounds(eventId, etapa: etapa);
  }

  /// Obtém o ranking de um evento
  static Future<List<Map<String, dynamic>>> getEventRanking(
    String eventId, {
    String? tipo,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (tipo != null) queryParams['tipo'] = tipo;

      final endpoint = ApiConfig.getEndpoint('rankings', 'list')
          .replaceAll('{event_id}', eventId);
      final response = await ApiService.get(endpoint, queryParams: queryParams);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> rankingsJson = data['data'];
        return rankingsJson.cast<Map<String, dynamic>>();
      }

      return [];
    } catch (e) {
      throw ApiException('Erro ao buscar ranking: $e');
    }
  }

  /// Obtém estatísticas de uma etapa
  static Future<Map<String, dynamic>> getStageStats(
      String eventId, String etapa) async {
    try {
      final endpoint =
          ApiConfig.getEndpoint('events', 'stats').replaceAll('{id}', eventId);
      final response =
          await ApiService.get(endpoint, queryParams: {'etapa': etapa});

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      }

      return {
        'total_participants': 0,
        'average_score': 0.0,
        'best_score': 0.0,
        'total_rounds': 0,
      };
    } catch (e) {
      throw ApiException('Erro ao buscar estatísticas: $e');
    }
  }

  /// Obtém todos os animais
  static Future<List<Animal>> getAnimals({
    int? tropeiroId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (tropeiroId != null) {
        queryParams['tropeiro_id'] = tropeiroId.toString();
      }

      final endpoint = ApiConfig.getEndpoint('animals', 'list');
      final response = await ApiService.get(endpoint, queryParams: queryParams);
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> animalsJson = data['data'];
        return animalsJson.map((json) => Animal.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw ApiException('Erro ao buscar animais: $e');
    }
  }

  /// Obtém todos os competidores
  static Future<List<Competidor>> getCompetitors({
    String? cidade,
    String? uf,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (cidade != null) queryParams['cidade'] = cidade;
      if (uf != null) queryParams['uf'] = uf;

      final endpoint = ApiConfig.getEndpoint('competitors', 'list');
      final response = await ApiService.get(endpoint, queryParams: queryParams);
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> competitorsJson = data['data'];
        return competitorsJson
            .map((json) => Competidor.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw ApiException('Erro ao buscar competidores: $e');
    }
  }

  /// Obtém todos os tropeiros
  static Future<List<Tropeiro>> getTropeiros({
    String? cidade,
    String? uf,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (cidade != null) queryParams['cidade'] = cidade;
      if (uf != null) queryParams['uf'] = uf;

      final endpoint = ApiConfig.getEndpoint('tropeiros', 'list');
      final response = await ApiService.get(endpoint, queryParams: queryParams);
      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> tropeirosJson = data['data'];
        return tropeirosJson.map((json) => Tropeiro.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw ApiException('Erro ao buscar tropeiros: $e');
    }
  }

  /// Obtém participantes filtrados por etapa (compatibilidade com o serviço anterior)
  static Future<List<Map<String, dynamic>>> getParticipantsByStage(
    String eventId,
    String etapa,
  ) async {
    try {
      final rounds = await getRoundsByStage(eventId, etapa);

      return rounds.map((round) {
        return {
          'animal':
              round.etapa, // Usando etapa como animal para compatibilidade
          'animalScore': round.notaTotal.toString(),
          'competitor': 'Competidor ${round.idCompetidor}', // Placeholder
          'competitorScore': round.notaTotal.toString(),
          'cidade': 'Cidade', // Placeholder
          'tropeiro': 'Tropeiro', // Placeholder
          'lado': round.lado,
          'seq': round.seq,
        };
      }).toList();
    } catch (e) {
      throw ApiException('Erro ao buscar participantes: $e');
    }
  }

  /// Obtém etapas disponíveis para um evento
  static Future<List<String>> getEventStages(String eventId) async {
    try {
      final endpoint =
          ApiConfig.getEndpoint('events', 'stages').replaceAll('{id}', eventId);
      final response = await ApiService.get(endpoint);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> stagesJson = data['data'];
        return stagesJson
            .map((stage) => stage['nome'] ?? stage['etapa'])
            .cast<String>()
            .toList();
      }

      // Fallback para etapas padrão se a API não retornar
      return ['ROUND 1', 'ROUND 3', 'ROUND4', 'ROUND5'];
    } catch (e) {
      // Fallback para etapas padrão em caso de erro
      return ['ROUND 1', 'ROUND 3', 'ROUND4', 'ROUND5'];
    }
  }

  /// Busca eventos por texto (search)
  static Future<List<Evento>> searchEvents(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final endpoint = ApiConfig.getEndpoint('events', 'search');
      final response = await ApiService.get(endpoint, queryParams: queryParams);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> eventsJson = data['data'];
        return eventsJson.map((json) => Evento.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      throw ApiException('Erro na busca: $e');
    }
  }

  /// Obtém dados em tempo real de um evento (WebSocket fallback para HTTP)
  static Future<Map<String, dynamic>> getLiveEventData(String eventId) async {
    try {
      final endpoint =
          ApiConfig.getEndpoint('events', 'live').replaceAll('{id}', eventId);
      final response = await ApiService.get(endpoint);

      final data = jsonDecode(response.body);

      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      }

      return {};
    } catch (e) {
      throw ApiException('Erro ao buscar dados em tempo real: $e');
    }
  }
}
