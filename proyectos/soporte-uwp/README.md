# Soporte de apps modernas de Windows (UWP / MSIX / WinRT) en windows-like

> Carpeta de proyecto propio. Motivo: a junio 2026, tras investigar internet,
> **nadie está construyendo soporte UWP/WinUI 3 completo para Wine**. Lo único
> activo es WinRT *parcial para juegos* (fork WineGDK/Weather-OS). Las apps XAML
> modernas (p. ej. el Bloc de notas de Windows 11) quedan fuera del alcance de
> cualquier proyecto libre existente. Aquí planificamos qué SÍ podemos lograr.

## Veredicto de viabilidad (resumen de la investigación)

| Nivel | Qué cubre | Viabilidad | Decisión |
|-------|-----------|-----------|----------|
| **0** | Desempaquetar `.msix`/`.appx` (es OPC/ZIP) + lanzar el `.exe` Win32 del manifiesto | Alta, factible HOY | **OBJETIVO** |
| **1** | Activación WinRT *no-UI* sin AppContainer (técnica Undocked RegFree WinRT) | Media, acotada | Explorar |
| **2** | Windows.UI.Xaml / Microsoft.UI.Xaml (WinUI 3) completo + AppContainer | Casi imposible en solitario | **Descartado** |

El cuello de botella NO es MSIX (un simple ZIP), sino **WinUI 3 + AppContainer**,
un framework de UI entero sin reimplementación libre. Por eso apuntamos al Nivel 0
(la mayoría de MSIX empaquetan ejecutables Win32 o híbridos que sí corren en Wine)
y exploramos el Nivel 1 para componentes WinRT acotados.

## Estado del arte en Wine (jun 2026)

- `combase.dll`: ~53% de funciones; activación WinRT (`RoActivateInstance`,
  `RoGetActivationFactory`) en estado *semi-stub* (`combase/roapi.c` + parches
  wine-staging `combase-RoApi`).
- Metadata `.winmd` vía `widl --winmd`/`--winrt`: inicial en Wine 11; falta MIDL 3.0
  completo y leer `.winmd` del sistema (Bug 53905).
- Excepciones WinRT C++: soportadas desde Wine 10.19 / 11.
- WinRT de juegos (`Windows.Gaming.Input`, GDK): único módulo WinRT real, en el
  fork **WineGDK** (no aborda UWP/WinUI3).
- Despliegue AppX/MSIX, AppContainer, firma de paquetes: **no implementados**.
  Bottles cerró la petición de MSIX como "fuera de alcance, es asunto de Wine".

Fuentes completas en [`investigacion.md`](investigacion.md).

## Metodología

- **Iterativo-incremental**: cada iteración entrega funcionalidad ejecutable y se
  **valida** antes de seguir (criterio de salida explícito por iteración).
- **Paralelismo**: los paquetes de trabajo marcados con el mismo carril `‖A`/`‖B`/`‖C`
  pueden ejecutarse a la vez (sin dependencias cruzadas). Los marcados `→` son
  secuenciales (dependen del anterior).
- Ver la **EDT/WBS de 5 niveles** en [`WBS.md`](WBS.md).
- Ver el **detalle de ejecución por actividad** (cómo, herramientas, criterios `[V]`)
  y los **Requisitos No Funcionales** (compatibilidad, estabilidad, rendimiento, bajo
  consumo, ultrarendimiento) en [`actividades-detalle.md`](actividades-detalle.md).

## Iteraciones (roadmap de alto nivel)

1. **It-1 (Nivel 0 mínimo)**: desempaquetar un `.msix` y lanzar su `.exe` Win32.
   *Validación*: una app MSIX Win32-pura abre en el windows-like.
2. **It-2 (Nivel 0 robusto)**: parsear `AppxManifest.xml`, resolver dependencias
   de `Framework` packages, registrar accesos en el menú Inicio.
   *Validación*: 3 apps MSIX distintas instalan y aparecen en el menú.
3. **It-3 (Nivel 1 exploratorio)**: activar un componente WinRT no-UI vía manifest
   Undocked RegFree WinRT. *Validación*: una llamada WinRT de almacenamiento/red
   responde sin AppContainer.
4. **It-4 (límites)**: documentar qué apps fallan y por qué (WinUI3/AppContainer),
   cerrando el alcance. *Validación*: matriz de compatibilidad publicada.
