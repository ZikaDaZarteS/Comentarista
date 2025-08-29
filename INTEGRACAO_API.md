# 🔗 Integração com API do DataRodeo

## 📋 Visão Geral

Este documento descreve a implementação da integração entre o aplicativo **Comentarista** e a API do site [DataRodeo](https://datarodeo.com.br/mobile), permitindo que o app utilize todas as funcionalidades e recursos disponíveis no site.

## 🎯 Objetivos da Integração

- ✅ **Autenticação via API**: Login usando ID da rodada ou credenciais
- ✅ **Dados em Tempo Real**: Sincronização com eventos e rodadas ativas
- ✅ **Funcionalidades Completas**: Acesso a todos os recursos do DataRodeo
- ✅ **Compatibilidade**: Mantém funcionamento offline com dados locais
- ✅ **Interface Preservada**: Nenhuma tela foi alterada visualmente

## 🏗️ Arquitetura da Integração

### Estrutura de Arquivos

```
lib/
├── config/
│   └── api_config.dart          # Configurações centralizadas da API
├── services/
│   ├── api_service.dart         # Serviço base para requisições HTTP
│   ├── auth_service.dart        # Autenticação e gerenciamento de tokens
│   ├── data_rodeo_service.dart # Serviços específicos do DataRodeo
│   └── event_service.dart      # Serviço de eventos (atualizado)
└── screens/
    └── login_screen.dart        # Tela de login (integrada)
```

### Fluxo de Integração

1. **Configuração**: URLs e endpoints centralizados em `ApiConfig`
2. **Autenticação**: `AuthService` gerencia login e tokens JWT
3. **Comunicação**: `ApiService` faz requisições HTTP com tratamento de erros
4. **Dados**: `DataRodeoService` implementa endpoints específicos
5. **Compatibilidade**: `EventService` usa API como fallback para dados locais

## 🔐 Sistema de Autenticação

### Métodos de Login

#### 1. **Login por ID da Rodada** (Principal)
```dart
// Usuário insere ID da rodada
final response = await AuthService.login(roundId: "12345");
```

#### 2. **Login por Credenciais** (Fallback)
```dart
// Usuário insere usuário e senha
final response = await AuthService.login(
  username: "usuario",
  password: "senha"
);
```

### Gerenciamento de Tokens

- **Cache Local**: Token armazenado em `SharedPreferences`
- **Validação**: Verificação automática de validade
- **Renovação**: Refresh automático quando necessário
- **Segurança**: Limpeza automática no logout

## 🌐 Endpoints da API

### Autenticação
- `POST /auth/login` - Login com ID da rodada ou credenciais
- `POST /auth/logout` - Logout e limpeza de token
- `POST /auth/refresh` - Renovação de token
- `GET /auth/validate` - Validação de token
- `GET /auth/me` - Informações do usuário atual
- `GET /auth/current-round` - Rodada atual

### Eventos
- `GET /events` - Lista de eventos
- `GET /events/{id}` - Detalhes de um evento
- `GET /events/{id}/stages` - Etapas de um evento
- `GET /events/{id}/stats` - Estatísticas de um evento
- `GET /events/{id}/live` - Dados em tempo real
- `GET /events/search` - Busca de eventos

### Rodadas
- `GET /events/{event_id}/rounds` - Rodadas de um evento
- `GET /rounds/{id}` - Detalhes de uma rodada
- `POST /rounds` - Criação de rodada
- `PUT /rounds/{id}` - Atualização de rodada

### Rankings e Classificações
- `GET /events/{event_id}/rankings` - Ranking de um evento
- `GET /rankings/{id}` - Detalhes de um ranking

### Entidades
- `GET /animals` - Lista de animais
- `GET /competitors` - Lista de competidores
- `GET /tropeiros` - Lista de tropeiros
- `GET /judges` - Lista de juízes

## 📱 Funcionalidades Implementadas

### 1. **Login Inteligente**
- Tenta primeiro com ID da rodada
- Fallback para credenciais tradicionais
- Validação automática de tokens
- Tratamento de erros específicos

### 2. **Sincronização de Dados**
- Eventos em tempo real
- Rodadas e classificações
- Estatísticas atualizadas
- Busca e filtros

### 3. **Gestão de Estado**
- Cache local para dados offline
- Sincronização automática
- Fallback para dados locais
- Tratamento de erros de rede

### 4. **Funcionalidades Avançadas**
- Dados em tempo real
- Busca de eventos
- Filtros por etapa
- Rankings dinâmicos

## 🔄 Estratégia de Fallback

### 1. **Prioridade da API**
```dart
try {
  // Tenta usar a API primeiro
  final data = await DataRodeoService.getEvent(eventId);
  return data;
} catch (e) {
  // Se falhar, usa dados locais
  return await loadLocalData();
}
```

### 2. **Dados Locais**
- JSON local como backup
- Funcionalidades offline
- Cache de dados recentes
- Sincronização quando online

## 🛡️ Tratamento de Erros

### Tipos de Erro
- **401 Unauthorized**: Token inválido ou expirado
- **403 Forbidden**: Sem permissão para recurso
- **404 Not Found**: Recurso não encontrado
- **429 Rate Limit**: Limite de requisições excedido
- **500 Server Error**: Erro interno do servidor

### Estratégias de Recuperação
- **Retry Automático**: Tentativas múltiplas para erros temporários
- **Fallback Local**: Uso de dados locais em caso de falha
- **Cache Inteligente**: Armazenamento de dados válidos
- **Tratamento de Usuário**: Mensagens de erro amigáveis

## 📊 Monitoramento e Logs

### Logs de Sistema
```dart
print('Erro ao carregar dados da API: $e');
print('Usando dados locais como fallback');
print('Token renovado com sucesso');
```

### Métricas de Performance
- Tempo de resposta da API
- Taxa de sucesso das requisições
- Uso de cache vs. API
- Erros por endpoint

## 🚀 Como Usar

### 1. **Configuração Inicial**
```dart
// Importar serviços
import 'package:comentarista/services/auth_service.dart';
import 'package:comentarista/services/data_rodeo_service.dart';
```

### 2. **Login**
```dart
// Login com ID da rodada
final response = await AuthService.login(roundId: "12345");
if (response['success']) {
  // Login bem-sucedido
  Navigator.pushReplacementNamed(context, '/home');
}
```

### 3. **Buscar Dados**
```dart
// Buscar eventos
final events = await DataRodeoService.getEvents();

// Buscar rodadas de um evento
final rounds = await DataRodeoService.getEventRounds(eventId);

// Buscar ranking
final ranking = await DataRodeoService.getEventRanking(eventId);
```

### 4. **Logout**
```dart
// Logout e limpeza
await AuthService.logout();
```

## 🔧 Configuração

### URLs da API
```dart
// lib/config/api_config.dart
static const String baseUrl = 'https://datarodeo.com.br/api';
static const String mobileUrl = 'https://datarodeo.com.br/mobile';
```

### Timeouts e Retry
```dart
static const Duration connectionTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
static const int maxRetries = 3;
```

## 📱 Compatibilidade

### Plataformas Suportadas
- ✅ **Android**: API 21+
- ✅ **iOS**: 11.0+
- ✅ **Web**: Todos os navegadores modernos
- ✅ **Windows**: Windows 10+
- ✅ **macOS**: 10.14+

### Dependências
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.1
```

## 🧪 Testes

### Testes de Integração
- Autenticação com API real
- Validação de endpoints
- Tratamento de erros
- Fallback para dados locais

### Testes de Performance
- Tempo de resposta
- Uso de memória
- Cache efficiency
- Network resilience

## 🔮 Próximos Passos

### Funcionalidades Futuras
- [ ] **WebSocket**: Dados em tempo real
- [ ] **Push Notifications**: Alertas de eventos
- [ ] **Offline Sync**: Sincronização quando online
- [ ] **Analytics**: Métricas de uso
- [ ] **A/B Testing**: Testes de interface

### Melhorias Técnicas
- [ ] **Rate Limiting**: Controle de requisições
- [ ] **Retry Logic**: Lógica de retry inteligente
- [ ] **Background Sync**: Sincronização em background
- [ ] **Data Compression**: Compressão de dados
- [ ] **CDN Integration**: Distribuição de conteúdo

## 📞 Suporte

### Documentação da API
- **Site**: [https://datarodeo.com.br/mobile](https://datarodeo.com.br/mobile)
- **Documentação**: [docs/api/README.md](docs/api/README.md)
- **Status**: Monitoramento em tempo real

### Contato
- **Desenvolvimento**: Equipe Comentarista
- **API**: Suporte técnico DataRodeo
- **Issues**: GitHub repository

---

## ✨ Resumo

A integração com a API do DataRodeo foi implementada com sucesso, mantendo **100% da interface original** e adicionando funcionalidades robustas de:

- 🔐 **Autenticação segura** com JWT
- 🌐 **Comunicação em tempo real** com a API
- 📱 **Funcionalidades completas** do site
- 🔄 **Fallback inteligente** para dados locais
- 🛡️ **Tratamento robusto** de erros
- 📊 **Monitoramento** e logs detalhados

O aplicativo agora oferece uma experiência completa e integrada com o ecossistema DataRodeo, mantendo a familiaridade visual para os usuários existentes.
