class Pokemon {
  final String nombre;
  final String url;
  final int? id;
  final List<String> tipos;
  final int hp;
  final int ataque;
  final int defensa;
  final int velocidad;

  const Pokemon({
    required this.nombre,
    required this.url,
    this.id,
    this.tipos = const <String>[],
    this.hp = 0,
    this.ataque = 0,
    this.defensa = 0,
    this.velocidad = 0,
  });

  String get tipoPrincipal => tipos.isEmpty ? 'normal' : tipos.first;

  int get poderTotal => hp + ataque + defensa + velocidad;
}
