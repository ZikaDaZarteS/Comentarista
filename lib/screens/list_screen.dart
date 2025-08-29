import 'package:flutter/material.dart';
import '../services/event_service.dart';
import 'competitor_history_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  int _selectedTabIndex = 0;
  List<Map<String, dynamic>> participants = [];
  Map<String, dynamic> eventData = {};
  bool isLoading = true;

  // ✅ CORREÇÃO: Definindo as abas baseadas nas companhias
  List<String> tabs = ['TODOS'];

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
      final companhias = await EventService.getCompanhias();

      setState(() {
        eventData = data;
        // ✅ Adicionar "TODOS" como primeira aba e depois as companhias
        tabs = ['TODOS', ...companhias];
        _loadParticipantsByCompanhia(tabs[_selectedTabIndex]);
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // ✅ Carregar participantes filtrados por companhia
  Future<void> _loadParticipantsByCompanhia(String companhia) async {
    if (eventData['round'] != null) {
      List<Map<String, dynamic>> companhiaParticipants;

      if (companhia == 'TODOS') {
        // ✅ Para "TODOS", mostrar todos os rounds
        companhiaParticipants = await EventService.getParticipantsByCompanhia(
            eventData['round'], '');
      } else {
        // ✅ Para companhias específicas, filtrar
        companhiaParticipants = await EventService.getParticipantsByCompanhia(
            eventData['round'], companhia);
      }

      setState(() {
        participants = companhiaParticipants;
      });
    }
  }

  // ✅ Mudança de aba com filtro
  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    _loadParticipantsByCompanhia(tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Cor exata da imagem
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
                    // Abas de navegação
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: tabs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final tab = entry.value;
                            final isSelected = index == _selectedTabIndex;

                            return Container(
                              margin: EdgeInsets.only(
                                  right: index < tabs.length - 1 ? 16 : 0),
                              child: GestureDetector(
                                onTap: () {
                                  _onTabChanged(index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(4),
                                    border: isSelected
                                        ? Border.all(
                                            color: Colors.blue, width: 1)
                                        : null,
                                    boxShadow: [
                                      // Neumorphism para todas as abas
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
                                  child: Text(
                                    tab,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Lista de cards
                    participants.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'Nenhum participante encontrado para esta etapa',
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
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: participants.length,
                            itemBuilder: (context, index) {
                              final participant = participants[index];

                              return GestureDetector(
                                onTap: () {
                                  // ✅ Navegar para tela de histórico do competidor
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CompetitorHistoryScreen(
                                        confrontation: participant,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A1A),
                                    borderRadius: BorderRadius.circular(8),
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
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        // Confronto principal
                                        Row(
                                          children: [
                                            // Seção esquerda - Touro
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF5C5C5C),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Image.asset(
                                                        'assets/images/touro.png',
                                                        width: 30,
                                                        height: 30,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    participant['animal'] ??
                                                        'BALADA',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '0.00',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Divisor central - X
                                            SizedBox(
                                              width: 60,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    'X',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Seção direita - Competidor
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 50,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                          0xFF5C5C5C),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Color(0xFF1A1A1A),
                                                      size: 30,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    participant['competitor'] ??
                                                        'DANIEL ALEXANDRE LOPES DOS SANTOS',
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '0.00',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
      ),
    );
  }
}
