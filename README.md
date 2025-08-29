<<<<<<< HEAD
# 🏆 Sistema Comentarista - App Flutter

## 📱 Visão Geral
O **Sistema Comentarista** é uma aplicação móvel Flutter para gerenciamento de rodeios e competições de montaria. O app consome uma API externa (DataRodeo) e oferece uma interface moderna para acompanhar eventos em tempo real.

## 🏗️ Arquitetura do Sistema

### **Frontend (Flutter)**
- **Framework**: Flutter 3.0+ com Dart
- **Estado**: Provider para gerenciamento de estado
- **Navegação**: Bottom Navigation + Rotas nomeadas
- **UI**: Material Design 3 com tema escuro personalizado

### **Backend (API Externa)**
- **Serviço Principal**: DataRodeo API (`https://datarodeo.com.br/api`)
- **Autenticação**: JWT com refresh tokens
- **Formato**: REST API com JSON
- **Cache**: Local com SharedPreferences

### **Estrutura de Dados**
- **Eventos**: Rodeios e competições
- **Rounds**: Rodadas de montaria
- **Rankings**: Classificações por pontuação
- **Participantes**: Competidores, animais e tropeiros

## 🎯 Telas e Funcionalidades

### **1. 🔐 Tela de Login** (`login_screen.dart`)
- **Função**: Autenticação via ID do evento
- **Características**:
  - Logo do touro em vermelho
  - Campo para ID da rodada
  - Validação de entrada
  - Integração com API DataRodeo

### **2. 🏆 Tela de Classificação** (`classification_screen.dart`)
- **Função**: Ranking dos competidores
- **Características**:
  - Lista ordenada por pontuação
  - Cores diferenciadas por posição:
    - 🥇 1º lugar: Amarelo (`#FFD700`)
    - 🥈 2º-3º lugar: Laranja (`#FF8C00`)
    - 🥉 Demais: Branco
  - Diferença de pontos para o líder
  - Dados em tempo real da API

### **3. 📋 Tela de Lista** (`list_screen.dart`)
- **Função**: Visualização de rodadas por etapa
- **Características**:
  - Abas filtradas: TODOS, CIA. 38, CIA FORMAÇÃO
  - Cards com animal vs competidor
  - Pontuações individuais
  - Filtros por companhia e etapa

### **4. 🌟 Tela Top** (`top_screen.dart`)
- **Função**: Rankings por categoria
- **Características**:
  - **Top Cia**: Ranking das empresas tropeiras
  - **Top Bull**: Ranking dos melhores touros
  - Estatísticas e médias
  - Cores diferenciadas por posição

### **5. 🐂 Tela Round** (`round_screen.dart`)
- **Função**: Detalhes das rodadas
- **Características**:
  - Cabeçalho com etapa atual
  - Lista de rodadas com posições
  - Informações de competidor e animal
  - Configurações da etapa

### **6. 📊 Tela de Histórico** (`competitor_history_screen.dart`)
- **Função**: Histórico de performance
- **Características**:
  - Dados históricos por competidor
  - Performance por evento
  - Estatísticas de pontuação

### **7. ⚔️ Tela de Confronto** (`confrontation_detail_screen.dart`)
- **Função**: Detalhes de confrontos
- **Características**:
  - Informações detalhadas da rodada
  - Pontuações dos juízes
  - Tempo de montaria

## 🔧 Estrutura Técnica

### **Arquitetura de Pastas**
```
lib/
├── main.dart                          # Ponto de entrada
├── config/
│   └── api_config.dart               # Configuração da API
├── models/
│   └── evento.dart                   # Modelos de dados
├── screens/                          # Telas da aplicação
│   ├── login_screen.dart
│   ├── classification_screen.dart
│   ├── list_screen.dart
│   ├── top_screen.dart
│   ├── round_screen.dart
│   ├── competitor_history_screen.dart
│   └── confrontation_detail_screen.dart
├── services/                         # Serviços de negócio
│   ├── api_service.dart             # Cliente HTTP principal
│   ├── auth_service.dart            # Autenticação
│   ├── event_service.dart           # Lógica de eventos
│   └── data_rodeo_service.dart     # Integração com API externa
├── providers/                        # Gerenciamento de estado
├── widgets/                          # Componentes reutilizáveis
└── utils/                           # Utilitários
```

### **Serviços Principais**

#### **ApiService** (`api_service.dart`)
- **Responsabilidade**: Cliente HTTP centralizado
- **Funcionalidades**:
  - Gerenciamento de tokens JWT
  - Headers padrão para todas as requisições
  - Tratamento de erros HTTP
  - Cache de autenticação
  - Rate limiting e retry logic

#### **DataRodeoService** (`data_rodeo_service.dart`)
- **Responsabilidade**: Integração com API externa
- **Endpoints principais**:
  - `/events` - Listagem de eventos
  - `/events/{id}/rounds` - Rodadas do evento
  - `/events/{id}/rankings` - Rankings
  - `/animals`, `/competitors`, `/tropeiros`

#### **EventService** (`event_service.dart`)
- **Responsabilidade**: Lógica de negócio dos eventos
- **Funcionalidades**:
  - Carregamento de dados do evento
  - Filtros por etapa e companhia
  - Cálculo de estatísticas
  - Fallback para dados locais

## 🌐 Integração com API Externa

### **DataRodeo API**
- **Base URL**: `https://datarodeo.com.br/api`
- **Autenticação**: JWT Bearer Token
- **Rate Limit**: 1000 requisições/hora
- **Timeout**: 30 segundos

### **Endpoints Principais**
```yaml
Eventos:
  - GET /events - Lista eventos
  - GET /events/{id} - Detalhes do evento
  - GET /events/{id}/stages - Etapas disponíveis

Rodadas:
  - GET /events/{id}/rounds - Rodadas do evento
  - GET /rounds/{id} - Detalhes da rodada

Rankings:
  - GET /events/{id}/rankings - Ranking completo
  - GET /events/{id}/stats - Estatísticas

Participantes:
  - GET /animals - Lista de animais
  - GET /competitors - Lista de competidores
  - GET /tropeiros - Lista de tropeiros
```

### **Fluxo de Dados**
1. **Login** → Validação do ID do evento
2. **Carregamento** → Busca dados da API DataRodeo
3. **Cache** → Armazenamento local para performance
4. **Atualização** → Sincronização em tempo real
5. **Fallback** → Dados locais em caso de falha

## 🎨 Design System

### **Paleta de Cores**
```dart
// Cores principais
primary: #E53E3E        // Vermelho principal
background: #1A1A1A     // Fundo escuro
surface: #2A2A2A        // Superfície dos cards
text: #FFFFFF          // Texto branco

// Cores de ranking
gold: #FFD700          // 1º lugar
silver: #FF8C00        // 2º-3º lugar
bronze: #CD853F        // 4º-5º lugar
```

### **Tipografia**
- **Títulos**: 24px, bold, branco
- **Subtítulos**: 20px, semibold, vermelho
- **Texto**: 16px, regular, branco
- **Legendas**: 14px, light, cinza

### **Componentes**
- **Cards**: Bordas arredondadas, sombras sutis
- **Botões**: Gradientes, estados hover/active
- **Inputs**: Bordas destacadas, validação visual
- **Listas**: Separadores, indicadores de scroll

## 📱 Navegação e UX

### **Bottom Navigation**
1. **🐂 Round** - Rodadas atuais
2. **🏆 Classificação** - Rankings
3. **📋 Lista** - Visualização geral
4. **⭐ Top** - Rankings por categoria
5. **👤 Perfil** - Configurações

### **Padrões de Navegação**
- **Stack Navigation** para telas de detalhes
- **Tab Navigation** para categorias principais
- **Drawer Navigation** para menu lateral
- **Deep Linking** para compartilhamento

### **Estados da Interface**
- **Loading**: Indicadores de carregamento
- **Empty**: Estados vazios com CTAs
- **Error**: Tratamento de erros amigável
- **Success**: Confirmações visuais

## 🔒 Segurança e Autenticação

### **JWT Token Management**
- **Access Token**: Validade de 1 hora
- **Refresh Token**: Validade de 24 horas
- **Auto-refresh**: Renovação automática
- **Secure Storage**: Armazenamento criptografado

### **Validação de Dados**
- **Input Sanitization**: Limpeza de dados de entrada
- **Type Safety**: Validação de tipos Dart
- **API Validation**: Validação no backend
- **Error Handling**: Tratamento robusto de erros

## 📊 Performance e Otimização

### **Estratégias de Cache**
- **API Cache**: Dados em memória por 5 minutos
- **Image Cache**: Cache de imagens e ícones
- **State Cache**: Persistência de estado da aplicação
- **Offline Support**: Funcionalidade offline básica

### **Otimizações**
- **Lazy Loading**: Carregamento sob demanda
- **Pagination**: Paginação de listas grandes
- **Image Optimization**: Compressão e redimensionamento
- **Memory Management**: Gerenciamento eficiente de memória

## 🧪 Testes e Qualidade

### **Tipos de Testes**
- **Unit Tests**: Testes de lógica de negócio
- **Widget Tests**: Testes de componentes UI
- **Integration Tests**: Testes de fluxos completos
- **API Tests**: Testes de integração com backend

### **Ferramentas de Qualidade**
- **Linting**: Análise estática de código
- **Formatting**: Formatação automática
- **Coverage**: Cobertura de testes
- **Performance**: Análise de performance

## 🚀 Deploy e Distribuição

### **Android**
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Assinatura
flutter build apk --release --build-number=1.0.0
```

### **iOS**
```bash
# Build iOS
flutter build ios --release

# Archive
flutter build ipa --release
```

### **Web**
```bash
# Build Web
flutter build web --release

# Deploy
flutter deploy
```

## 📈 Roadmap e Próximos Passos

### **Fase 1: Estabilização** ✅
- [x] Interface básica implementada
- [x] Integração com API externa
- [x] Sistema de autenticação
- [x] Navegação entre telas

### **Fase 2: Funcionalidades Avançadas** 🔄
- [ ] Notificações push
- [ ] Modo offline completo
- [ ] Sincronização em tempo real
- [ ] Relatórios e exportação

### **Fase 3: Backend Próprio** 📋
- [ ] Desenvolvimento de backend próprio
- [ ] Migração gradual da API externa
- [ ] Funcionalidades customizadas
- [ ] Escalabilidade e performance

## 🤝 Contribuição

### **Como Contribuir**
1. **Fork** o repositório
2. **Crie** uma branch para sua feature
3. **Implemente** as mudanças
4. **Teste** extensivamente
5. **Envie** um Pull Request

### **Padrões de Código**
- **Dart Style Guide**: Seguir convenções Dart
- **Flutter Best Practices**: Usar padrões Flutter
- **Documentação**: Comentar código complexo
- **Testes**: Manter cobertura alta

## 📞 Suporte e Contato

### **Canais de Suporte**
- **Email**: suporte@comentarista.com
- **Documentação**: [docs.comentarista.com](https://docs.comentarista.com)
- **Issues**: [GitHub Issues](https://github.com/comentarista/issues)
- **Discord**: [Comunidade Comentarista](https://discord.gg/comentarista)

### **Equipe de Desenvolvimento**
- **Tech Lead**: [Nome do Tech Lead]
- **Mobile Dev**: [Nome do Dev Mobile]
- **Backend Dev**: [Nome do Dev Backend]
- **UI/UX Designer**: [Nome do Designer]

## 📄 Licença

Este projeto está sob a licença **MIT**. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

**🏆 Sistema Comentarista**  
**📱 Versão**: 1.0.0  
**🔄 Última atualização**: Janeiro 2025  
**🚀 Desenvolvido com Flutter**  

*Transformando a gestão de rodeios em uma experiência digital moderna e eficiente.*

=======
# Comentarista
App da empresa que presto serviço
>>>>>>> c50715cb3e504dc20cc48af36c9baebdb342f153
