# RutaDex

Aplicacion Pokedex multiplataforma desarrollada en Flutter para la Practica 7 de Programacion de Dispositivos Moviles. Consume [PokeAPI](https://pokeapi.co/) y presenta la informacion como una ruta inspirada en los juegos de Pokemon de tercera generacion.

**Autor:** Andre Michel Marin Espinoza  
**Carrera:** Ingenieria en Inteligencia Artificial

## Funcionalidades

- Catalogo paginado con *infinite scrolling* y tarjetas por tipo.
- Consulta por nombre o numero.
- Filtros por tipo y generacion.
- Detalle con artwork, tipos, altura, peso, habilidades y descripcion.
- Estadisticas representadas mediante un radar hexagonal.
- Cadena evolutiva y movimientos.
- Reproduccion del grito al abrir un Pokemon en Android.
- Alternancia entre sprite normal y shiny.
- Creacion, edicion y eliminacion de equipos de hasta seis integrantes.
- Favoritos y equipos persistentes mediante `shared_preferences`.
- Interfaz adaptable para Android y web/escritorio.

## Decisiones tecnicas

La aplicacion separa los modelos, el acceso a PokeAPI, la persistencia local y la interfaz:

```text
lib/
|- main.dart          # Pantallas, navegacion y componentes visuales
|- models.dart        # Pokemon y Team
|- poke_api.dart      # Peticiones, paginacion y cache en memoria
`- trainer_store.dart # Favoritos y equipos persistentes
```

### Infinite scrolling

1. La pantalla solicita bloques de 24 Pokemon mediante `limit=24&offset=<cantidad cargada>`.
2. Un `ScrollController` anticipa la siguiente pagina cuando faltan 500 px para el final.
3. La bandera `loading` evita peticiones duplicadas si el usuario desplaza rapidamente.
4. Los detalles de cada bloque se resuelven en paralelo con `Future.wait`.
5. `GridView.builder` construye solamente los elementos visibles.
6. El repositorio mantiene una cache en memoria por ID y ofrece reintento sin borrar lo ya cargado cuando falla la red.

## Requisitos

- Flutter 3.47.9 o compatible.
- Android SDK 36 para generar el APK.
- Conexion a Internet para consultar PokeAPI y cargar las imagenes.

## Ejecucion

```powershell
flutter pub get
flutter run
```

Para elegir un destino concreto:

```powershell
flutter run -d <device-id>
flutter run -d edge
```

## Generar el APK

```powershell
flutter build apk --release
```

El resultado se crea en `build/app/outputs/flutter-apk/app-release.apk`.

## Evidencias

### Version web/escritorio

![RutaDex en escritorio](evidencias/rutadex-escritorio.png)

### Version movil

Pendiente: agregar `evidencias/rutadex-android.png` con una captura vertical tomada durante la grabacion.

## APK

[Descargar RutaDex para Android desde la ultima publicacion](../../releases/latest)

## Creditos

- Datos e imagenes: [PokeAPI](https://pokeapi.co/).
- Pokemon y sus nombres pertenecen a Nintendo, Game Freak y The Pokemon Company. Proyecto academico sin fines de lucro.
