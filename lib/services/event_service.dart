import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'data_rodeo_service.dart';

class EventService {
  static List<String> _etapas = ['ROUND 1', 'ROUND 3', 'ROUND4', 'ROUND5'];
  static String? _currentEventId;

  // ✅ Helper CIRÚRGICO para converter notas (trata Int32 e Decimal)
  static double _parseNotaTotal(dynamic notaTotal) {
    if (notaTotal == null) return 0.0;

    // Se já é um número, converte diretamente
    if (notaTotal is num) {
      return notaTotal.toDouble();
    }

    // Se é string, trata vírgula como separador decimal
    final notaStr = notaTotal.toString().replaceAll(',', '.');
    return double.tryParse(notaStr) ?? 0.0;
  }

  /// Define o ID do evento atual
  static void setCurrentEventId(dynamic eventId) {
    _currentEventId = eventId.toString();
  }

  /// Obtém o ID do evento atual
  static String? getCurrentEventId() {
    return _currentEventId;
  }

  /// ✅ Carregar etapas do backend (API DataRodeo)
  static Future<List<String>> getEtapas() async {
    try {
      if (_currentEventId != null) {
        // Tenta obter etapas da API
        final stages = await DataRodeoService.getEventStages(_currentEventId!);
        if (stages.isNotEmpty) {
          _etapas = stages;
          return stages;
        }

        // Se não conseguir da API, tenta extrair das rounds
        final data = await loadEventData();
        if (data['round'] != null && data['round'] is List) {
          final rounds = data['round'] as List;
          final etapasUnicas = <String>{};

          for (final round in rounds) {
            if (round['etapa'] != null &&
                round['etapa'].toString().isNotEmpty) {
              etapasUnicas.add(round['etapa'].toString());
            }
          }

          if (etapasUnicas.isNotEmpty) {
            _etapas = etapasUnicas.toList()..sort();
            return _etapas;
          }
        }
      }

      // Fallback para etapas padrão
      return _etapas;
    } catch (e) {
      // Em caso de erro, retorna etapas padrão
      return _etapas;
    }
  }

  /// ✅ Obter companhias do evento (nova funcionalidade)
  static Future<List<String>> getCompanhias() async {
    try {
      final data = await loadEventData();
      if (data['round'] != null && data['round'] is List) {
        final rounds = data['round'] as List;
        final companhias = rounds
            .map((round) => round['tropeiro']?.toString() ?? '')
            .where((companhia) => companhia.isNotEmpty && companhia != '-')
            .toSet()
            .toList();
        return companhias;
      }
    } catch (e) {
      debugPrint('Erro ao obter companhias: $e');
    }

    return [];
  }

  /// ✅ Carregar dados do evento do backend JSON (com fallback para API)
  static Future<Map<String, dynamic>> loadEventData() async {
    try {
      // Primeiro tenta carregar da API se houver evento selecionado
      if (_currentEventId != null) {
        try {
          // Carrega dados direto da API do DataRodeo (mesmo endpoint do login)
          final response = await http.get(
            Uri.parse(
                'https://datarodeo.com.br/api/mobile?id=$_currentEventId'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'Comentarista/1.0.0'
            },
          ).timeout(const Duration(seconds: 20));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data != null && data is Map) {
              // Retorna os dados completos da API
              return {
                'evento': data['evento'] is String
                    ? data['evento']
                    : (data['evento']?['nome'] ?? 'Evento'),
                'round': data['round'] ?? [],
                'rank': data['rank'] ?? [],
                'animals': data['animals'] ?? [],
                'tropeiro': data['tropeiro'] ?? [],
                'professionals': data['professionals'] ?? [],
                'ocorrencias': data['ocorrencias'] ?? [],
              };
            }
          }
        } catch (e) {
          debugPrint('Erro ao carregar dados da API: $e');
          // Se falhar na API, continua com o JSON local
        }
      }

      // Fallback para JSON local
      final String response =
          await rootBundle.loadString('data/events/comentarista.json.txt');
      final Map<String, dynamic> data = json.decode(response);
      return data;
    } catch (e) {
      debugPrint('Erro ao carregar dados do evento: $e');
      return {};
    }
  }

  /// ✅ Carregar rounds da API DataRodeo
  static Future<List<Map<String, dynamic>>> loadRoundsFromAPI() async {
    if (_currentEventId == null) {
      return [];
    }

    try {
      final rounds = await DataRodeoService.getEventRounds(_currentEventId!);
      return rounds.map((round) => round.toJson()).toList();
    } catch (e) {
      debugPrint('Erro ao carregar rounds da API: $e');
      return [];
    }
  }

  /// ✅ Filtrar rounds por etapa (compatibilidade com API)
  static Future<List<Map<String, dynamic>>> getRoundsByStage(
      List<dynamic> rounds, String etapa) async {
    try {
      // Se temos evento selecionado, tenta usar a API
      if (_currentEventId != null) {
        final apiRounds =
            await DataRodeoService.getRoundsByStage(_currentEventId!, etapa);
        return apiRounds.map((round) => round.toJson()).toList();
      }
    } catch (e) {
      // Se falhar na API, usa o método local
    }

    // Fallback para filtro local
    return rounds
        .where((round) => round['etapa'] == etapa)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// ✅ Obter participantes filtrados por companhia (nova funcionalidade)
  static Future<List<Map<String, dynamic>>> getParticipantsByCompanhia(
      List<dynamic> rounds, String companhia) async {
    // Filtra rounds por companhia (tropeiro)
    final companhiaRounds = companhia.isEmpty
        ? rounds // Se companhia vazia, retorna todos os rounds
        : rounds
            .where((round) =>
                round['tropeiro']?.toString().toUpperCase() ==
                companhia.toUpperCase())
            .toList();

    return companhiaRounds.map((round) {
      return {
        'id': round['id'] ?? 0,
        'seq': round['seq'] ?? 0,
        'animal': round['animal'] ?? '',
        'animal_descricao': round['animal_descricao'] ?? '',
        'animalScore': round['nota_animal'] ?? 0,
        'competitor': round['competidor'] ?? '',
        'competitor_descricao': round['competidor_descricao'] ?? '',
        'competitorScore': round['nota_competidor'] ?? 0,
        'cidade': round['cidade'] ?? '',
        'cidade_tropeiro': round['cidade_tropeiro'] ?? '',
        'tropeiro': round['tropeiro'] ?? '',
        'lado': round['lado'] ?? '',
        'etapa': round['etapa'] ?? '',
        'nota': round['nota'] ?? 0,
        'nota_total': _parseNotaTotal(round['nota_total']),
        'tempo': round['tempo'] ?? 0,
        'bonus': round['bonus'] ?? 0,
        'id_animal': round['id_animal'],
        'id_competidor': round['id_competidor'],
        'id_etapa': round['id_etapa'],
        'cpf': round['cpf'] ?? '',
        'data_nascimento': round['data_nascimento'],
      };
    }).toList();
  }

  /// ✅ Obter participantes filtrados por etapa (compatibilidade com API)
  static Future<List<Map<String, dynamic>>> getParticipantsByStage(
      List<dynamic> rounds, String etapa) async {
    try {
      // Se temos evento selecionado, tenta usar a API
      if (_currentEventId != null) {
        return await DataRodeoService.getParticipantsByStage(
            _currentEventId!, etapa);
      }
    } catch (e) {
      // Se falhar na API, usa o método local
    }

    // Fallback para método local - processa dados reais da API
    final stageRounds = etapa.isEmpty
        ? rounds // ✅ Se etapa vazia, retorna todos os rounds
        : rounds
            .where((round) =>
                round['etapa']
                    ?.toString()
                    .toUpperCase()
                    .contains(etapa.toUpperCase()) ==
                true)
            .toList();

    return stageRounds.map((round) {
      return {
        'id': round['id'] ?? 0,
        'seq': round['seq'] ?? 0,
        'animal': round['animal'] ?? '',
        'animal_descricao': round['animal_descricao'] ?? '',
        'animalScore': _parseNotaTotal(round['nota_total']).toString(),
        'competitor': round['competidor'] ?? '',
        'competitor_descricao': round['competidor_descricao'] ?? '',
        'competitorScore': _parseNotaTotal(round['nota_total']).toString(),
        'cidade': round['cidade'] ?? '',
        'cidade_tropeiro': round['cidade_tropeiro'] ?? '',
        'tropeiro': round['tropeiro'] ?? '',
        'lado': round['lado'] ?? '',
        'etapa': round['etapa'] ?? '',
        'nota': round['nota'] ?? 0,
        'nota_total': _parseNotaTotal(round['nota_total']),
        'tempo': round['tempo'] ?? 0,
        'bonus': round['bonus'] ?? 0,
        'id_animal': round['id_animal'],
        'id_competidor': round['id_competidor'],
        'id_etapa': round['id_etapa'],
        'cpf': round['cpf'] ?? '',
        'data_nascimento': round['data_nascimento'],
      };
    }).toList();
  }

  /// ✅ Obter estatísticas da etapa (compatibilidade com API)
  static Future<Map<String, dynamic>> getStageStats(
      List<dynamic> rounds, String etapa) async {
    try {
      // Se temos evento selecionado, tenta usar a API
      if (_currentEventId != null) {
        return await DataRodeoService.getStageStats(_currentEventId!, etapa);
      }
    } catch (e) {
      // Se falhar na API, usa o método local
    }

    // Fallback para método local
    final stageRounds = await getRoundsByStage(rounds, etapa);

    if (stageRounds.isEmpty) {
      return {
        'total_participants': 0,
        'average_score': 0.0,
        'best_score': 0.0,
        'total_rounds': 0,
      };
    }

    final scores =
        stageRounds.map((r) => _parseNotaTotal(r['nota_total'])).toList();
    final totalScore = scores.reduce((a, b) => a + b);
    final averageScore = totalScore / scores.length;
    final bestScore = scores.reduce((a, b) => a > b ? a : b);

    return {
      'total_participants': stageRounds.length,
      'average_score': double.parse(averageScore.toStringAsFixed(2)),
      'best_score': bestScore,
      'total_rounds': stageRounds.length,
    };
  }

  /// ✅ Obter ranking do evento (nova funcionalidade com API)
  static Future<List<Map<String, dynamic>>> getEventRanking({
    String? tipo,
    int page = 1,
    int limit = 50,
  }) async {
    if (_currentEventId == null) {
      return [];
    }

    try {
      return await DataRodeoService.getEventRanking(
        _currentEventId!,
        tipo: tipo,
        page: page,
        limit: limit,
      );
    } catch (e) {
      debugPrint('Erro ao obter ranking: $e');
      return [];
    }
  }

  /// ✅ Obter dados em tempo real (nova funcionalidade com API)
  static Future<Map<String, dynamic>> getLiveData() async {
    if (_currentEventId == null) {
      return {};
    }

    try {
      return await DataRodeoService.getLiveEventData(_currentEventId!);
    } catch (e) {
      debugPrint('Erro ao obter dados em tempo real: $e');
      return {};
    }
  }

  /// ✅ Buscar eventos (nova funcionalidade com API)
  static Future<List<Map<String, dynamic>>> searchEvents(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final events =
          await DataRodeoService.searchEvents(query, page: page, limit: limit);
      return events.map((event) => event.toJson()).toList();
    } catch (e) {
      debugPrint('Erro na busca: $e');
      return [];
    }
  }

  /// ✅ Obter todos os eventos disponíveis (nova funcionalidade com API)
  static Future<List<Map<String, dynamic>>> getAllEvents({
    int page = 1,
    int limit = 20,
    String? status,
    String? tipo,
  }) async {
    try {
      final events = await DataRodeoService.getEvents(
        page: page,
        limit: limit,
        status: status,
        tipo: tipo,
      );
      return events.map((event) => event.toJson()).toList();
    } catch (e) {
      debugPrint('Erro ao obter eventos: $e');
      return [];
    }
  }
}
