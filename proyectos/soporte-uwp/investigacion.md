# Investigación: estado de UWP / MSIX / WinRT en Wine (junio 2026)

## Veredicto

**Nadie está construyendo soporte UWP/WinUI 3 completo para Wine.** El único
trabajo WinRT activo y relevante (fork **WineGDK** de Weather-OS) es para juegos
GDK, no para apps XAML. Bottles cerró la petición de MSIX/UWP como "fuera de
alcance, es asunto de Wine". No hay fork tipo "Boxedwine-uwp", ni reimplementación
libre de Windows.UI.Xaml, ni roadmap público de CrossOver/CodeWeavers o Proton/Valve
hacia UWP/WinUI 3.

## Tabla de componentes

| Componente | Estado en Wine (jun 2026) | Quién | Bloqueador | Enlace |
|---|---|---|---|---|
| combase.dll (núcleo COM/WinRT) | Parcial ~53% | Wine upstream | Cobertura incompleta | https://source.winehq.org/WineAPI/combase.html |
| Activación WinRT (RoActivateInstance/RoGetActivationFactory) | semi-stub | Wine + wine-staging | No existe modelo de paquete | https://github.com/wine-mirror/wine/blob/master/dlls/combase/roapi.c |
| Metadata .winmd (widl) | Inicial en Wine 11 | Wine upstream | Falta MIDL 3.0 completo | https://list.winehq.org/archives/list/wine-bugs@list.winehq.org/thread/KIK3J635RFDNQDCLUY26X72JZWW2IMKO/ |
| Excepciones WinRT C++ | OK desde Wine 10.19/11 | Wine upstream | resuelto | https://www.gamingonlinux.com/2026/01/windows-compatibility-layer-wine-11-arrives-bringing-masses-of-improvements-to-linux/ |
| WinRT de juegos (Windows.Gaming.Input, GDK) | Funcional en fork | WineGDK/Weather-OS | XUser sin implementar | https://github.com/Weather-OS/WineGDK |
| Windows.UI.Xaml / Microsoft.UI.Xaml (WinUI 3) | **No implementado** | Nadie | Framework de UI entero | https://learn.microsoft.com/en-us/windows/apps/winui/winui3/ |
| Despliegue AppX/MSIX | **No soportado** (workaround: extraer con 7z) | Nadie (Bottles lo rechazó) | Sin deployment stack | https://github.com/bottlesdevs/Bottles/issues/3350 |
| AppContainer / Package SID | **No implementado** | Nadie | Modelo de token de seguridad | https://learn.microsoft.com/en-us/windows/win32/secauthz/implementing-an-appcontainer |
| Undocked RegFree WinRT (activación sin paquete) | Técnica MS (xlang) | Microsoft | Solo tipos definidos por el dev | https://github.com/microsoft/xlang/blob/master/src/UndockedRegFreeWinRT/README.md |

## Bloqueadores, de mayor a menor dificultad

1. **WinUI 3 / Microsoft.UI.Xaml completo** — casi imposible en solitario. El Bloc
   de notas de Win11 lo exige (`Microsoft.UI.Windowing.Core.dll`).
2. **AppContainer / tokens de seguridad** (Package SID + capability SIDs).
3. **Deployment stack AppX/MSIX** (registro de paquetes).
4. **Activación WinRT genérica fiable** — ruta viable acotada: Undocked RegFree WinRT.
5. **combase incompleto + Windows.Foundation parcial** — trabajo incremental en curso.
6. **widl / MIDL 3.0 + .winmd** — el menos duro, progreso activo.

## Conclusión

Construir UWP/WinUI 3 completo NO es viable para un proyecto pequeño. El subconjunto
con valor inmediato es el **Nivel 0: desempaquetar el `.msix` (es OPC/ZIP), leer
`AppxManifest.xml` y lanzar el `.exe` Win32 del manifiesto**. Para apps puramente
WinUI 3 (Notepad de Win11), la alternativa práctica sigue siendo el equivalente
Win32 clásico o nativo Linux.

## Fuentes adicionales

- GDK-Proton: https://github.com/Weather-OS/GDK-Proton
- wine-staging combase-RoApi: https://github.com/wine-compholio/wine-staging/blob/master/patches/combase-RoApi/
- Winetricks #2225 (instalar .appx): https://github.com/Winetricks/winetricks/issues/2225
- WineHQ forum (MSIX sin soporte): https://forum.winehq.org/viewtopic.php?t=36815
- Wine 10.19 (reparse points + WinRT): https://www.linuxjournal.com/content/wine-1019-released-game-changing-support-windows-reparse-points-linux
- MSIX supported platforms: https://learn.microsoft.com/en-us/windows/msix/supported-platforms
- WinUI 3 enfoque Win32: https://www.windowslatest.com/2021/07/12/microsoft-winui-3-uwp-win32-apps-windows-11/
