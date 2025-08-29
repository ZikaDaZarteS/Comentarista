# 🔍 CHECKLIST DE REVISÃO - IDs do DataRodeo no Login

## 📋 **RESUMO EXECUTIVO**

Este documento contém o checklist completo para revisar e garantir que o app **Comentarista** esteja funcionando corretamente com os IDs do DataRodeo no sistema de login.

---

## ✅ **1. FORMATO DO ID**

### **Verificações Necessárias:**
- [ ] **ID corresponde exatamente** ao ID do evento no site DataRodeo
- [ ] **Exemplos válidos**: "86", "130", "B1F", "125", "128"
- [ ] **Sem espaços extras** antes ou depois do ID
- [ ] **Sem diferenças** entre maiúsculas/minúsculas
- [ ] **Sem caracteres inválidos** ou especiais

### **IDs Conhecidos para Teste:**
```dart
// IDs VÁLIDOS (Status 200)
"86"    → EXPOFAR FARTURA ST
"B1F"   → ENGENHO RODEO FEST  
"125"   → SANTA BRANCA RODEO FEST LNR
"128"   → TESTE

// IDs INVÁLIDOS (Status 400)
"96"    → "Id inválido"
"999"   → "Id inválido"
"130"   → "Id inválido" (aparece no site mas não é válido para API mobile)
```

---

## 🌐 **2. ENDPOINT E URL CORRETA**

### **URL de Requisição:**
```dart
// ✅ CORRETO
final url = 'https://datarodeo.com.br/api/mobile?id=$eventId';

// ❌ INCORRETO
final url = 'https://datarodeo.com.br/api/events/$eventId';
final url = 'https://datarodeo.com.br/mobile?id=$eventId';
final url = 'https://datarodeo.com.br/api/event/$eventId';
```

### **Verificações:**
- [ ] **URL base**: `https://datarodeo.com.br`
- [ ] **Endpoint**: `/api/mobile`
- [ ] **Parâmetro**: `?id=ID_DO_EVENTO`
- [ ] **Método HTTP**: `GET`
- [ ] **URL completa**: `https://datarodeo.com.br/api/mobile?id=86`

---

## 📡 **3. HEADERS HTTP CORRETOS**

### **Headers Obrigatórios:**
```dart
final headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'User-Agent': 'Comentarista/1.0.0'
};
```

### **Verificações:**
- [ ] **Content-Type**: `application/json`
- [ ] **Accept**: `application/json`
- [ ] **User-Agent**: `Comentarista/1.0.0` (ou equivalente)
- [ ] **Sem headers desnecessários** que possam causar conflito
- [ ] **Headers consistentes** em todas as requisições

---

## 📊 **4. TRATAMENTO DA RESPOSTA**

### **Status 200 - Sucesso:**
```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  
  // ✅ Verificar dados essenciais
  final hasEvento = data['evento'] != null;
  final hasRound = data['round'] != null && data['round'] is List;
  final hasCompetitors = hasRound && (data['round'] as List).isNotEmpty;
  
  if (hasEvento && hasRound) {
    // ID válido - prosseguir com login
    return {'success': true, 'data': data};
  }
}
```

### **Status 400 - ID Inválido:**
```dart
} else if (response.statusCode == 400) {
  final errorData = jsonDecode(response.body);
  final message = errorData['message'] ?? 'ID inválido';
  
  // ❌ Retornar erro amigável
  return {'success': false, 'message': message};
}
```

### **Outros Status:**
```dart
} else {
  // ❌ Tratar outros status com mensagens apropriadas
  String message;
  switch (response.statusCode) {
    case 401:
      message = 'Não autorizado';
      break;
    case 404:
      message = 'Evento não encontrado';
      break;
    case 500:
      message = 'Erro interno do servidor';
      break;
    default:
      message = 'Erro desconhecido (Status: ${response.statusCode})';
  }
  return {'success': false, 'message': message};
}
```

---

## 🎯 **5. VALIDAÇÃO NO FRONTEND**

### **Feedback Imediato:**
```dart
// ✅ Sucesso
if (response['success'] == true) {
  // Limpar mensagens de erro
  setState(() {
    _errorMessage = null;
    _isLoading = false;
  });
  
  // Redirecionar para tela do evento
  Navigator.pushReplacementNamed(context, '/home');
}

// ❌ Erro
} else {
  setState(() {
    _errorMessage = response['message'] ?? 'Falha na autenticação';
    _isLoading = false;
  });
}
```

### **Verificações de UX:**
- [ ] **Loading state** durante a requisição
- [ ] **Mensagem de erro clara** e específica
- [ ] **Campo de ID destacado** em caso de erro
- [ ] **Botão desabilitado** durante processamento
- [ ] **Feedback visual** para sucesso/erro

---

## 🧪 **6. TESTES DIRETOS**

### **Teste com cURL:**
```bash
# ✅ Teste com ID válido
curl -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "User-Agent: Comentarista/1.0.0" \
     "https://datarodeo.com.br/api/mobile?id=86"

# ❌ Teste com ID inválido
curl -H "Accept: application/json" \
     -H "Content-Type: application/json" \
     -H "User-Agent: Comentarista/1.0.0" \
     "https://datarodeo.com.br/api/mobile?id=999"
```

### **Teste com Postman:**
- **Método**: GET
- **URL**: `https://datarodeo.com.br/api/mobile?id=86`
- **Headers**: 
  - `Accept: application/json`
  - `Content-Type: application/json`
  - `User-Agent: Comentarista/1.0.0`

### **Verificações de Teste:**
- [ ] **ID "86"** retorna Status 200 com dados completos
- [ ] **ID "999"** retorna Status 400 com "Id inválido"
- [ ] **Headers corretos** são aceitos pela API
- [ ] **Resposta JSON** está bem formatada
- [ ] **Dados essenciais** estão presentes na resposta

---

## 📝 **7. LOGS E DEBUG**

### **Logs Obrigatórios:**
```dart
// 🔍 Início da validação
print('🔍 Validando evento ID: $eventId');

// 🌐 URL da requisição
print('🌐 Fazendo requisição para: $fullUrl');

// 📱 Headers utilizados
print('📱 Headers: Content-Type: application/json, Accept: application/json, User-Agent: Comentarista/1.0.0');

// 📡 Status da resposta
print('📡 Resposta recebida - Status: ${response.statusCode}');

// 📄 Conteúdo da resposta
print('📄 Conteúdo (primeiros 300 chars): ${response.body.length > 300 ? response.body.substring(0, 300) + "..." : response.body}');

// ✅ Sucesso ou ❌ Erro
if (response.statusCode == 200) {
  print('✅ Evento encontrado: ${data['evento']}');
  print('📊 Dados: evento=$hasEvento, round=$hasRound, competidores=$hasCompetitors');
} else if (response.statusCode == 400) {
  print('❌ ID inválido - Status 400: ${response.body}');
} else {
  print('❌ Status HTTP inválido: ${response.statusCode}');
}
```

### **Verificações de Log:**
- [ ] **Logs ativos** no console do Flutter
- [ ] **Informações completas** sobre requisição e resposta
- [ ] **Tratamento de erros** com logs específicos
- [ ] **Debug de rede** funcionando
- [ ] **Logs limpos** em produção (opcional)

---

## 🔐 **8. PERMISSÕES E CONECTIVIDADE**

### **Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### **iOS (Info.plist):**
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### **Verificações de Rede:**
- [ ] **Permissão de internet** configurada
- [ ] **Conexão ativa** no dispositivo
- [ ] **Firewall/Proxy** não bloqueando requisições
- [ ] **DNS** resolvendo corretamente
- [ ] **HTTPS** funcionando (certificado válido)

---

## 🚨 **PROBLEMAS COMUNS E SOLUÇÕES**

### **Problema: "Id inválido" para IDs que existem no site**
**Causa**: Diferença entre IDs da interface web e IDs da API mobile
**Solução**: Usar apenas IDs testados e validados (86, B1F, 125, 128)

### **Problema: Timeout de conexão**
**Causa**: Rede lenta ou API sobrecarregada
**Solução**: Aumentar timeout para 30+ segundos

### **Problema: Headers rejeitados**
**Causa**: Headers incorretos ou incompatíveis
**Solução**: Usar apenas headers essenciais e testados

### **Problema: Erro de parsing JSON**
**Causa**: Resposta não é JSON válido
**Solução**: Verificar se a API está retornando JSON correto

---

## 📱 **TESTE FINAL NO APP**

### **Sequência de Teste:**
1. **Abrir app** e ir para tela de login
2. **Digitar ID "86"** no campo de ID
3. **Clicar em "Entrar"**
4. **Verificar logs** no console
5. **Confirmar redirecionamento** para tela principal
6. **Testar ID inválido** (ex: "999")
7. **Verificar mensagem de erro** apropriada

### **Resultado Esperado:**
- ✅ **ID "86"**: App abre e vai para tela principal
- ❌ **ID "999"**: Mensagem "Id inválido" exibida
- 📝 **Logs completos** no console
- 🔄 **Loading states** funcionando
- 🎯 **Feedback visual** claro para usuário

---

## 🎉 **CONCLUSÃO**

Seguindo este checklist, você garantirá que:

1. **IDs são validados corretamente** contra a API do DataRodeo
2. **Requisições HTTP** estão configuradas adequadamente
3. **Respostas são tratadas** de forma robusta
4. **Interface do usuário** fornece feedback claro
5. **Logs de debug** facilitam troubleshooting
6. **Permissões de rede** estão configuradas
7. **Testes diretos** confirmam funcionamento da API

**Status**: ✅ Checklist completo para revisão  
**Próximo passo**: Executar todas as verificações e testar no app  
**Resultado esperado**: Login funcionando perfeitamente com IDs válidos do DataRodeo

