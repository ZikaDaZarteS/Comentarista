import 'package:flutter/material.dart';

class ConfrontationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> confrontation;

  const ConfrontationDetailScreen({
    super.key,
    required this.confrontation,
  });

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
          'Detalhes do Confronto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com informações básicas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFCE1B2D),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCE1B2D),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SEQ ${confrontation['seq'] ?? 'N/A'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      Text(
                        'Lado: ${confrontation['lado'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Etapa: ${confrontation['etapa'] ?? 'N/A'}',
                    style: const TextStyle(
                      color: Color(0xFFCE1B2D),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Confronto principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
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
              child: Row(
                children: [
                  // Seção esquerda - Touro
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/touro.png',
                          width: 60,
                          height: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          confrontation['animal'] ?? 'N/A',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${confrontation['animalScore'] ?? '0.00'}',
                          style: const TextStyle(
                            color: Color(0xFFCE1B2D),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divisor central - VS
                  SizedBox(
                    width: 60,
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCE1B2D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'VS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seção direita - Competidor
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 60,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          confrontation['competitor'] ?? 'N/A',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${confrontation['competitorScore'] ?? '0.00'}',
                          style: const TextStyle(
                            color: Color(0xFFCE1B2D),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informações detalhadas do round
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFCE1B2D),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações do Round',
                    style: TextStyle(
                      color: Color(0xFFCE1B2D),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid de informações
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Total',
                          '${confrontation['nota_total'] ?? '0.00'}',
                          const Color(0xFFCE1B2D),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Tempo',
                          '${confrontation['tempo'] ?? '0.00'}s',
                          Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'Bonus',
                          '${confrontation['bonus'] ?? '0.00'}',
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Nota',
                          '${confrontation['nota'] ?? '0.00'}',
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Informações adicionais
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
                  const Text(
                    'Informações Adicionais',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Cidade', confrontation['cidade'] ?? 'N/A'),
                  _buildInfoRow(
                      'Tropeiro', confrontation['cidade_tropeiro'] ?? 'N/A'),
                  _buildInfoRow(
                      'ID Animal', '${confrontation['id_animal'] ?? 'N/A'}'),
                  _buildInfoRow('ID Competidor',
                      '${confrontation['id_competidor'] ?? 'N/A'}'),
                  if (confrontation['cpf'] != null &&
                      confrontation['cpf'].toString().isNotEmpty)
                    _buildInfoRow('CPF', confrontation['cpf']),
                  if (confrontation['data_nascimento'] != null &&
                      confrontation['data_nascimento'].toString().isNotEmpty)
                    _buildInfoRow(
                        'Data Nascimento', confrontation['data_nascimento']),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color valueColor) {
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
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
