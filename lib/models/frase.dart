class Frase {
  final int? id;
  final String frase;
  final String autor;
  const Frase({this.id, required this.frase, required this.autor});

  Map<String,  Object?> toMap() {
    return {if (id != null) 'id': id, 'frase': frase, 'autor': autor};
  }

  factory Frase.fromMap(Map<String, Object?> mapa) {
    return Frase(id: mapa['id'] as int?, frase: mapa['frase'] as String, autor: mapa['autor'] as String);
  }
}
