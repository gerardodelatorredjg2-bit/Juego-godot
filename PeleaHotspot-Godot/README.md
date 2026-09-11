# Pelea Hotspot (Godot 4.4+)

> **Carpeta única:** todo el proyecto está dentro de `PeleaHotspot-Godot/`. Abre directamente `PeleaHotspot-Godot/project.godot` en Godot; no se incluye ningún archivo binario ni paquete comprimido.

Proyecto base de pelea 3D **1 vs. 1** hecho enteramente con GDScript y primitivas de Godot. No requiere recursos externos.

## Abrir y jugar

1. Abre `project.godot` con Godot **4.4 o superior** y ejecuta el proyecto.
2. Para jugar mediante hotspot/LAN, en el primer dispositivo pulsa **Crear partida**.
3. Averigua la IP local del anfitrión (por ejemplo, `192.168.x.x`). En el segundo dispositivo, introdúcela y pulsa **Unirse a partida**.
4. Ambos equipos deben estar en la misma red. El puerto UDP utilizado es **7000**; permite ese puerto en el firewall si fuese necesario.

También hay **Jugar local**, para dos jugadores en el mismo teclado:

| Acción | Jugador 1 | Jugador 2 local |
|---|---|---|
| Mover | A / D | J / L |
| Saltar | W | I |
| Atacar | F | O |
| Bloquear | G | P |

En LAN, cada dispositivo usa los controles del jugador 1 (A/D/W/F/G); el host asigna el primer jugador y el cliente el segundo.

## Arquitectura

- `NetworkManager.gd` crea `ENetMultiplayerPeer` como servidor o cliente y detecta desconexiones.
- El **host es la autoridad** de todos los luchadores. Los clientes envían entradas y reciben posición, rotación, vida, ataque y bloqueo sincronizados.
- El daño, creación de luchadores, rondas y resultado usan RPC fiables con `call_local` para que el host ejecute la misma acción.
- Un combate es mejor de tres rondas. Cada luchador es una `CharacterBody3D` con `CapsuleMesh`; el escenario usa `BoxMesh`.

## Reemplazar placeholders

Sustituye el `BodyMesh` de `escenas/Jugador.tscn` por tu modelo y conserva `CollisionShape3D` y `scripts/Jugador.gd`. Las acciones están definidas en `project.godot`, por lo que se pueden remapear desde **Proyecto → Ajustes del proyecto → Mapa de entradas**.

## Modo Compatibilidad

El proyecto usa explícitamente el renderizador **GL Compatibility** tanto en escritorio como en móvil (`renderer/rendering_method` y `renderer/rendering_method.mobile`). Esto prioriza OpenGL 3/WebGL 2 para que pueda abrirse en teléfonos y equipos de menor potencia. El escenario también evita sombras en tiempo real y materiales metálicos, reduciendo el coste gráfico.

## Controles móviles y sala LAN

En Android/iOS el juego se fuerza a orientación horizontal y muestra controles táctiles multitáctiles: movimiento a la izquierda, derecha, salto, ataque y bloqueo. Cada teléfono controla su propio luchador; para dos personas se recomienda una partida por hotspot/LAN.

Al pulsar **Crear partida**, el menú muestra las direcciones IPv4 LAN detectadas y el puerto. Comparte una de esas IP con la otra persona; el botón **Copiar IP** la deja en el portapapeles y **Iniciar combate** permite al anfitrión empezar cuando quiera. Si el cliente ya estaba conectado, aparecerá al iniciar el combate.

## Estructura de entrega

Todos los archivos editables del juego están reunidos en esta única carpeta: escenas, scripts, recursos, interfaz, configuración y esta guía. No se versiona ningún `.zip` ni otro binario, evitando problemas al actualizar el repositorio.

## Pantalla, escenario y audio

- El juego abre a **pantalla completa**, permite redimensionar y usa `stretch/aspect = "expand"` para aprovechar pantallas anchas, altas y resoluciones distintas.
- La escena de combate está en `escenas/Juego.tscn`. Su cámara ortográfica recalcula el encuadre cuando cambia el tamaño de la ventana para mantener la plataforma completa visible.
- Los botones táctiles tienen bordes, estados pulsado/normal y una pequeña animación de escala; no dependen de imágenes externas.
- La música de fondo y los tonos de impacto/ronda se sintetizan por código con `AudioStreamGenerator`, por lo que no hay archivos de audio binarios que bloqueen actualizaciones.

## Modelos y animaciones

El proyecto conserva personajes de cápsula para que siga siendo ligero y compatible. Puedo integrar modelos 3D y animaciones que sean de uso permitido si proporcionas los archivos o indicas una fuente/licencia concreta; para producción conviene usar personajes con esqueleto (`Skeleton3D`), `AnimationPlayer` y animaciones de reposo, caminar, salto, ataque, bloqueo y derrota. Si Godot muestra un error, copia aquí el texto completo y la línea indicada: así se puede corregir exactamente la causa.
