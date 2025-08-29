# Esquema de Banco de Dados - Sistema Comentarista

## Visão Geral
Este documento descreve a estrutura do banco de dados do Sistema Comentarista, incluindo todas as tabelas, relacionamentos e índices necessários para o funcionamento do sistema.

## Tecnologia
- **SGBD**: PostgreSQL 13+
- **ORM**: Prisma (opcional)
- **Migrations**: Alembic ou similar

## Diagrama ER
```
[EVENTOS] 1:N [ROUNDS] N:1 [COMPETIDORES]
    |              |              |
    |              |              |
    |              |              |
[PROFISSIONAIS]   |              |
    |              |              |
    |              |              |
[OCORRENCIAS]     |              |
                [ANIMAIS] N:1 [TROPEIROS]
```

## Tabelas Principais

### 1. eventos
Tabela principal para armazenar informações dos eventos de rodeio.

```sql
CREATE TABLE eventos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    local VARCHAR(255),
    status VARCHAR(50) DEFAULT 'ativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único do evento
- `nome`: Nome do evento (ex: "ENGENHO RODEO FEST")
- `data_inicio`: Data de início do evento
- `data_fim`: Data de término do evento
- `local`: Local onde o evento acontece
- `status`: Status do evento (ativo, cancelado, finalizado)
- `created_at`: Data de criação do registro
- `updated_at`: Data da última atualização

### 2. rounds
Armazena todas as rodadas de competição de cada evento.

```sql
CREATE TABLE rounds (
    id SERIAL PRIMARY KEY,
    id_evento INTEGER REFERENCES eventos(id),
    id_animal INTEGER REFERENCES animais(id),
    id_competidor INTEGER REFERENCES competidores(id),
    id_etapa INTEGER REFERENCES etapas(id),
    etapa VARCHAR(50) NOT NULL,
    seq INTEGER,
    lado CHAR(1) CHECK (lado IN ('C', 'E')),
    tipo INTEGER DEFAULT 1,
    nota DECIMAL(5,2) DEFAULT 0,
    nota_total DECIMAL(6,2) DEFAULT 0,
    tempo DECIMAL(4,2) DEFAULT 0,
    bonus DECIMAL(5,2) DEFAULT 0,
    ordem INTEGER,
    rr INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único da rodada
- `id_evento`: Referência ao evento
- `id_animal`: Referência ao animal
- `id_competidor`: Referência ao competidor
- `etapa`: Nome da etapa (ROUND 1, ROUND 3, etc.)
- `seq`: Sequência da rodada
- `lado`: Lado da arena (C = Centro, E = Esquerda)
- `tipo`: Tipo de competição
- `nota`: Nota da rodada
- `nota_total`: Nota total acumulada
- `tempo`: Tempo de montaria em segundos
- `bonus`: Pontos bônus
- `ordem`: Ordem de apresentação
- `rr`: Referência a rodada de re-ride

### 3. competidores
Cadastro de todos os competidores do sistema.

```sql
CREATE TABLE competidores (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cidade VARCHAR(255),
    uf CHAR(2),
    cpf VARCHAR(14),
    rg VARCHAR(20),
    data_nascimento DATE,
    pis VARCHAR(20),
    descricao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único do competidor
- `nome`: Nome completo do competidor
- `cidade`: Cidade de origem
- `uf`: Estado (UF)
- `cpf`: CPF do competidor
- `rg`: RG do competidor
- `data_nascimento`: Data de nascimento
- `pis`: Número do PIS
- `descricao`: Descrição/currículo do competidor

### 4. animais
Cadastro de todos os animais utilizados nas competições.

```sql
CREATE TABLE animais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    id_tropeiro INTEGER REFERENCES tropeiros(id),
    descricao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único do animal
- `nome`: Nome do animal
- `id_tropeiro`: Referência ao tropeiro proprietário
- `descricao`: Descrição do animal

### 5. tropeiros
Empresas/entidades que fornecem os animais para as competições.

```sql
CREATE TABLE tropeiros (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cidade VARCHAR(255),
    uf CHAR(2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único do tropeiro
- `nome`: Nome da empresa/entidade
- `cidade`: Cidade de localização
- `uf`: Estado (UF)

### 6. etapas
Definição das etapas de cada evento.

```sql
CREATE TABLE etapas (
    id SERIAL PRIMARY KEY,
    id_evento INTEGER REFERENCES eventos(id),
    nome VARCHAR(50) NOT NULL,
    ordem INTEGER NOT NULL,
    status VARCHAR(50) DEFAULT 'ativo',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único da etapa
- `id_evento`: Referência ao evento
- `nome`: Nome da etapa
- `ordem`: Ordem de execução
- `status`: Status da etapa

### 7. profissionais
Cadastro de juízes e outros profissionais envolvidos nos eventos.

```sql
CREATE TABLE profissionais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    id_profissao INTEGER REFERENCES profissoes(id),
    cidade VARCHAR(255),
    uf CHAR(2),
    rg VARCHAR(20),
    cpf VARCHAR(14),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único do profissional
- `nome`: Nome do profissional
- `id_profissao`: Referência à profissão
- `cidade`: Cidade de origem
- `uf`: Estado (UF)
- `rg`: RG do profissional
- `cpf`: CPF do profissional

### 8. profissoes
Tipos de profissões disponíveis no sistema.

```sql
CREATE TABLE profissoes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único da profissão
- `nome`: Nome da profissão
- `descricao`: Descrição da profissão

### 9. ocorrencias
Tipos de ocorrências que podem acontecer durante as competições.

```sql
CREATE TABLE ocorrencias (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    tipo VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único da ocorrência
- `nome`: Nome da ocorrência
- `descricao`: Descrição detalhada
- `tipo`: Tipo da ocorrência

### 10. notas
Histórico detalhado de todas as notas atribuídas pelos juízes.

```sql
CREATE TABLE notas (
    id SERIAL PRIMARY KEY,
    id_round INTEGER REFERENCES rounds(id),
    id_profissional INTEGER REFERENCES profissionais(id),
    nota_animal DECIMAL(5,2),
    nota_competidor DECIMAL(5,2),
    nota_bonus DECIMAL(5,2) DEFAULT 0,
    tempo DECIMAL(4,2),
    versao INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Campos:**
- `id`: Identificador único da nota
- `id_round`: Referência à rodada
- `id_profissional`: Referência ao juiz
- `nota_animal`: Nota atribuída ao animal
- `nota_competidor`: Nota atribuída ao competidor
- `nota_bonus`: Nota bônus
- `tempo`: Tempo registrado pelo juiz
- `versao`: Versão da nota (para auditoria)

## Índices Recomendados

```sql
-- Índices para performance de consultas
CREATE INDEX idx_rounds_evento ON rounds(id_evento);
CREATE INDEX idx_rounds_competidor ON rounds(id_competidor);
CREATE INDEX idx_rounds_animal ON rounds(id_animal);
CREATE INDEX idx_rounds_etapa ON rounds(etapa);
CREATE INDEX idx_notas_round ON notas(id_round);
CREATE INDEX idx_notas_profissional ON notas(id_profissional);
CREATE INDEX idx_competidores_cidade ON competidores(cidade);
CREATE INDEX idx_animais_tropeiro ON animais(id_tropeiro);

-- Índices compostos
CREATE INDEX idx_rounds_evento_etapa ON rounds(id_evento, etapa);
CREATE INDEX idx_rounds_competidor_evento ON rounds(id_competidor, id_evento);
```

## Constraints e Validações

```sql
-- Constraints de integridade referencial
ALTER TABLE rounds ADD CONSTRAINT fk_rounds_evento 
    FOREIGN KEY (id_evento) REFERENCES eventos(id) ON DELETE CASCADE;

ALTER TABLE rounds ADD CONSTRAINT fk_rounds_competidor 
    FOREIGN KEY (id_competidor) REFERENCES competidores(id) ON DELETE RESTRICT;

ALTER TABLE rounds ADD CONSTRAINT fk_rounds_animal 
    FOREIGN KEY (id_animal) REFERENCES animais(id) ON DELETE RESTRICT;

-- Constraints de validação
ALTER TABLE rounds ADD CONSTRAINT chk_nota_total 
    CHECK (nota_total >= 0 AND nota_total <= 300);

ALTER TABLE rounds ADD CONSTRAINT chk_tempo 
    CHECK (tempo >= 0 AND tempo <= 999.99);

ALTER TABLE rounds ADD CONSTRAINT chk_lado 
    CHECK (lado IN ('C', 'E'));
```

## Views Úteis

### vw_ranking_evento
```sql
CREATE VIEW vw_ranking_evento AS
SELECT 
    c.nome as competidor,
    c.cidade,
    r.id_competidor,
    SUM(r.nota_total) as nota_total,
    COUNT(r.id) as rodadas_participadas,
    ROW_NUMBER() OVER (ORDER BY SUM(r.nota_total) DESC) as posicao
FROM rounds r
JOIN competidores c ON r.id_competidor = c.id
WHERE r.id_evento = $1
GROUP BY c.id, c.nome, c.cidade, r.id_competidor
ORDER BY nota_total DESC;
```

### vw_performance_animal
```sql
CREATE VIEW vw_performance_animal AS
SELECT 
    a.nome as animal,
    t.nome as tropeiro,
    COUNT(r.id) as total_rodadas,
    AVG(r.nota_total) as media_nota,
    MAX(r.nota_total) as melhor_nota
FROM animais a
JOIN tropeiros t ON a.id_tropeiro = t.id
LEFT JOIN rounds r ON a.id = r.id_animal
GROUP BY a.id, a.nome, t.id, t.nome;
```

## Backup e Recuperação

### Estratégia de Backup
- **Backup Completo**: Diário às 02:00
- **Backup Incremental**: A cada 4 horas
- **Backup de Logs**: A cada 15 minutos
- **Retenção**: 30 dias para backups completos, 7 dias para incrementais

### Script de Backup
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h localhost -U comentarista -d comentarista_db > backup_$DATE.sql
gzip backup_$DATE.sql
```

## Monitoramento e Performance

### Métricas Importantes
- **Tempo de resposta médio**: < 200ms
- **Throughput**: > 1000 req/s
- **Disponibilidade**: > 99.9%
- **Tamanho do banco**: Monitorar crescimento

### Queries de Monitoramento
```sql
-- Tamanho das tabelas
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Estatísticas de uso
SELECT 
    relname as table_name,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes
FROM pg_stat_user_tables
ORDER BY n_tup_ins + n_tup_upd + n_tup_del DESC;
```

## Segurança

### Usuários e Permissões
```sql
-- Usuário da aplicação
CREATE USER comentarista_app WITH PASSWORD 'senha_segura';

-- Usuário de backup
CREATE USER comentarista_backup WITH PASSWORD 'senha_backup';

-- Permissões
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO comentarista_app;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO comentarista_app;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO comentarista_backup;
```

### Criptografia
- **Dados sensíveis**: CPF, RG criptografados
- **Senhas**: Hash bcrypt
- **Comunicação**: SSL/TLS obrigatório
- **Backup**: Criptografado

## Migração e Versionamento

### Estrutura de Migrations
```
migrations/
├── 001_create_initial_tables.sql
├── 002_add_indexes.sql
├── 003_add_constraints.sql
└── 004_add_views.sql
```

### Script de Migração
```bash
#!/bin/bash
echo "Executando migrações..."
for file in migrations/*.sql; do
    echo "Executando: $file"
    psql -h localhost -U comentarista -d comentarista_db -f "$file"
done
echo "Migrações concluídas!"
```

