class DataConverters {
  /// Converte nota total para double (trata Int32 e Decimal)
  static double parseNotaTotal(dynamic notaTotal) {
    if (notaTotal == null) return 0.0;

    // Se já é um número, converte diretamente
    if (notaTotal is num) {
      return notaTotal.toDouble();
    }

    // Se é string, trata vírgula como separador decimal
    final notaStr = notaTotal.toString().replaceAll(',', '.');
    return double.tryParse(notaStr) ?? 0.0;
  }

  /// Converte string para int seguro
  static int parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Converte string para double seguro
  static double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  /// Formata nota para exibição
  static String formatNota(double nota) {
    return nota.toStringAsFixed(1);
  }

  /// Formata tempo para exibição
  static String formatTempo(double tempo) {
    if (tempo <= 0) return "0.0s";
    return "${tempo.toStringAsFixed(1)}s";
  }
}
