# PokéPlanner

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase Auth](https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase&logoColor=black)
![PokéAPI](https://img.shields.io/badge/API-Pok%C3%A9API-EF5350)
![Estado](https://img.shields.io/badge/Estado-Funcional-2E7D32)

App Flutter para organizar colecciones Pokémon y practicar estructuras de datos con datos reales de PokéAPI.

## Vista previa

> Aún no hay capturas versionadas.  
> Recomendado agregar:
>
> - `docs/capturas/inicio.png`
> - `docs/capturas/arbol.png`
> - `docs/capturas/analizador.png`

## Resumen rápido

PokéPlanner es un proyecto académico de **Programación III** construido con Flutter/Dart.  
Integra autenticación con Firebase (Android) y consumo de PokéAPI para trabajar módulos interactivos de estructuras de datos desde interfaz gráfica.

## Características principales

- Autenticación de usuarios con Firebase Authentication.
- Consumo de PokéAPI para Pokémon, tipos y cadenas evolutivas.
- Implementación de estructuras de datos en Dart.
- Operaciones visibles desde UI (agregar, buscar, eliminar, reordenar, analizar).
- Análisis de árbol evolutivo con métricas y rutas.
- Analizador de equipos por tipos con matriz defensiva.
- Organización de colecciones personalizadas.
- Interfaz móvil con tema e icono personalizado (`assets/iconos/app_icon.png`).

## Tecnologías utilizadas

- Flutter
- Dart
- Firebase Authentication
- Firebase Core
- PokéAPI
- HTTP (`http`)
- `flutter_launcher_icons`
- Git / GitHub

## Requisitos previos

- Flutter SDK
- Dart SDK
- Android Studio y/o emulador Android
- Git
- Proyecto Firebase configurado para Android

## Instalación rápida

```bash
git clone <URL_DEL_REPOSITORIO>
cd proyecto_final_progra3
flutter pub get
```

## Configuración de entorno

Este proyecto usa variables por `String.fromEnvironment`, por lo que debes crear `.env` tomando `.env.example` como base:

```env
API_URL_BASE=https://pokeapi.co/api/v2
POKEAPI_SPRITES_URL_BASE=https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon
POKEAPI_TYPE_ICONS_URL_BASE=https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-viii/sword-shield
```

`.env` es local y **no debe subirse** al repositorio.

## Ejecución

```bash
flutter run --dart-define-from-file=.env
```

Emulador específico:

```bash
flutter run -d emulator-5554 --dart-define-from-file=.env
```

## Módulos principales

- **Autenticación**: login, registro y control de sesión.
- **Pantalla principal**: acceso a todos los módulos.
- **Cartas Pokémon**: gestión tipo pila (LIFO) con álbum y búsqueda.
- **Vista de Batalla**: turnos tipo cola (FIFO) y rotación.
- **Organizador de colecciones**: lista enlazada con filtros y reordenamiento.
- **Árbol Evolutivo**: carga de familias, búsqueda y simulaciones locales.
- **Analizador de Equipos**: equipo de 6, recientes y análisis de tipos.

## Estructuras de datos implementadas

| Estructura | Archivo principal | Uso en la app | Operaciones visibles |
|---|---|---|---|
| `PilaPokemon` | `lib/dominio/estructuras/pila_pokemon.dart` | Cartas Pokémon / álbum | apilar, desapilar, buscar en pila |
| `ColaPokemon` | `lib/dominio/estructuras/cola_pokemon.dart` | Vista de Batalla | enqueue, dequeue, atacar y rotar, buscar posición |
| `ListaEnlazadaLivingDex` | `lib/dominio/estructuras/lista_enlazada_living_dex.dart` | Organizador de colecciones | insertar final/después, eliminar, buscar, reordenar |
| `ArbolPokemon` | `lib/dominio/estructuras/arbol_pokemon.dart` | Árbol Evolutivo | cargar raíz, buscar, insertar/eliminar simulados, recorridos y métricas |
| `TablaHashTiposPokemon` | `lib/dominio/estructuras/tabla_hash_tipos_pokemon.dart` | Analizador de Equipos | insertar/buscar tipo, multiplicadores defensivos |
| `EquipoPokemon` | `lib/dominio/estructuras/equipo_pokemon.dart` | Armado de equipo (máx. 6) | agregar, eliminar, buscar, validar duplicados |
| `EquiposRecientesPokemon` | `lib/dominio/estructuras/equipos_recientes_pokemon.dart` | Historial de equipos | guardar, cargar, eliminar, limpiar recientes |

## Arquitectura del proyecto

```text
lib/
├── aplicacion/
├── datos/
├── dominio/
├── nucleo/
└── presentacion/
```

- `aplicacion/`: configuración de la app raíz.
- `datos/`: modelos y servicios externos (Firebase/PokéAPI).
- `dominio/`: entidades, repositorios y estructuras de datos.
- `nucleo/`: configuración, constantes, tema y utilidades.
- `presentacion/`: pantallas y widgets de UI.

## Validaciones

```bash
flutter analyze lib
```

Estado actual de pruebas:

- `flutter analyze lib`: limpio.
- `flutter test`: pendiente técnico conocido.  
  El test heredado `test/widget_test.dart` referencia `MyApp`, clase que ya no existe.

## Control de versiones

- Rama estable: `main`.
- Desarrollo por ramas `feature/...`.
- Integración sugerida vía Pull Requests.
- Commits descriptivos por módulo/entrega.

## Integrantes

- INT1 Kevin: Pila y Cola.
- INT2 Hetzon: Lista enlazada.
- INT3 Alexys: Tabla Hash.
- INT4 Daniel: Árbol, ajustes visuales, identidad y autenticación.

## Estado final

- App funcional.
- Autenticación integrada.
- PokéAPI integrada.
- Estructuras de datos implementadas.
- UI organizada por módulos.
- README actualizado.

## Licencia

Proyecto académico de uso educativo para Programación III.
