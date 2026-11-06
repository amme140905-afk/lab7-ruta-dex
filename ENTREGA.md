# Guia de grabacion y entrega - RutaDex

## Video 1: explicacion del infinite scrolling (maximo 2 minutos)

### Guion sugerido

> En RutaDex el catalogo no descarga todos los Pokemon de golpe. La aplicacion solicita paginas de 24 elementos usando los parametros limit y offset de PokeAPI. El offset corresponde a la cantidad que ya se encuentra cargada.
>
> La pantalla usa un ScrollController. Cuando el usuario queda a menos de 500 pixeles del final, se solicita anticipadamente la pagina siguiente, de forma que la espera casi no se percibe.
>
> Una bandera llamada loading evita que el desplazamiento rapido dispare peticiones duplicadas. La API primero devuelve nombres y URLs; despues los detalles de los 24 Pokemon se consultan en paralelo con Future.wait. Los resultados tambien se guardan en una cache en memoria por ID.
>
> Para cuidar el rendimiento, GridView.builder crea las tarjetas conforme son necesarias. Si ocurre un error de red, se conserva lo ya cargado y aparece un boton para reintentar. Probe como alternativas cargar todo el catalogo y pedir detalles de forma secuencial, pero ambas opciones aumentaban el tiempo inicial y la cantidad de trabajo innecesario.

### Tomas recomendadas

1. Mostrar `poke_api.dart`, especialmente `limit=24`, `offset` y `Future.wait`.
2. Mostrar `main.dart`, en `DexPage`, senalando el `ScrollController`, el umbral de 500 px y `loading`.
3. Cerrar con una demostracion corta desplazando varias paginas.

## Video 2: demo funcional (maximo 5 minutos)

### Orden sugerido

1. **Android:** abrir RutaDex y recorrer el catalogo para evidenciar el infinite scrolling.
2. Abrir un Pokemon y mostrar grito, artwork, datos, radar de estadisticas, evolucion, movimientos y shiny.
3. Buscar por nombre o numero y aplicar filtros de tipo y generacion.
4. Marcar un favorito.
5. Crear un equipo, nombrarlo y agregar hasta seis Pokemon; cerrar y reabrir para demostrar persistencia.
6. **Web/escritorio:** mostrar la misma aplicacion adaptada a una ventana amplia.
7. Cerrar ensenando la pantalla de favoritos y el APK instalado.

## Lista antes de entregar

- [ ] Subir todo el proyecto a GitHub.
- [ ] Confirmar que `evidencias/rutadex-escritorio.png` se vea en el README.
- [ ] Sustituir `evidencias/rutadex-android.png` con una captura vertical real.
- [ ] Subir los dos videos y pegar sus enlaces donde solicite el profesor.
- [ ] Adjuntar `release/RutaDex-v1.0.0.apk` a una GitHub Release (no al repositorio, porque el APK de depuracion supera el limite de 100 MB).
- [ ] Probar el APK en un telefono Android antes de enviar el enlace.
