import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import '../utils/data_converters.dart';
import '../utils/dependency_injection.dart';

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
      final data = await EventService.loadEventData();
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
          (a, b) => (b['points'] as double).compareTo(a['points'] as double));

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
          'diff': diff.toStringAsFixed(2),
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
      backgroundColor: const Color(0xFF1A1A1A), // Mesma cor do fundo
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFCE1B2D),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header com título
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A1A1A), // Mesma cor do fundo
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                // ✅ Nome real do evento do backend
                                eventData['evento'] ?? 'Classificação',
                                style: const TextStyle(
                                  color: Color(0xFFCE1B2D),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            onPressed: () {
                              // ✅ Recarregar dados do backend
                              _loadEventData();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Lista de classificações
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          rankings.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text(
                                      'Nenhuma classificação disponível',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: rankings.length,
                                  itemBuilder: (context, index) {
                                    final ranking = rankings[index];
                                    final position = ranking['position'] as int;

                                    // Cores baseadas na posição (Ouro, Prata, Bronze, Branco)
                                    Color borderColor;
                                    Color numberColor;
                                    if (position == 1) {
                                      borderColor =
                                          const Color(0xFFFFD700); // Ouro
                                      numberColor = const Color(0xFFFFD700);
                                    } else if (position == 2) {
                                      borderColor =
                                          const Color(0xFFC0C0C0); // Prata
                                      numberColor = const Color(0xFFC0C0C0);
                                    } else if (position == 3) {
                                      borderColor =
                                          const Color(0xFFCD7F32); // Bronze
                                      numberColor = const Color(0xFFCD7F32);
                                    } else {
                                      borderColor = Colors
                                          .white; // Branco para 4ª posição em diante
                                      numberColor = Colors.white;
                                    }

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.only(
                                          left: 8,
                                          top: 8,
                                          right: 16,
                                          bottom: 8),
                                      height:
                                          80, // Altura fixa para todos os cards
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A1A1A),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border(
                                          left: BorderSide(
                                            color: borderColor,
                                            width: 4,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white
                                                .withValues(alpha: 0.08),
                                            blurRadius: 8,
                                            offset: const Offset(-2, -2),
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.59),
                                            blurRadius: 8,
                                            offset: const Offset(4, 4),
                                            spreadRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          // Número da posição
                                          SizedBox(
                                            width: 50,
                                            child: Text(
                                              '$position -',
                                              style: TextStyle(
                                                color: numberColor,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Montserrat',
                                                height: 1.0,
                                                letterSpacing: 0.0,
                                              ),
                                            ),
                                          ),

                                          // Informações do lado esquerdo
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  ranking['name'] as String,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  ranking['cidade'] as String,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Informações do lado direito
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                'Pontos',
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 11,
                                                ),
                                              ),
                                              Text(
                                                // ✅ Pontuação real do backend
                                                ranking['points'].toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                // ✅ Diferença real para o líder
                                                'Dif. Líder: ${ranking['diff']}',
                                                style: TextStyle(
                                                  color: Colors.grey[400],
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
