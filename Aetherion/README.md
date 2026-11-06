# Aetherion — Sprint 001

A playable movement foundation in a placeholder Cinderhaven test yard. Standard **Godot 4.3+**, GDScript, no plugins. Validated locally with **Godot 4.7.2**; older supported versions have not been exercised.

## Play

Import `project.godot` into Godot and press **F6** on `scenes/cinderhaven.tscn`, or **F5** to run the project.

| Key | Action |
| --- | --- |
| A / D or Left / Right | Run |
| Space / W / Up | Jump, then jump again in air |
| Release jump early | Short hop |
| R | Respawn |
| F1 | Toggle debug overlay |

Cyan platforms can be jumped through from below and landed on from above. The gap resets you automatically. Explore to the right to test camera tracking and double-jump spacing.

## Tests

From this `Aetherion` folder in PowerShell, set `$godot` to your standard Godot console executable. If installed through WinGet and on PATH:

```powershell
$godot = (Get-Command 'Godot*_console.exe' | Select-Object -First 1).Source
& $godot --headless --path . --editor --import --quit
& $godot --headless --path . --script res://tests/run_tests.gd
if ($LASTEXITCODE -ne 0) { throw 'Sprint 001 tests failed' }
```

The test script exits 1 on failure, 0 on success. It checks movement logic at 60/120 Hz and runs the real scene with physics and scripted input. No test framework installation is needed.

To capture a rendered preview, run `& $godot --path . --script res://tests/capture_preview.gd`. It saves `builds/sprint_001.png` and closes automatically.

Validation on 6 November 2026: **46 checks passed** on Godot 4.7.2, the Compatibility-rendered preview was inspected, and an exported resource pack launched successfully for a 120-frame smoke check. Editor operations reported an editor-settings safe-save warning in the restricted execution environment; game tests, rendering and the final packed-project launch completed successfully. Full Windows executable and browser exports have not been run because matching export templates are absent; browser behavior remains to be verified after export.

## Windows export

1. In **Editor → Manage Export Templates**, install templates matching your exact Godot editor version. Templates are not bundled here.
2. Open **Project → Export → Windows Desktop**. The preset targets x86_64, unsigned, with a separate PCK.
3. Create `builds/windows`, then export to `builds/windows/Aetherion.exe`.
4. Distribute the executable and its sibling `.pck` together. Launch it on Windows and repeat the manual checks in [Sprint 001](docs/Sprint_001.md).

Equivalent command (after installing templates):

```powershell
New-Item -ItemType Directory -Force builds/windows | Out-Null
& $godot --headless --path . --export-release 'Windows Desktop' builds/windows/Aetherion.exe
if ($LASTEXITCODE -ne 0) { throw 'Windows export failed' }
```

Resource modification is disabled so this prototype does not require an external executable resource editor. Production signing and custom executable branding can be configured later.

## Web export

1. Install the matching export templates as above.
2. Choose **Project → Export → Web** and export to `builds/web/index.html`. The preset uses Compatibility, with thread and extension support disabled.
3. Serve the entire output directory using HTTP locally or HTTPS when deployed. Do not open the HTML through `file://`, rename generated files, or upload only the HTML.
4. Open in a desktop browser with WebAssembly and WebGL 2.0. Click the game canvas to focus keyboard input. Resize and repeat the movement checks; inspect the browser console for errors.

```powershell
New-Item -ItemType Directory -Force builds/web | Out-Null
& $godot --headless --path . --export-release 'Web' builds/web/index.html
if ($LASTEXITCODE -ne 0) { throw 'Web export failed' }
# If Python is installed:
python -m http.server 8060 --bind 127.0.0.1 --directory builds/web
# Open http://localhost:8060 in your browser. Ctrl+C stops the server.
```

Single-threaded web export avoids the cross-origin isolation headers required by threaded builds. These settings follow the official [web export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) and [Windows export guide](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html).

## Project map and design preservation

- `scenes/player.tscn`, `scripts/player.gd`: player body, camera, movement tuning.
- `scenes/cinderhaven.tscn`, `scripts/cinderhaven.gd`: test map, collisions, respawn, HUD and placeholder drawing.
- `tests/run_tests.gd`: automated acceptance tests, excluded from exports.
- `docs/Aetherion_GDD_v1.1.md`: recovered design decisions, explicitly distinguished from the unavailable original GDD.
- `docs/Seven_Fractures_recovered.md`: recovered story with approved naming updates.
- `docs/Sprint_001.md`: scope, tuning and manual checks.

No original GDD file was available to edit. The established world, characters, story progression and rewards are retained as recovered design context. This sprint does not implement combat or progression.
