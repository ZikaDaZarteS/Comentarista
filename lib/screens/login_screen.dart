import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _roundIdController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Cor exata da imagem
      body: SafeArea(
        child: SingleChildScrollView(
          // Adiciona scroll para resolver overflow
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Logo do Touro - medidas exatas da imagem (237 x 272)
              SizedBox(
                width: 237,
                height: 272,
                child: SvgPicture.asset(
                  'assets/images/login.svg',
                  width: 237,
                  height: 272,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 160), // Aumentado para descer os campos

              // Campo ID da Rodada
              const SizedBox(
                width: 179, // Largura exata especificada
                height: 20, // Altura exata especificada
                child: Center(
                  // Centraliza verticalmente o texto
                  child: Text(
                    'Digite o ID da rodada',
                    textAlign: TextAlign.center, // Centraliza o texto
                    style: TextStyle(
                      color: Color(0xFFCE1B2D), // Cor exata da imagem
                      fontSize: 16,
                      fontWeight: FontWeight.w700, // Bold como na imagem
                      fontFamily: 'Montserrat',
                      height: 1.0, // 100% como na imagem
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: 316, // Largura exata da imagem
                height: 48, // Altura exata da imagem
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Mesma cor do fundo
                  borderRadius:
                      BorderRadius.circular(8), // Raio 8px como na imagem
                  boxShadow: [
                    // Neumorphism exato da imagem
                    BoxShadow(
                      color:
                          Colors.white.withValues(alpha: 0.08), // 8% opacidade
                      blurRadius: 8,
                      offset: const Offset(-2, -2),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: 0.59), // 59% opacidade
                      blurRadius: 8,
                      offset: const Offset(4, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _roundIdController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // Font-size exato especificado
                    fontWeight: FontWeight.w400, // Font-weight 400 especificado
                    fontFamily: 'Montserrat', // Font-family especificada
                    height: 1.0, // Line-height 100% especificado
                    letterSpacing: 0, // Letter-spacing 0% especificado
                  ),
                  decoration: const InputDecoration(
                    hintText: 'ID da rodada',
                    hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 16, // Font-size exato especificado
                      fontWeight:
                          FontWeight.w400, // Font-weight 400 especificado
                      fontFamily: 'Montserrat', // Font-family especificada
                      height: 1.0, // Line-height 100% especificado
                      letterSpacing: 0, // Letter-spacing 0% especificado
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: 24, // Reduzido pela metade (era 48px)
                      top: 14, // Centraliza verticalmente (middle)
                      right: 16,
                      bottom: 14,
                    ),
                  ),
                ),
              ),

              // Mensagem de erro
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Color(0xFFCE1B2D),
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 20),

              // Botão Entrar - medidas exatas da imagem (316 x 36)
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFCE1B2D), // Cor exata da imagem
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8), // Raio 8px como na imagem
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Manipula o processo de login
  Future<void> _handleLogin() async {
    final roundId = _roundIdController.text.trim();
    if (roundId.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, digite o ID da rodada';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Tenta fazer login com a API do DataRodeo
      final response = await AuthService.login(
        eventId: roundId,
      );

      if (response['success'] == true) {
        // Login bem-sucedido
        final eventData = response['data'];

        // Define o ID do evento atual para o serviço
        if (eventData?['event_id'] != null) {
          EventService.setCurrentEventId(eventData['event_id']);
        } else {
          // Se não tiver event_id na resposta, usa o roundId
          EventService.setCurrentEventId(roundId);
        }

        // Navega para a tela principal
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        // Login falhou
        setState(() {
          _errorMessage = response['message'] ?? 'Falha na autenticação';
        });
      }
    } on UnauthorizedException {
      setState(() {
        _errorMessage = 'ID da rodada inválido';
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão. Verifique sua internet.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _roundIdController.dispose();
    super.dispose();
  }
}
