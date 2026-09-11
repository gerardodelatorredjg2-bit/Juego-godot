# Pelea Hotspot (Godot 4.4+)

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
