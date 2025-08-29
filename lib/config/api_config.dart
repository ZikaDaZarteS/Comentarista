class ApiConfig {
  // URLs da API
  static const String baseUrl = 'https://datarodeo.com.br/api';
  static const String mobileUrl = 'https://datarodeo.com.br/mobile';
  static const String webUrl = 'https://datarodeo.com.br';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Rate Limiting
  static const int maxRequestsPerHour = 1000;
  static const Duration rateLimitWindow = Duration(hours: 1);

  // Retry Configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Cache Configuration
  static const Duration tokenCacheDuration = Duration(hours: 24);
  static const Duration dataCacheDuration = Duration(minutes: 5);

  // Headers padrão
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Comentarista/1.0.0',
    'Accept-Language': 'pt-BR,pt;q=0.9,en;q=0.8',
  };

  // Endpoints da API
  static const Map<String, Map<String, String>> endpoints = {
    'auth': {
      'login': '/auth/login',
      'logout': '/auth/logout',
      'refresh': '/auth/refresh',
      'validate': '/auth/validate',
      'me': '/auth/me',
      'currentRound': '/auth/current-round',
    },
    'events': {
      'list': '/events',
      'get': '/events/{id}',
      'create': '/events',
      'update': '/events/{id}',
      'delete': '/events/{id}',
      'search': '/events/search',
      'stages': '/events/{id}/stages',
      'stats': '/events/{id}/stats',
      'live': '/events/{id}/live',
    },
    'rounds': {
      'list': '/events/{event_id}/rounds',
      'get': '/rounds/{id}',
      'create': '/rounds',
      'update': '/rounds/{id}',
      'delete': '/rounds/{id}',
    },
    'rankings': {
      'list': '/events/{event_id}/rankings',
      'get': '/rankings/{id}',
    },
    'animals': {
      'list': '/animals',
      'get': '/animals/{id}',
      'create': '/animals',
      'update': '/animals/{id}',
      'delete': '/animals/{id}',
    },
    'competitors': {
      'list': '/competitors',
      'get': '/competitors/{id}',
      'create': '/competitors',
      'update': '/competitors/{id}',
      'delete': '/competitors/{id}',
    },
    'tropeiros': {
      'list': '/tropeiros',
      'get': '/tropeiros/{id}',
      'create': '/tropeiros',
      'update': '/tropeiros/{id}',
      'delete': '/tropeiros/{id}',
    },
    'judges': {
      'list': '/judges',
      'get': '/judges/{id}',
      'create': '/judges',
      'update': '/judges/{id}',
      'delete': '/judges/{id}',
    },
  };

  // Códigos de erro da API
  static const Map<String, String> errorCodes = {
    'VALIDATION_ERROR': 'Erro de validação dos dados',
    'NOT_FOUND': 'Recurso não encontrado',
    'UNAUTHORIZED': 'Usuário não autenticado',
    'FORBIDDEN': 'Usuário sem permissão',
    'INTERNAL_ERROR': 'Erro interno do sistema',
    'RATE_LIMIT_EXCEEDED': 'Limite de requisições excedido',
    'INVALID_ROUND_ID': 'ID da rodada inválido',
    'EVENT_NOT_FOUND': 'Evento não encontrado',
    'ROUND_NOT_FOUND': 'Rodada não encontrada',
    'COMPETITOR_NOT_FOUND': 'Competidor não encontrado',
    'ANIMAL_NOT_FOUND': 'Animal não encontrado',
  };

  // Mensagens de erro padrão
  static const Map<String, String> defaultErrorMessages = {
    'network_error': 'Erro de conexão. Verifique sua internet.',
    'timeout_error': 'Tempo limite excedido. Tente novamente.',
    'server_error': 'Erro no servidor. Tente novamente mais tarde.',
    'unknown_error': 'Erro desconhecido. Tente novamente.',
    'auth_error': 'Erro de autenticação. Verifique suas credenciais.',
    'permission_error': 'Sem permissão para acessar este recurso.',
  };

  /// Obtém um endpoint específico
  static String getEndpoint(String category, String action) {
    return endpoints[category]?[action] ?? '';
  }

  /// Obtém uma mensagem de erro por código
  static String getErrorMessage(String code) {
    return errorCodes[code] ?? defaultErrorMessages['unknown_error']!;
  }

  /// Obtém uma mensagem de erro padrão por tipo
  static String getDefaultErrorMessage(String type) {
    return defaultErrorMessages[type] ?? defaultErrorMessages['unknown_error']!;
  }

  /// Constrói uma URL completa para um endpoint
  static String buildUrl(String endpoint, {Map<String, String>? pathParams}) {
    String url = '$baseUrl$endpoint';

    if (pathParams != null) {
      pathParams.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }

    return url;
  }
}
