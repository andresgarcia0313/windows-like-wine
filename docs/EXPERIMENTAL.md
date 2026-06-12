# Apéndice experimental

Opciones investigadas que NO forman parte del flujo principal, con su veredicto.

## Shells alternativos dentro del escritorio virtual

| Opción | Qué es | Veredicto |
|--------|--------|-----------|
| RetroBar | Taskbar clásica (Win95→Vista) en .NET/WPF | **No verificado bajo Wine.** Usa ManagedShell, que depende de hooks del shell de Windows (SHAppBarMessage, tray) que el explorer de Wine no implementa completamente. Tienes .NET 4.8 instalado si quieres experimentar |
| Cairo Shell | Shell completo alternativo para Windows | Mismo problema de hooks + más pesado. No recomendado |
| Open-Shell | Reemplazo del menú inicio | Se integra con el explorer.exe real de Windows; el de Wine es distinto. Incompatible |

**Conclusión:** la taskbar nativa de Wine (`/desktop=shell`) es la única opción
estable hoy. Es básica (inicio + ventanas + reloj) pero confiable.

## Temas visuales (.msstyles)

Wine soporta temas del formato Windows XP. Hay ports de la apariencia Win10/Win11
en ese formato, con calidad variable.

Instalación: `winecfg` → **Integración de escritorio** → **Instalar tema** →
seleccionar `.msstyles` → Aplicar.

Notas:
- El tema **Light** (default de Wine moderno) ya da apariencia limpia tipo Win10
- Wine es exigente con qué temas detecta; muchos fallan al cargar
- Un tema corrupto se revierte eligiendo "(Sin tema)" en el mismo diálogo

## Resolución del escritorio virtual

`1600x900` está definido en dos sitios (deben coincidir si cambias):
1. Registro: `HKCU\Software\Wine\Explorer\Desktops\shell`
2. Lanzador: `Exec=... /desktop=shell,1600x900`
