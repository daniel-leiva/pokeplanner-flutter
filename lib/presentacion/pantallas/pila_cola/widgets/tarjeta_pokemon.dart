import 'package:flutter/material.dart';
import 'package:proyecto_final_progra3/dominio/entidades/pokemon.dart';
import 'package:proyecto_final_progra3/nucleo/tema/colores_app.dart';
import 'package:proyecto_final_progra3/nucleo/utilidades/imagen_pokemon_helper.dart';
import 'package:proyecto_final_progra3/presentacion/widgets/imagen_pokemon.dart';

class TarjetaPokemon extends StatelessWidget {
  const TarjetaPokemon({
    super.key,
    required this.pokemon,
    this.resaltado = false,
    this.etiqueta,
  });

  final Pokemon pokemon;
  final bool resaltado;
  final String? etiqueta;

  Color _colorTipo(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'fuego':
      case 'electrico':
        return ColoresApp.acento;
      case 'agua':
        return ColoresApp.secundario;
      case 'planta':
        return ColoresApp.primario;
      default:
        return ColoresApp.secundario;
    }
  }

  String _formatearTipo(String tipo) {
    if (tipo.isEmpty) {
      return 'Normal';
    }

    return tipo[0].toUpperCase() + tipo.substring(1).toLowerCase();
  }

  Widget _stat(String label, int value, Color color) {
    final double porcentaje = (value / 100).clamp(0.0, 1.0);

    return Column(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: 6,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: porcentaje,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 9,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tipoPrincipal = pokemon.tipoPrincipal;
    final Color colorTipo = _colorTipo(tipoPrincipal);
    final ReferenciasImagenPokemon? referencias =
        ImagenPokemonHelper.obtenerReferenciasDesdeUrl(pokemon.url);
    final String identificador =
        pokemon.id?.toString().padLeft(3, '0') ?? '---';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      width: 220,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[colorTipo.withValues(alpha: 0.2), ColoresApp.tarjeta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: resaltado
              ? ColoresApp.acento
              : ColoresApp.secundario.withValues(alpha: 0.45),
          width: resaltado ? 3 : 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColoresApp.secundario.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                '#$identificador',
                style: TextStyle(color: colorTipo, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              if (etiqueta != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ColoresApp.secundario,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    etiqueta!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ImagenPokemon(
            imagenUrl: referencias?.urlPrincipal,
            imagenFallbackUrl: referencias?.urlFallback,
            tamano: 85,
            radioBorde: 18,
          ),
          const SizedBox(height: 8),
          Text(
            pokemon.nombre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              color: ColoresApp.textoPrincipal,
            ),
          ),
          const SizedBox(height: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: colorTipo.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatearTipo(tipoPrincipal),
              style: TextStyle(color: colorTipo, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _stat('HP', pokemon.hp, ColoresApp.secundario),
                _stat('ATK', pokemon.ataque, ColoresApp.primario),
                _stat('DEF', pokemon.defensa, ColoresApp.secundario),
                _stat('SPD', pokemon.velocidad, ColoresApp.acento),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: colorTipo.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Poder total: ${pokemon.poderTotal}',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorTipo, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}
