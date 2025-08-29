import '../services/event_service.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/data_rodeo_service.dart';

class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();

  factory DependencyInjection() {
    return _instance;
  }

  DependencyInjection._internal();

  // Serviços singleton
  late final EventService eventService = EventService();
  late final AuthService authService = AuthService();
  late final ApiService apiService = ApiService();
  late final DataRodeoService dataRodeoService = DataRodeoService();

  // Inicialização dos serviços
  void initialize() {
    // Configurações iniciais se necessário
  }

  // Cleanup dos serviços
  void dispose() {
    ApiService.dispose();
  }
}
