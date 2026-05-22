import 'package:proyecto_final_progra3/dominio/entidades/pokemon.dart';

// Pila de Pokemon (LIFO).
class PilaPokemon {
  final List<Pokemon> _elementos = <Pokemon>[];

  List<Pokemon> get elementos => List.unmodifiable(_elementos);

  bool get estaVacia => _elementos.isEmpty;

  int get tamanio => _elementos.length;

  Pokemon? get top => estaVacia ? null : _elementos.last;

  void apilar(Pokemon pokemon) {
    _elementos.add(pokemon);
  }

  Pokemon? desapilar() {
    if (estaVacia) return null;
    return _elementos.removeLast();
  }

  Pokemon? verTope() {
    return top;
  }

  List<Pokemon> obtenerElementos() {
    return _elementos.reversed.toList();
  }

  // Alias para mantener compatibilidad con pantallas existentes.
  void push(Pokemon pokemon) {
    apilar(pokemon);
  }

  Pokemon? pop() {
    return desapilar();
  }

  int buscarIndicePorNombre(String nombre) {
    final List<Pokemon> listaVisual = obtenerElementos();

    for (int i = 0; i < listaVisual.length; i++) {
      if (listaVisual[i].nombre.toLowerCase() == nombre.toLowerCase()) {
        return i;
      }
    }

    return -1;
  }

  void limpiar() {
    _elementos.clear();
  }
}
