import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../utils/data_converters.dart';
import '../../../utils/constants.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({super.key});

  @override
  State<ClassificationScreen> createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  List<Map<String, dynamic>> rankings = [];
  Map<String, dynamic> eventData = {};
  bool isLoading = true;

  // ✅ Helper CIRÚRGICO para converter notas (trata Int32 e Decimal)
  double _parseNotaTotal(dynamic notaTotal) {
    return DataConverters.parseNotaTotal(notaTotal);
  }

  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  // ✅ Carregar dados reais do backend
  Future<void> _loadEventData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Usa a nova arquitetura através da injeção de dependências
      final di = DependencyInjection();
      final data = await di.eventRepository.loadEventData();
      setState(() {
        eventData = data;
        _loadRankings();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Carregar rankings baseados no backend (campo 'rank')
  Future<void> _loadRankings() async {
    if (eventData['rank'] != null) {
      final ranks = eventData['rank'] as List<dynamic>;

      // Agrupar por competidor e calcular pontuação total
      final Map<String, Map<String, dynamic>> competitorScores = {};

      for (final rank in ranks) {
        final competitorName = rank['competidor'] ?? '';
        final score = _parseNotaTotal(rank['nota']);
        final cidade = rank['cidade'] ?? '';

        if (competitorName.isNotEmpty) {
          if (competitorScores.containsKey(competitorName)) {
            competitorScores[competitorName]!['points'] += score;
            competitorScores[competitorName]!['rounds'] += 1;
          } else {
            competitorScores[competitorName] = {
              'name': competitorName,
              'cidade': cidade,
              'points': score,
              'rounds': 1,
            };
          }
        }
      }

      // Converter para lista e ordenar por pontuação
      final rankingsList = competitorScores.values.toList();
      rankingsList.sort(
        (a, b) => (b['points'] as double).compareTo(a['points'] as double),
      );

      // Calcular diferença para o líder
      final leaderScore = rankingsList.isNotEmpty
          ? rankingsList.first['points'] as double
          : 0.0;

      final finalRankings = rankingsList.asMap().entries.map((entry) {
        final index = entry.key;
        final ranking = entry.value;
        final points = ranking['points'] as double;
        final diff = index == 0 ? 0.0 : leaderScore - points;

        return {
          'position': index + 1,
          'name': ranking['name'],
          'cidade': ranking['cidade'],
          'points': points,
          'rounds': ranking['rounds'],
          'diff': diff,
        };
      }).toList();

      setState(() {
        rankings = finalRankings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      appBar: AppBar(
        backgroundColor: const Color(AppConstants.backgroundColorValue),
        elevation: 0,
        title: const Text(
          'Classificação Geral',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFCE1B2D)),
            )
          : Column(
              children: [
                // Header com estatísticas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(AppConstants.cardBackgroundColorValue),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${rankings.length} Competidores',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Classificação por pontuação total',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Lista de rankings
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: rankings.length,
                    itemBuilder: (context, index) {
                      final ranking = rankings[index];
                      final position = ranking['position'] as int;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(
                            AppConstants.cardBackgroundColorValue,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: position <= 3
                                ? const Color(AppConstants.primaryColorValue)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Posição
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: position <= 3
                                    ? const Color(
                                        AppConstants.primaryColorValue,
                                      )
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Center(
                                child: Text(
                                  '$position',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Informações do competidor
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ranking['name'] ?? 'N/A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ranking['cidade'] ?? 'N/A',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${ranking['rounds']} rounds',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Pontuação e diferença
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${ranking['points'].toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: position <= 3
                                        ? const Color(
                                            AppConstants.primaryColorValue,
                                          )
                                        : Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (position > 1)
                                  Text(
                                    '-${ranking['diff'].toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                    ),
                                  )
                                else
                                  const Text(
                                    'Líder',
                                    style: TextStyle(
                                      color: Color(0xFFCE1B2D),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
