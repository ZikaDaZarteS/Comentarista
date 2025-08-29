import 'package:flutter/material.dart';
import '../services/event_service.dart';

class TopScreen extends StatefulWidget {
  const TopScreen({super.key});

  @override
  State<TopScreen> createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen> {
  List<Map<String, dynamic>> topCia = [];
  List<Map<String, dynamic>> topBull = [];
  bool isLoading = true;

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
    _loadTopData();
  }

  Future<void> _loadTopData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await EventService.loadEventData();
      debugPrint('🔍 Dados carregados: ${data.keys.toList()}');

      // ✅ Carregar Top Cia (campo 'tropeiro')
      if (data['tropeiro'] != null) {
        final tropeiros = data['tropeiro'] as List<dynamic>;
        debugPrint('🔍 Tropeiros encontrados: ${tropeiros.length}');

        // Converter para lista de companhias
        topCia = tropeiros.map((tropeiro) {
          return {
            'position': tropeiro['posicao'] ?? 0,
            'name': tropeiro['tropeiro'] ?? '',
            'average': _parseNotaTotal(tropeiro['media']),
            'animals': tropeiro['qtde_animais'] ?? 0,
            'city': tropeiro['cidade'] ?? '',
          };
        }).toList();

        debugPrint('🔍 Top Cia carregado: ${topCia.length} itens');

        // Ordenar por posição
        topCia.sort(
            (a, b) => (a['position'] as int).compareTo(b['position'] as int));
      } else {
        debugPrint('❌ Campo tropeiro não encontrado');
      }

      // ✅ Carregar Top Bull (campo 'tropeiro' -> 'animal')
      if (data['tropeiro'] != null) {
        final tropeiros = data['tropeiro'] as List<dynamic>;
        final allAnimals = <Map<String, dynamic>>[];

        // Extrair todos os animais de todos os tropeiros
        for (final tropeiro in tropeiros) {
          if (tropeiro['animal'] != null) {
            final animals = tropeiro['animal'] as List<dynamic>;
            debugPrint(
                '🔍 Animais encontrados em ${tropeiro['tropeiro']}: ${animals.length}');
            for (final animal in animals) {
              allAnimals.add({
                'position': animal['posicao'] ?? 0,
                'name': animal['animal'] ?? '',
                'average': _parseNotaTotal(animal['media']),
                'exits': animal['saida'] ?? 0,
                'company': tropeiro['tropeiro'] ?? '',
              });
            }
          }
        }

        debugPrint('🔍 Total de animais: ${allAnimals.length}');

        // Ordenar por posição
        allAnimals.sort(
            (a, b) => (a['position'] as int).compareTo(b['position'] as int));
        topBull = allAnimals;

        debugPrint('🔍 Top Bull carregado: ${topBull.length} itens');
      } else {
        debugPrint('❌ Campo tropeiro não encontrado para Top Bull');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Erro ao carregar dados do top: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFCE1B2D),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Seção Top Cia
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Top Cia',
                  style: TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topCia.length,
                  itemBuilder: (context, index) {
                    final cia = topCia[index];
                    final position = cia['position'] as int;

                    Color borderColor;
                    Color numberColor;
                    if (position == 1) {
                      borderColor = const Color(0xFFFFD700); // Ouro
                      numberColor = const Color(0xFFFFD700);
                    } else if (position == 2) {
                      borderColor = const Color(0xFFC0C0C0); // Prata
                      numberColor = const Color(0xFFC0C0C0);
                    } else if (position == 3) {
                      borderColor = const Color(0xFFCD7F32); // Bronze
                      numberColor = const Color(0xFFCD7F32);
                    } else {
                      borderColor =
                          Colors.white; // Branco para 4ª posição em diante
                      numberColor = Colors.white;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                            color: Colors.white.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(-2, -2),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.59),
                            blurRadius: 8,
                            offset: const Offset(4, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Número da posição
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$position -',
                                style: TextStyle(
                                  color: numberColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Informações do lado esquerdo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cia['name'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    cia['city'] as String,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Informações do lado direito
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Média',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${cia['average']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Animais: ',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${cia['animals']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Seção Top Bull
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Top Bull',
                  style: TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topBull.length,
                  itemBuilder: (context, index) {
                    final bull = topBull[index];
                    final position = bull['position'] as int;

                    Color borderColor;
                    Color numberColor;
                    if (position == 1) {
                      borderColor = const Color(0xFFFFD700); // Ouro
                      numberColor = const Color(0xFFFFD700);
                    } else if (position == 2) {
                      borderColor = const Color(0xFFC0C0C0); // Prata
                      numberColor = const Color(0xFFC0C0C0);
                    } else if (position == 3) {
                      borderColor = const Color(0xFFCD7F32); // Bronze
                      numberColor = const Color(0xFFCD7F32);
                    } else {
                      borderColor =
                          Colors.white; // Branco para 4ª posição em diante
                      numberColor = Colors.white;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                            color: Colors.white.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(-2, -2),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.59),
                            blurRadius: 8,
                            offset: const Offset(4, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Número da posição
                            SizedBox(
                              width: 40,
                              child: Text(
                                '$position -',
                                style: TextStyle(
                                  color: numberColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Informações do lado esquerdo
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bull['name'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    bull['company'] as String,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Informações do lado direito
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Média',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${bull['average']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Saída: ',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${bull['exits']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40), // Espaço extra para evitar overflow
          ],
        ),
      ),
    );
  }
}
