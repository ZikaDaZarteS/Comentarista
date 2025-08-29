class Evento {
  final int id;
  final String nome;
  final String dataInicio;
  final String dataFim;
  final String local;
  final String tipo;
  final String status;
  final String descricao;
  final String organizador;
  final Map<String, dynamic> contato;

  Evento({
    required this.id,
    required this.nome,
    required this.dataInicio,
    required this.dataFim,
    required this.local,
    required this.tipo,
    required this.status,
    required this.descricao,
    required this.organizador,
    required this.contato,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      dataInicio: json['data_inicio'] ?? '',
      dataFim: json['data_fim'] ?? '',
      local: json['local'] ?? '',
      tipo: json['tipo'] ?? '',
      status: json['status'] ?? '',
      descricao: json['descricao'] ?? '',
      organizador: json['organizador'] ?? '',
      contato: json['contato'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'data_inicio': dataInicio,
      'data_fim': dataFim,
      'local': local,
      'tipo': tipo,
      'status': status,
      'descricao': descricao,
      'organizador': organizador,
      'contato': contato,
    };
  }
}

class Round {
  final int id;
  final int idEvento;
  final int idAnimal;
  final int idCompetidor;
  final int idEtapa;
  final String etapa;
  final int seq;
  final String lado;
  final int tipo;
  final double nota;
  final double notaTotal;
  final double tempo;
  final double bonus;
  final int ordem;
  final int rr;

  Round({
    required this.id,
    required this.idEvento,
    required this.idAnimal,
    required this.idCompetidor,
    required this.idEtapa,
    required this.etapa,
    required this.seq,
    required this.lado,
    required this.tipo,
    required this.nota,
    required this.notaTotal,
    required this.tempo,
    required this.bonus,
    required this.ordem,
    required this.rr,
  });

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      id: json['id'] ?? 0,
      idEvento: json['id_evento'] ?? 0,
      idAnimal: json['id_animal'] ?? 0,
      idCompetidor: json['id_competidor'] ?? 0,
      idEtapa: json['id_etapa'] ?? 0,
      etapa: json['etapa'] ?? '',
      seq: json['seq'] ?? 0,
      lado: json['lado'] ?? '',
      tipo: json['tipo'] ?? 0,
      nota: (json['nota'] ?? 0).toDouble(),
      notaTotal: (json['nota_total'] ?? 0).toDouble(),
      tempo: (json['tempo'] ?? 0).toDouble(),
      bonus: (json['bonus'] ?? 0).toDouble(),
      ordem: json['ordem'] ?? 0,
      rr: json['rr'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_evento': idEvento,
      'id_animal': idAnimal,
      'id_competidor': idCompetidor,
      'id_etapa': idEtapa,
      'etapa': etapa,
      'seq': seq,
      'lado': lado,
      'tipo': tipo,
      'nota': nota,
      'nota_total': notaTotal,
      'tempo': tempo,
      'bonus': bonus,
      'ordem': ordem,
      'rr': rr,
    };
  }
}

class Competidor {
  final int id;
  final String nome;
  final String cidade;
  final String uf;
  final String cpf;
  final String rg;
  final String dataNascimento;
  final String pis;
  final String descricao;

  Competidor({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.uf,
    required this.cpf,
    required this.rg,
    required this.dataNascimento,
    required this.pis,
    required this.descricao,
  });

  factory Competidor.fromJson(Map<String, dynamic> json) {
    return Competidor(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      cidade: json['cidade'] ?? '',
      uf: json['uf'] ?? '',
      cpf: json['cpf'] ?? '',
      rg: json['rg'] ?? '',
      dataNascimento: json['data_nascimento'] ?? '',
      pis: json['pis'] ?? '',
      descricao: json['descricao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cidade': cidade,
      'uf': uf,
      'cpf': cpf,
      'rg': rg,
      'data_nascimento': dataNascimento,
      'pis': pis,
      'descricao': descricao,
    };
  }
}

class Animal {
  final int id;
  final String nome;
  final int idTropeiro;
  final String descricao;

  Animal({
    required this.id,
    required this.nome,
    required this.idTropeiro,
    required this.descricao,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      idTropeiro: json['id_tropeiro'] ?? 0,
      descricao: json['descricao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'id_tropeiro': idTropeiro,
      'descricao': descricao,
    };
  }
}

class Tropeiro {
  final int id;
  final String nome;
  final String cidade;
  final String uf;

  Tropeiro({
    required this.id,
    required this.nome,
    required this.cidade,
    required this.uf,
  });

  factory Tropeiro.fromJson(Map<String, dynamic> json) {
    return Tropeiro(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      cidade: json['cidade'] ?? '',
      uf: json['uf'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'cidade': cidade,
      'uf': uf,
    };
  }
}
