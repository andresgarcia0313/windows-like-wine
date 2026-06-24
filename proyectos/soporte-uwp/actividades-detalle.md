# Detalle de actividades — Soporte UWP/MSIX con ultrarendimiento

> Complemento operativo de [`WBS.md`](WBS.md). El WBS da el *árbol* de actividades
> atómicas (qué); este documento da el *cómo* de cada hoja, más los Requisitos No
> Funcionales (RNF) transversales que el objetivo exige: **máxima compatibilidad,
> estabilidad, rendimiento, bajo consumo de hardware y ultrarendimiento**.
> Hardware objetivo: Lenovo IdeaPad (Intel Iris Xe, Vulkan), recursos acotados.

---

## 1. Requisitos No Funcionales transversales (los pilares)

Estos RNF aplican a TODA actividad. Cada actividad del bloque 4 referencia los que
le tocan con su etiqueta `[C][E][R][B][U]`.

### [C] Compatibilidad máxima
- **No tocar el prefix windows-like** (win64 + Wine Mono): toda la lógica MSIX vive
  en un wrapper externo (`wl-msix`) y carpetas dedicadas (`C:\msix\`), no parchea Wine.
- **Degradación elegante por capas**: si una app es Win32-pura -> abre; si depende de
  WinUI3/AppContainer -> diagnóstico claro + recomendación de equivalente Win32. Nunca
  un fallo opaco.
- **Reutilizar runtimes ya instalados** (scripts 03/12: vcrun, dotnetdesktop8, quartz,
  xact, dxvk, vkd3d) en vez de reempaquetar dependencias por app.
- **Corpus de prueba representativo** (5+ MSIX de clases distintas) como contrato de
  compatibilidad medible, no anecdótico.

### [E] Estabilidad
- **Idempotencia**: instalar/reinstalar/desinstalar deja el sistema en estado
  determinista, sin residuos (índice de instalación + limpieza verificada).
- **Aislamiento de fallos (jidoka)**: cada paso valida su precondición; si rompe, para
  y reporta, no propaga corrupción. `set -euo pipefail` en todo script.
- **Atomicidad**: extracción a carpeta temporal -> validación -> `mv` atómico al destino
  final. Nunca dejar instalaciones a medias.
- **Logs de evento** (preferencia del usuario): `log()` a stdout + `/tmp/wl-msix.log`
  con timestamps, estado ANTES/DURANTE/diagnóstico-si-rompe.

### [R] Rendimiento
- **`WINEDEBUG=-all`** en todo lanzamiento: elimina el overhead de logging de Wine.
- **DXVK + vkd3d-proton** (ya instalados) traducen D3D9/11/12 a Vulkan sobre Iris Xe:
  menos CPU y mejor frame pacing que wined3d.
- **Caché de shaders persistente**: `DXVK_STATE_CACHE_PATH` y `VKD3D_SHADER_CACHE`
  apuntando a `C:\msix\_cache` -> evita recompilar shaders en cada arranque.
- **wineserver persistente** (`wineserver -p`): mantener el server vivo entre lanzados
  reduce el cold-start del segundo arranque en adelante.

### [B] Bajo consumo de hardware
- **Dedup de framework packages**: una sola copia compartida de VCLibs/WinAppSDK en
  `C:\msix\_frameworks` para TODAS las apps -> menos disco, menos page-cache, menos IO.
- **Extracción en streaming**: descomprimir el MSIX leyendo el ZIP en flujo (libarchive/
  bsdtar), sin cargar el paquete entero en RAM ni duplicarlo en disco.
- **Extracción selectiva**: extraer solo lo que el manifiesto referencia como ejecutable
  + assets necesarios, no el paquete completo si no hace falta.
- Respetar la config de RAM del equipo (zram + swappiness): el wrapper no debe mantener
  procesos residentes; termina cuando la app termina.

### [U] Ultrarendimiento (modo on-demand, opt-in)
- **esync/fsync**: `WINEESYNC=1`/`WINEFSYNC=1` (kernel 7.0 trae futex2/FUTEX_WAIT_MULTIPLE)
  -> sincronización en espacio de usuario, baja drásticamente el uso de CPU del wineserver.
- **CPU governor performance** puntual durante el arranque pesado (revertir al terminar);
  el equipo gestiona energía manualmente, así que es opt-in con flag, no por defecto.
- **Preload de combase/wintypes** para apps con WinRT no-UI: evita el coste de resolución
  en frío de la activación.
- **Huge pages transparentes** solo si se mide beneficio (no asumir).

> Regla de oro de rendimiento: **medir antes y después** (sección 5). Ninguna táctica se
> da por buena sin número. "Debería ser más rápido" no cuenta.

---

## 2. Stack de implementación (decisiones)

| Componente | Tecnología elegida | Por qué (RNF) |
|------------|--------------------|---------------|
| Extracción MSIX | `bsdtar`/libarchive (streaming) con fallback `python -m zipfile` | [B] streaming sin doble copia; [C] libarchive lee OPC/ZIP estándar |
| Parser AppxManifest.xml | `python` stdlib `xml.etree` (sin deps externas) | [E] cero dependencias frágiles; [C] namespaces AppX bien soportados |
| Orquestación/lanzador | `bash` (`set -euo pipefail`) | [E] idempotencia y logs simples; integra con scripts 01-13 existentes |
| Accesos menú Inicio | reusar `CreateLnk.exe` del script 08 | [C] no reinventar; consistente con el resto del entorno |
| Activación WinRT (It-3) | Undocked RegFree WinRT (`<exe>.manifest` + winrtact) | [C] no requiere AppContainer; acotado y reversible |

Principio: **KISS + reutilización**. El cuello de botella de rendimiento es la *app en
Wine*, no el wrapper; por eso el wrapper se mantiene mínimo y la energía se invierte en
la configuración de Wine (sección 1, RNF [R][U]).

---

## 3. Carpetas y contrato de datos

```
C:\msix\
├── _frameworks\        # framework packages COMPARTIDOS (dedup) -> [B]
├── _cache\             # DXVK_STATE_CACHE + VKD3D_SHADER_CACHE -> [R]
├── _index.json         # registro de apps instaladas (para limpieza idempotente) -> [E]
└── <AppId>\            # una carpeta por app: payload extraído + <exe>.manifest
```

`_index.json` (contrato): `{ appId, displayName, exe, frameworks[], lnk, installedAt }`.
Es la fuente de verdad para desinstalar sin residuos.

---

## 4. Detalle por actividad (mapeo 1:1 con las hojas del WBS)

Formato: **ID WBS — objetivo — técnica concreta — entregable — `[V]` criterio — RNF**.

### Fase 1.1 — Investigación y fundamentos `‖A`

- **1.1.1.1.x Cobertura combase/WinRT** — inventariar funciones implementadas vs stub.
  Técnica: `winedump` sobre `combase.dll` del prefix + cruce con `combase/roapi.c` upstream
  y parches `wine-staging/combase-RoApi`. Entregable: tabla función->estado. `[V]`
  `RoActivateInstance` activa una clase de prueba propia. RNF: [C].
- **1.1.1.2.x Metadata .winmd** — compilar `widl --winmd` en el host, generar `.winmd` de
  un `.idl` mínimo, verificar que Wine lo lee. `[V]` Wine resuelve el tipo del .winmd. RNF: [C].
- **1.1.2.1.x Anatomía MSIX** — `bsdtar -tf app.msix` lista el OPC; mapear `AppxManifest.xml`
  (Identity, Dependencies, Applications); localizar `<Application Executable=...>`. `[V]`
  entrypoint identificado. RNF: [C][B] (listar sin extraer = cero IO innecesario).
- **1.1.2.2.x Clasificación por UI** — heurística: si el manifiesto declara
  `EntryPoint="Windows.FullTrustApplication"` o un `Executable` .exe -> candidato Win32; si
  declara framework `Microsoft.UI.Xaml`/WinAppSDK como dependencia dura -> WinUI3 (riesgo).
  Entregable: corpus etiquetado de 5+ MSIX. `[V]` corpus reproducible. RNF: [C].

### Iteración 1 — MSIX unpack + launch (Nivel 0 mínimo) `→`

- **1.2.1.1.x CLI de extracción** — `wl-msix extract`: `bsdtar -xf` en streaming a carpeta
  temporal; aviso (no bloqueo) si `AppxSignature.p7x`/`AppxBlockMap.xml` no validan. `[V]`
  extrae sin pérdida (comparar conteo y hash de entradas). RNF: [B][E].
- **1.2.1.2.x Parser de manifiesto** — `python xml.etree`: leer `Executable`/`EntryPoint`,
  resolver rutas relativas al raíz del paquete. `[V]` entrypoint correcto en 3 paquetes.
  RNF: [E].
- **1.2.2.1.x Lanzador** — `mv` atómico a `C:\msix\<AppId>`, exportar
  `WINEDEBUG=-all DXVK_STATE_CACHE_PATH=... VKD3D_SHADER_CACHE=...`, lanzar el `.exe` con
  Wine. `[V]` una app MSIX Win32-pura ABRE en el windows-like. RNF: [C][R][E].
- **1.2.2.2.x Diagnóstico de fallo** — capturar `err:module` (DLL ausente) y fallos de
  activación WinRT del log; clasificar causa (Win32 OK / falta runtime / WinUI3 / AppContainer);
  reporte legible. `[V]` el reporte nombra la causa real. RNF: [E][C].

### Iteración 2 — MSIX robusto + integración (Nivel 0 robusto) `→`

- **1.3.1.1.x Resolución de dependencias `‖B`** — parsear `<PackageDependency Name=.. MinVersion=..>`;
  mapear VCLibs/WinAppSDK a los runtimes ya instalados (scripts 03/12). `[V]` app con VCLibs
  resuelve. RNF: [C].
- **1.3.1.2.x Almacén de frameworks `‖B`** — `C:\msix\_frameworks` compartido + dedup por
  (Name,Versión): si ya existe, no recopiar. `[V]` dos apps comparten un framework (una sola
  copia en disco). RNF: [B] (este es el mayor ahorro de disco/RAM del proyecto).
- **1.3.2.1.x Accesos menú Inicio `‖C`** — leer `VisualElements` (DisplayName, Square44/150
  logo), generar `.lnk` con `CreateLnk.exe`. `[V]` 3 apps MSIX en el menú. RNF: [C].
- **1.3.2.2.x Desinstalación `‖C`** — `wl-msix remove` lee `_index.json`, borra payload +
  `.lnk`, conserva frameworks aún referenciados por otras apps. `[V]` instalar/desinstalar sin
  residuos (verificado con diff de árbol). RNF: [E][B].

### Iteración 3 — WinRT regfree no-UI (Nivel 1 exploratorio) `→`

- **1.4.1.1.x Undocked RegFree WinRT `‖B`** — generar `<exe>.manifest` con `<activatableClass>`,
  desplegar `winrtact.dll` junto al exe. `[V]` activa un tipo WinRT propio sin AppContainer.
  RNF: [C][U] (preload combase para no pagar resolución en frío).
- **1.4.1.2.x Componentes WinRT del sistema `‖B`** — probar `Windows.Storage`/`Windows.Networking`
  (no-UI); documentar cuáles responden en Wine 11. `[V]` una llamada WinRT no-UI responde. RNF: [C].
- **1.4.2.x Contribución upstream (opcional) `‖C`** — aislar API faltante en caso mínimo, abrir
  bug WineHQ con evidencia reproducible, opcional parche stub a wine-devel. `[V]` bug enlazado /
  parche enviado. RNF: [C] (mejora la base para todos).

### Iteración 4 — Límites, matriz y cierre `→`

- **1.5.1.1.x Matriz de compatibilidad `‖A`** — ejecutar el corpus completo, registrar
  abre/parcial/falla+causa, publicar matriz en `docs/`. `[V]` matriz publicada. RNF: [C][R]
  (incluir tiempo de arranque y RAM pico por app -> evidencia de rendimiento).
- **1.5.1.2.x Casos WinUI3/AppContainer `‖A`** — confirmar fallo del Bloc de notas Win11,
  documentar el equivalente Win32 recomendado, cerrar alcance con justificación. `[V]` alcance
  cerrado. RNF: [C].
- **1.5.2.x Empaquetado como fase del repo `‖A`** — integrar `wl-msix` como `scripts/14-msix.sh`,
  actualizar CHANGELOG (SemVer) + README, instalación end-to-end desde cero, regenerar backup
  dorado (`99-backup.sh`) y commit final. `[V]` reproducible end-to-end con backup. RNF: [E].

---

## 5. Plan de rendimiento dedicado (presupuestos y medición)

| Métrica | Presupuesto objetivo | Cómo se mide |
|---------|----------------------|--------------|
| Tiempo de extracción de un MSIX de ~100 MB | < 3 s | `time wl-msix extract` |
| Cold-start de la app (1er lanzamiento) | < 5 s a ventana visible | `time` + marca de ventana (`xdotool search`) |
| Warm-start (2.º lanzamiento, wineserver vivo) | < 2 s | idem con `wineserver -p` activo |
| RAM pico del wrapper (sin la app) | < 50 MB | `/usr/bin/time -v` campo Maximum RSS |
| Disco extra por app que comparte frameworks | solo su payload propio | `du -sh` antes/después con dedup |
| Uso de CPU del wineserver en idle de la app | medible y menor con fsync | `pidstat -p $(pgrep wineserver)` con/sin `WINEFSYNC` |

Protocolo: medir baseline (sin optimizaciones) -> aplicar táctica -> volver a medir ->
conservar solo si mejora. Registrar en `docs/benchmarks.md`. **Cero optimización a ciegas.**

---

## 6. Estabilidad — matriz de fallos y mitigación

| Fallo posible | Causa | Mitigación |
|---------------|-------|------------|
| App MSIX no abre, sin mensaje | dependencia WinUI3/AppContainer | Diagnóstico clasificado (1.2.2.2) + recomendar equivalente Win32 |
| Instalación a medias tras corte | extracción no atómica | Temp -> validación -> `mv` atómico (RNF [E]) |
| Residuos tras desinstalar | borrado parcial | `_index.json` como fuente de verdad + diff de árbol en test |
| Framework duplicado infla disco | sin dedup | Almacén compartido por (Name,Versión) (1.3.1.2) |
| Shaders se recompilan cada arranque | caché volátil | `DXVK_STATE_CACHE`/`VKD3D_SHADER_CACHE` persistente |
| Regresión al actualizar Wine | cambios upstream | Corpus + matriz como test de regresión antes de adoptar nueva versión |

---

## 7. Observabilidad

- `wl-msix` escribe `log()` con timestamp a stdout y `/tmp/wl-msix.log` (estado ANTES,
  éxito/fallo DURANTE, diagnóstico si rompe). Preferencia confirmada del usuario para
  operaciones que modifican el sistema.
- Cada `[V]` deja evidencia (salida de test) archivable, no solo "pasó/falló".

---

## 8. Control de cambios

| Versión | Fecha | Autor | Descripción |
|---------|-------|-------|-------------|
| 1.0 | 2026-06-24 | Andrés García | Detalle inicial de actividades con RNF de compatibilidad, estabilidad, rendimiento, bajo consumo y ultrarendimiento, mapeado 1:1 al WBS de 5 niveles. |
