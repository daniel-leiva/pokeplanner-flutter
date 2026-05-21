import 'dart:math';

import 'package:flutter/material.dart';
import 'package:proyecto_final_progra3/datos/servicios/servicio_pokeapi.dart';
import 'package:proyecto_final_progra3/dominio/entidades/pokemon.dart';
import 'package:proyecto_final_progra3/dominio/entidades/pokemon_carta.dart';
import 'package:proyecto_final_progra3/dominio/estructuras/cola_pokemon.dart';
import 'package:proyecto_final_progra3/nucleo/tema/colores_app.dart';
import 'package:proyecto_final_progra3/presentacion/pantallas/pila_cola/widgets/tarjeta_pokemon.dart';

class PantallaColaPokemon extends StatefulWidget {
  const PantallaColaPokemon({super.key});

  @override
  State<PantallaColaPokemon> createState() => _PantallaColaPokemonState();
}

class _PantallaColaPokemonState extends State<PantallaColaPokemon>
    with SingleTickerProviderStateMixin {
  static final ColaPokemon _colaCompartida = ColaPokemon();
  static final List<PokemonCarta> _batallaCompartida = <PokemonCarta>[];

  ColaPokemon get cola => _colaCompartida;
  List<PokemonCarta> get batalla => _batallaCompartida;

  final ServicioPokeapi _servicioPokeapi = ServicioPokeapi();
  final TextEditingController buscarController = TextEditingController();

  late AnimationController controladorAnimacion;

  int posicionEncontrada = -1;
  int paginaActual = 0;

  static const int totalPokemones = 100;
  static const int pokemonesPorPagina = 20;

  bool cargandoBusqueda = false;
  bool cargandoTodos = false;

  PokemonCarta? pokemonBuscado;

  int vidaEnemigo = 300;
  final int vidaMaximaEnemigo = 300;

  int ultimoDanio = 0;
  bool mostrarDanio = false;

  String mensajeBatalla = 'Agrega Pokémon a la cola o batalla para iniciar.';

  final List<PokemonCarta> todosLosPokemones = <PokemonCarta>[];

  @override
  void initState() {
    super.initState();

    controladorAnimacion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    cargarTodosLosPokemones();
  }

  Future<void> cargarTodosLosPokemones() async {
    setState(() {
      cargandoTodos = true;
    });

    try {
      final List<Pokemon> lista = await _servicioPokeapi
          .obtenerPokemonesPaginados(limite: totalPokemones, offset: 0);

      final List<PokemonCarta> cartas = <PokemonCarta>[];

      for (final Pokemon pokemon in lista) {
        try {
          final PokemonCarta carta = await _servicioPokeapi
              .obtenerPokemonCartaDetalle(pokemon.nombre);
          cartas.add(carta);
        } catch (_) {}
      }

      if (!mounted) return;

      setState(() {
        todosLosPokemones
          ..clear()
          ..addAll(cartas);
      });
    } catch (_) {
      mostrarMensaje('No se pudieron cargar los Pokémon.', esError: true);
    } finally {
      if (mounted) {
        setState(() {
          cargandoTodos = false;
        });
      }
    }
  }

  bool _pokemonExisteEnCola(PokemonCarta pokemon) {
    return cola.elementos.any(
      (PokemonCarta item) =>
          item.id == pokemon.id ||
          item.nombre.toLowerCase() == pokemon.nombre.toLowerCase(),
    );
  }

  bool _pokemonExisteEnBatalla(PokemonCarta pokemon) {
    return batalla.any(
      (PokemonCarta item) =>
          item.id == pokemon.id ||
          item.nombre.toLowerCase() == pokemon.nombre.toLowerCase(),
    );
  }

  bool _pokemonExisteGeneral(PokemonCarta pokemon) {
    return _pokemonExisteEnCola(pokemon) || _pokemonExisteEnBatalla(pokemon);
  }

  void agregarACola(PokemonCarta pokemon) {
    if (_pokemonExisteGeneral(pokemon)) {
      mostrarMensaje('${pokemon.nombre} ya está registrado.', esError: true);
      return;
    }

    setState(() {
      cola.enqueue(pokemon);
      batalla.add(pokemon);
      posicionEncontrada = -1;
      pokemonBuscado = null;
      buscarController.clear();
      mensajeBatalla = '${pokemon.nombre} entró a la cola y a la batalla.';
    });

    mostrarMensaje('${pokemon.nombre} agregado a la cola y batalla.');
  }

  void agregarABatalla(PokemonCarta pokemon) {
    if (_pokemonExisteGeneral(pokemon)) {
      mostrarMensaje('${pokemon.nombre} ya está registrado.', esError: true);
      return;
    }

    setState(() {
      batalla.add(pokemon);
      pokemonBuscado = null;
      buscarController.clear();
      mensajeBatalla = '${pokemon.nombre} fue enviado directamente a batalla.';
    });

    mostrarMensaje('${pokemon.nombre} agregado a batalla.');
  }

  void agregarAleatorioACola() {
    if (todosLosPokemones.isEmpty) {
      mostrarMensaje(
        'Espera a que se carguen los Pokémon disponibles.',
        esError: true,
      );
      return;
    }

    final List<PokemonCarta> disponibles = todosLosPokemones
        .where((PokemonCarta pokemon) => !_pokemonExisteGeneral(pokemon))
        .toList();

    if (disponibles.isEmpty) {
      mostrarMensaje(
        'Ya agregaste todos los Pokémon disponibles.',
        esError: true,
      );
      return;
    }

    final PokemonCarta seleccionado =
        disponibles[Random().nextInt(disponibles.length)];

    agregarACola(seleccionado);
  }

  void retirarSiguiente() {
    final PokemonCarta? eliminado = cola.dequeue();

    setState(() {
      posicionEncontrada = -1;
      mensajeBatalla = eliminado == null
          ? 'No hay Pokémon en la cola.'
          : '${eliminado.nombre} salió de la cola.';
    });
  }

  void quitarDeBatalla(PokemonCarta pokemon) {
    setState(() {
      batalla.removeWhere((PokemonCarta item) => item.id == pokemon.id);
      mensajeBatalla = '${pokemon.nombre} fue retirado de batalla.';
    });
  }

  Future<void> buscarPokemonApi() async {
    final String nombre = buscarController.text.trim();

    if (nombre.isEmpty) {
      mostrarMensaje('Ingresa el nombre o ID de un Pokémon.', esError: true);
      return;
    }

    setState(() {
      cargandoBusqueda = true;
      pokemonBuscado = null;
      posicionEncontrada = -1;
    });

    try {
      final PokemonCarta carta = await _servicioPokeapi
          .obtenerPokemonCartaDetalle(nombre);

      if (!mounted) return;

      setState(() {
        pokemonBuscado = carta;
      });

      mostrarMensaje('Pokémon encontrado: ${carta.nombre}.');
    } catch (_) {
      if (!mounted) return;

      mostrarMensaje('No se pudo encontrar ese Pokémon.', esError: true);
    } finally {
      if (mounted) {
        setState(() {
          cargandoBusqueda = false;
        });
      }
    }
  }

  void buscarEnCola() {
    final String nombre = buscarController.text.trim();

    setState(() {
      posicionEncontrada = cola.buscarPosicion(nombre);
      mensajeBatalla = posicionEncontrada == -1
          ? 'No se encontró ese Pokémon en la cola.'
          : '$nombre está en la posición $posicionEncontrada.';
    });
  }

  Future<void> atacar() async {
    PokemonCarta? atacante;

    if (batalla.isNotEmpty) {
      atacante = batalla.first;
    } else {
      atacante = cola.atacarYRotar();
    }

    if (atacante == null) {
      setState(() {
        mensajeBatalla = 'No hay Pokémon para atacar.';
      });
      return;
    }

    final int danio = atacante.ataque;
    final int nuevaVida = vidaEnemigo - danio;

    setState(() {
      ultimoDanio = danio;
      mostrarDanio = true;
      posicionEncontrada = -1;
      mensajeBatalla = '${atacante!.nombre} está atacando...';
    });

    await controladorAnimacion.forward(from: 0);

    setState(() {
      vidaEnemigo = nuevaVida < 0 ? 0 : nuevaVida;
      mensajeBatalla = '${atacante!.nombre} hizo $danio de daño.';

      if (vidaEnemigo == 0) {
        mensajeBatalla =
            '${atacante.nombre} derrotó al enemigo. Se reinicia la batalla.';
        vidaEnemigo = vidaMaximaEnemigo;
      }
    });

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() {
        mostrarDanio = false;
      });
    }
  }

  List<PokemonCarta> _obtenerPaginaActual() {
    final int inicio = paginaActual * pokemonesPorPagina;
    final int fin = inicio + pokemonesPorPagina;

    if (inicio >= todosLosPokemones.length) {
      return <PokemonCarta>[];
    }

    return todosLosPokemones.sublist(
      inicio,
      fin > todosLosPokemones.length ? todosLosPokemones.length : fin,
    );
  }

  int _totalPaginas() {
    if (todosLosPokemones.isEmpty) return 1;

    return (todosLosPokemones.length / pokemonesPorPagina).ceil();
  }

  void mostrarMensaje(String mensaje, {bool esError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  void mostrarDetalleCarta(PokemonCarta pokemon) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Material(
            color: Colors.black.withValues(alpha: 0.45),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: TarjetaPokemon(pokemon: pokemon, etiqueta: 'Detalle'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cartaClickeable({
    required PokemonCarta pokemon,
    String? etiqueta,
    bool resaltado = false,
  }) {
    return GestureDetector(
      onTap: () => mostrarDetalleCarta(pokemon),
      child: TarjetaPokemon(
        pokemon: pokemon,
        etiqueta: etiqueta,
        resaltado: resaltado,
      ),
    );
  }

  @override
  void dispose() {
    buscarController.dispose();
    controladorAnimacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: ColoresApp.fondo,
        appBar: AppBar(
          title: const Text('Vista de Batalla'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.queue_rounded), text: 'Cola'),
              Tab(icon: Icon(Icons.sports_mma_rounded), text: 'Batalla'),
              Tab(icon: Icon(Icons.catching_pokemon_rounded), text: 'Todos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _construirPestanaCola(),
            _construirPestanaBatalla(),
            _construirPestanaTodos(),
          ],
        ),
      ),
    );
  }

  Widget _construirPestanaCola() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'La cola funciona con el principio FIFO: el primer Pokémon en entrar será el primero en atacar.',
                style: TextStyle(fontSize: 14.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1) Buscar Pokémon',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: buscarController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      labelText: 'Nombre o ID',
                      hintText: 'Ejemplo: pikachu o 25',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => buscarPokemonApi(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: cargandoBusqueda ? null : buscarPokemonApi,
                          icon: cargandoBusqueda
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search_rounded),
                          label: const Text('Buscar Pokémon'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: buscarEnCola,
                          icon: const Icon(Icons.queue_rounded),
                          label: const Text('Buscar en cola'),
                        ),
                      ),
                    ],
                  ),
                  if (pokemonBuscado != null) ...[
                    const SizedBox(height: 14),
                    Center(
                      child: _cartaClickeable(
                        pokemon: pokemonBuscado!,
                        etiqueta: 'Encontrado',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => agregarACola(pokemonBuscado!),
                            icon: const Icon(Icons.playlist_add_rounded),
                            label: const Text('Agregar a cola'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => agregarABatalla(pokemonBuscado!),
                            icon: const Icon(Icons.sports_mma_rounded),
                            label: const Text('Enviar a batalla'),
                            style: FilledButton.styleFrom(
                              backgroundColor: ColoresApp.secundario,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Aún no hay Pokémon buscado.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2) Operaciones de cola',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: agregarAleatorioACola,
                          icon: const Icon(Icons.shuffle_rounded),
                          label: const Text('Agregar aleatorio'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: retirarSiguiente,
                          icon: const Icon(Icons.remove_rounded),
                          label: const Text('Atender siguiente'),
                          style: FilledButton.styleFrom(
                            backgroundColor: ColoresApp.secundario,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColoresApp.primario.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Pokémon en cola: ${cola.elementos.length}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColoresApp.primario,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '3) Turnos de batalla',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (cola.elementos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(
                          'La cola está vacía.\nAgrega Pokémon para organizar los turnos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 18,
                      runSpacing: 18,
                      children: cola.elementos.map((PokemonCarta pokemon) {
                        final int index = cola.elementos.indexOf(pokemon);

                        return _cartaClickeable(
                          pokemon: pokemon,
                          resaltado: index + 1 == posicionEncontrada,
                          etiqueta: index == 0
                              ? 'Siguiente'
                              : 'Turno ${index + 1}',
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirPestanaBatalla() {
    final PokemonCarta? atacante = batalla.isNotEmpty
        ? batalla.first
        : cola.frente;
    final double porcentajeVida = vidaEnemigo / vidaMaximaEnemigo;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  const Text(
                    'Vista de Batalla',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: ColoresApp.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ataca con los Pokémon activos o con el primero de la cola.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _BarraVidaEnemigo(
                    vida: vidaEnemigo,
                    vidaMaxima: vidaMaximaEnemigo,
                    porcentaje: porcentajeVida,
                  ),
                  const SizedBox(height: 18),
                  if (atacante == null)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No hay Pokémon atacando'),
                    )
                  else
                    AnimatedBuilder(
                      animation: controladorAnimacion,
                      builder: (BuildContext context, Widget? child) {
                        final double shake =
                            sin(controladorAnimacion.value * pi * 8) * 7;

                        return Transform.translate(
                          offset: Offset(shake, 0),
                          child: child,
                        );
                      },
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          _TarjetaBatallaPokemon(pokemon: atacante),
                          AnimatedOpacity(
                            opacity: mostrarDanio ? 1 : 0,
                            duration: const Duration(milliseconds: 250),
                            child: Transform.translate(
                              offset: const Offset(0, -10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: ColoresApp.secundario,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '-$ultimoDanio HP',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: atacar,
                    icon: const Icon(Icons.flash_on_rounded),
                    label: const Text('Atacar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: ColoresApp.secundario,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mensajeBatalla,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pokémon en batalla',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  if (batalla.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(
                          'No hay Pokémon enviados directamente a batalla.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 18,
                      runSpacing: 18,
                      children: batalla.map((PokemonCarta pokemon) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _cartaClickeable(
                              pokemon: pokemon,
                              etiqueta: 'Batalla',
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 220,
                              child: FilledButton.icon(
                                onPressed: () => quitarDeBatalla(pokemon),
                                icon: const Icon(Icons.remove_circle_outline),
                                label: const Text('Retirar de batalla'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: ColoresApp.secundario,
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirPestanaTodos() {
    final List<PokemonCarta> pagina = _obtenerPaginaActual();
    final int totalPaginas = _totalPaginas();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'Explora los primeros 100 Pokémon. Puedes agregarlos a la cola o enviarlos directamente a batalla.',
                style: TextStyle(fontSize: 14.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  if (cargandoTodos)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: paginaActual == 0
                                ? null
                                : () {
                                    setState(() {
                                      paginaActual--;
                                    });
                                  },
                            icon: const Icon(Icons.chevron_left_rounded),
                            label: const Text('Anterior'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColoresApp.primario.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Página ${paginaActual + 1} de $totalPaginas',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColoresApp.primario,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: paginaActual >= totalPaginas - 1
                                ? null
                                : () {
                                    setState(() {
                                      paginaActual++;
                                    });
                                  },
                            icon: const Icon(Icons.chevron_right_rounded),
                            label: const Text('Siguiente'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (pagina.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'No hay Pokémon disponibles.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    else
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 18,
                        runSpacing: 18,
                        children: pagina.map((PokemonCarta pokemon) {
                          final bool registrado = _pokemonExisteGeneral(
                            pokemon,
                          );

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _cartaClickeable(
                                pokemon: pokemon,
                                etiqueta: registrado
                                    ? 'Registrado'
                                    : 'Disponible',
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 220,
                                child: FilledButton.icon(
                                  onPressed: registrado
                                      ? null
                                      : () => agregarACola(pokemon),
                                  icon: const Icon(Icons.playlist_add_rounded),
                                  label: Text(
                                    registrado
                                        ? 'Ya registrado'
                                        : 'Agregar a cola',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 220,
                                child: FilledButton.icon(
                                  onPressed: registrado
                                      ? null
                                      : () => agregarABatalla(pokemon),
                                  icon: const Icon(Icons.sports_mma_rounded),
                                  label: const Text('Enviar a batalla'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: ColoresApp.secundario,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraVidaEnemigo extends StatelessWidget {
  const _BarraVidaEnemigo({
    required this.vida,
    required this.vidaMaxima,
    required this.porcentaje,
  });

  final int vida;
  final int vidaMaxima;
  final double porcentaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ColoresApp.tarjeta,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield, color: ColoresApp.secundario),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: porcentaje),
                duration: const Duration(milliseconds: 500),
                builder: (BuildContext context, double value, Widget? child) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 14,
                    backgroundColor: ColoresApp.secundario.withValues(
                      alpha: 0.16,
                    ),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      ColoresApp.secundario,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$vida/$vidaMaxima',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TarjetaBatallaPokemon extends StatelessWidget {
  const _TarjetaBatallaPokemon({required this.pokemon});

  final PokemonCarta pokemon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ColoresApp.secundario.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: ColoresApp.secundario.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.topRight,
            child: Chip(
              label: Text('ATACA', style: TextStyle(color: Colors.white)),
              backgroundColor: ColoresApp.secundario,
            ),
          ),
          Image.network(pokemon.imagenUrl, height: 90, fit: BoxFit.contain),
          const SizedBox(height: 8),
          Text(
            pokemon.nombre,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            pokemon.tipo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Ataque: ${pokemon.ataque}  |  Poder: ${pokemon.poderTotal}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
