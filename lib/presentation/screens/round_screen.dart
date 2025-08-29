import 'package:flutter/material.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../utils/data_converters.dart';
import '../../../utils/constants.dart';

class RoundScreen extends StatefulWidget {
  const RoundScreen({super.key});

  @override
  State<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends State<RoundScreen> {
  List<Map<String, dynamic>> rounds = [];
  Map<String, dynamic> eventData = {};
  bool isLoading = true;
  String currentStage = ''; // Será definido automaticamente

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
        _loadCurrentRound();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Carregar automaticamente o round em execução
  void _loadCurrentRound() {
    if (eventData['round'] != null) {
      final allRounds = eventData['round'] as List<dynamic>;

      // Encontrar o round mais recente (assumindo que é o em execução)
      if (allRounds.isNotEmpty) {
        // Ordenar por ID para pegar o mais recente
        allRounds.sort((a, b) => (b['id'] ?? 0).compareTo(a['id'] ?? 0));
        final currentRound = allRounds.first;
        final currentStageName = currentRound['etapa'] as String;

        // Filtrar rounds da etapa atual
        final stageRounds = allRounds
            .where((round) => round['etapa'] == currentStageName)
            .cast<Map<String, dynamic>>()
            .toList();

        // ✅ Ordenar por nota do round atual (maior nota primeiro - classificação)
        stageRounds.sort((a, b) {
          // ✅ Conversão CIRÚRGICA: usa campo 'nota' (round atual) em vez de 'nota_total'
          final notaA = _parseNotaTotal(a['nota']);
          final notaB = _parseNotaTotal(b['nota']);
          return notaB.compareTo(
            notaA,
          ); // Ordem decrescente (maior nota primeiro)
        });

        setState(() {
          currentStage = currentStageName;
          rounds = stageRounds;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColorValue),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFCE1B2D)),
              )
            : Column(
                children: [
                  // Header com informações da etapa
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
                          currentStage.isNotEmpty
                              ? currentStage
                              : 'Etapa Atual',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${rounds.length} competidores',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Lista de rounds
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: rounds.length,
                      itemBuilder: (context, index) {
                        final round = rounds[index];
                        final position = index + 1;

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
                                      round['competidor'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      round['cidade'] ?? 'N/A',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          'Animal: ',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                        Text(
                                          round['animal'] ?? 'N/A',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Montserrat',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Nota do round
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _parseNotaTotal(
                                      round['nota'],
                                    ).toStringAsFixed(1),
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
                                  Text(
                                    'Nota',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
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
      ),
    );
  }
}
