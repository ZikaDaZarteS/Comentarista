import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../utils/constants.dart';
import '../utils/data_converters.dart';
import '../utils/dependency_injection.dart';

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
      final data = await EventService.loadEventData();
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
          return notaB
              .compareTo(notaA); // Ordem decrescente (maior nota primeiro)
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
      backgroundColor: AppColors.backgroundColor, // Mesma cor do fundo
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFCE1B2D),
                ),
              )
            : CustomScrollView(
                slivers: [
                  // ✅ AppBar que se move com o scroll
                  SliverAppBar(
                    floating: true, // Permite que o AppBar se mova com o scroll
                    pinned: false, // Não fica fixo no topo
                    backgroundColor:
                        AppColors.backgroundColor, // Mesma cor do fundo
                    elevation: 0,
                    expandedHeight: 60, // Altura do header
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color:
                              AppColors.backgroundColor, // Mesma cor do fundo
                        ),
                        child: Center(
                          child: Text(
                            // ✅ Etapa real do backend (round em execução)
                            'Etapa: $currentStage',
                            style: const TextStyle(
                              color: Color(0xFFCE1B2D), // Vermelho exato
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Lista de rounds
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: rounds.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  'Nenhum round encontrado para esta etapa',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final round = rounds[index];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  constraints: const BoxConstraints(
                                    minHeight:
                                        100, // Reduzido para evitar overflow
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .backgroundColor, // Mesma cor do fundo
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      // Ponto de luz (sombra interna clara)
                                      BoxShadow(
                                        color: Colors.white
                                            .withValues(alpha: 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(-2, -2),
                                        spreadRadius: 0,
                                      ),
                                      // Sombra escura
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // Número da posição
                                      Container(
                                        height: 100,
                                        alignment: Alignment.center,
                                        child: Text(
                                          // ✅ Posição na classificação (index + 1)
                                          '${index + 1} -',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'Montserrat',
                                            height: 1.0,
                                            letterSpacing: 0.0,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      // Informações do competidor e animal
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Competidor:',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              // ✅ Nome real do competidor do backend
                                              round['competidor'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'Animal:',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              // ✅ Nome real do animal do backend
                                              round['animal'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      // Nota com efeito neumorphism
                                      Container(
                                        width: 70,
                                        height: 60,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A1A1A),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: [
                                            // Ponto de luz (sombra interna clara)
                                            BoxShadow(
                                              color: Colors.white
                                                  .withValues(alpha: 0.08),
                                              blurRadius: 8,
                                              offset: const Offset(-2, -2),
                                              spreadRadius: 0,
                                            ),
                                            // Sombra escura
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.59),
                                              blurRadius: 8,
                                              offset: const Offset(4, 4),
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Nota',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              // ✅ Nota do round atual (campo 'nota')
                                              _parseNotaTotal(round['nota'])
                                                  .toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: rounds.length,
                            ),
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
