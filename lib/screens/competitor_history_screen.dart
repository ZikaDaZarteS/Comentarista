import 'package:flutter/material.dart';
import '../services/event_service.dart';

class CompetitorHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> confrontation;

  const CompetitorHistoryScreen({
    super.key,
    required this.confrontation,
  });

  @override
  State<CompetitorHistoryScreen> createState() =>
      _CompetitorHistoryScreenState();
}

class _CompetitorHistoryScreenState extends State<CompetitorHistoryScreen> {
  bool _isCompetitorTab = true; // true = Competidor, false = Animal
  List<Map<String, dynamic>> _competitorRounds = [];
  List<Map<String, dynamic>> _animalRounds = [];
  double _totalScore = 0.0;
  double _difference = 0.0;
  bool _isLoading = true;

  // ✅ Helper CIRÚRGICO para converter notas (trata Int32 e Decimal)
  double _parseNotaTotal(dynamic notaTotal) {
    if (notaTotal == null) return 0.0;

    // Se já é um número, converte diretamente
    if (notaTotal is num) {
      return notaTotal.toDouble();
    }

    // Se é string, trata vírgula como separador decimal
    final notaStr = notaTotal.toString().replaceAll(',', '.');
    return double.tryParse(notaStr) ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carrega todos os dados do evento
      final eventData = await EventService.loadEventData();

      if (eventData['round'] != null && eventData['round'] is List) {
        final allRounds = eventData['round'] as List<dynamic>;

        // Filtra rounds do competidor
        final competitorName = widget.confrontation['competidor'] ?? '';
        final competitorRounds = allRounds
            .where((round) => round['competidor'] == competitorName)
            .cast<Map<String, dynamic>>()
            .toList();

        // Filtra rounds do animal
        final animalName = widget.confrontation['animal'] ?? '';
        final animalRounds = allRounds
            .where((round) => round['animal'] == animalName)
            .cast<Map<String, dynamic>>()
            .toList();

        // Calcula pontuação total do competidor
        _totalScore = competitorRounds.fold(0.0, (sum, round) {
          final total = _parseNotaTotal(round['nota_total']);
          return sum + total;
        });

        // Calcula diferença (assumindo que o líder tem a maior pontuação)
        final allCompetitorScores = <double>[];
        for (final round in allRounds) {
          final competitor = round['competidor']?.toString() ?? '';
          if (competitor.isNotEmpty) {
            final existingIndex = allCompetitorScores.indexWhere((score) =>
                allRounds[allCompetitorScores.indexOf(score)]['competidor'] ==
                competitor);

            if (existingIndex == -1) {
              allCompetitorScores.add(_parseNotaTotal(round['nota_total']));
            } else {
              allCompetitorScores[existingIndex] +=
                  _parseNotaTotal(round['nota_total']);
            }
          }
        }

        if (allCompetitorScores.isNotEmpty) {
          allCompetitorScores.sort((a, b) => b.compareTo(a));
          final leaderScore = allCompetitorScores.first;
          _difference = leaderScore - _totalScore;
        }

        setState(() {
          _competitorRounds = competitorRounds;
          _animalRounds = animalRounds;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar histórico: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Histórico',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFCE1B2D),
              ),
            )
          : Column(
              children: [
                // Abas Competidor/Animal
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCompetitorTab = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isCompetitorTab
                                  ? const Color(0xFFCE1B2D)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Competidor',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isCompetitorTab
                                    ? Colors.white
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                decoration: _isCompetitorTab
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                decorationColor: _isCompetitorTab
                                    ? Colors.white
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isCompetitorTab = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isCompetitorTab
                                  ? Colors.transparent
                                  : const Color(0xFFCE1B2D),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Animal',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isCompetitorTab
                                    ? Colors.white
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                decoration: _isCompetitorTab
                                    ? TextDecoration.none
                                    : TextDecoration.underline,
                                decorationColor: _isCompetitorTab
                                    ? Colors.transparent
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Conteúdo baseado na aba selecionada
                Expanded(
                  child: _isCompetitorTab
                      ? _buildCompetitorContent()
                      : _buildAnimalContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildCompetitorContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do competidor
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.confrontation['competidor'] ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.confrontation['cidade'] ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildScoreCard(
                          'Pontuação',
                          _totalScore.toStringAsFixed(0),
                          const Color(0xFFCE1B2D)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildScoreCard(
                          'Dif', _difference.toStringAsFixed(1), Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Histórico de rounds
          ..._competitorRounds.map((round) => _buildRoundCard(round)),
        ],
      ),
    );
  }

  Widget _buildAnimalContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informações do animal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.confrontation['animal'] ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Animal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildScoreCard(
                          'Pontuação',
                          _totalScore.toStringAsFixed(0),
                          const Color(0xFFCE1B2D)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildScoreCard(
                          'Dif', _difference.toStringAsFixed(1), Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Histórico de rounds do animal
          ..._animalRounds.map((round) => _buildRoundCard(round)),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFCE1B2D),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundCard(Map<String, dynamic> round) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etapa
          Row(
            children: [
              const Text(
                'Etapa',
                style: TextStyle(
                  color: Color(0xFFCE1B2D),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(width: 8),
              Text(
                round['etapa'] ?? 'N/A',
                style: const TextStyle(
                  color: Color(0xFFCE1B2D),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Informações do round
          _buildInfoRow('Animal', round['animal'] ?? 'N/A'),
          _buildInfoRow(
              'Nota do competidor', '${round['nota_competidor'] ?? '0'}'),
          _buildInfoRow('Nota Animal', '${round['nota_animal'] ?? '0'}'),
          _buildInfoRow('Total', '${round['nota_total'] ?? '0'}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}
