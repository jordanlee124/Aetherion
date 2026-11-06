# Sprint 001 — movement foundation

## Implemented

- Godot 4 GDScript project using Compatibility rendering for Windows/web.
- 640×360 internal viewport, 1280×720 initial window, aspect-preserving integer scaling.
- Keyboard run, jump, one air jump, 100 ms coyote window and 120 ms jump buffer.
- Acceleration, braking, early-release short hops, terminal fall speed.
- Cinderhaven test yard: solid floor, two boundary walls, seven one-way catwalks, a fall gap and automatic/manual respawn.
- Tracking Camera2D with smoothing, world limits and immediate recenter on respawn.
- F1 overlay: FPS, ground state, position, velocity, jump count and grace/buffer timers.
- Dependency-free headless tests and Windows/Web export presets.
- Geometric placeholder art only; no downloaded assets.

## Provisional tuning

| Setting | Value |
| --- | --- |
| Run speed | 180 px/s |
| Acceleration / braking | 1400 / 1800 px/s² |
| Gravity | 1100 px/s² |
| Jump impulse | 480 px/s upward |
| Fall speed cap | 600 px/s |
| Coyote / buffer | 0.10 / 0.12 s |
| Early jump release | Upward velocity × 0.45 |

Values are exported on the Player scene's script. Leaving a ledge after grace expires leaves one air jump. A press uses an available air jump immediately; when both jumps are spent, a press within the buffer window before landing triggers a new ground jump. Holding jump does not repeat it. Landing resets jump count. Cyan catwalk tops are one-way; brass ground is solid. Drop-through controls are outside this sprint.

## Acceptance checks

Automated: movement cap and braking; ground/double/blocked third jumps; coyote allowance and expiry; valid and expired jump buffers; early release; terminal velocity; reset state at both 60 and 120 Hz. Scene integration drives actual input and physics to check movement, one-way pass-through and landing, respawn, camera and overlay wiring, viewport and action configuration.

Manual feel check: run to the right, jump through the first cyan catwalk, double jump up the staircase, cross the gap, return left, fall into the gap, press R mid-jump, toggle F1, resize the window. Check camera limits at both ends. Try short taps and full held jumps. Browser builds also need a real-browser check after export: focus canvas, exercise the same controls, inspect console and resize.

Combat, enemies, animation assets, sound, save data and progression are future work. This sprint preserves the GDD rather than implementing those systems.
