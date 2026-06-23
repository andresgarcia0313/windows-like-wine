# EDT / WBS — Soporte de apps modernas de Windows en windows-like

Estructura de Desglose del Trabajo a **5 niveles**. Notación:
`‖A/‖B/‖C` = carriles paralelizables (mismo carril = puede correr a la vez con
otros del mismo carril; distinto carril = independiente). `→` = depende del previo.
`[V]` = punto de validación obligatorio (criterio de salida). Cada hoja (nivel 5)
es una actividad atómica asignable.

```
1. Soporte apps modernas Windows (UWP/MSIX/WinRT) en windows-like   [PROYECTO]
│
├── 1.1 Investigación y fundamentos                                  [FASE ‖A]
│   ├── 1.1.1 Estado del arte en Wine
│   │   ├── 1.1.1.1 Mapa de cobertura combase/WinRT
│   │   │   ├── 1.1.1.1.1 Inventariar funciones implementadas en combase
│   │   │   ├── 1.1.1.1.2 Listar parches wine-staging combase-RoApi
│   │   │   └── 1.1.1.1.3 Probar RoActivateInstance con clase de prueba   [V]
│   │   └── 1.1.1.2 Metadata .winmd
│   │       ├── 1.1.1.2.1 Compilar widl con --winmd en el host
│   │       ├── 1.1.1.2.2 Generar .winmd de un .idl mínimo
│   │       └── 1.1.1.2.3 Verificar lectura del .winmd por Wine          [V]
│   └── 1.1.2 Anatomía del formato MSIX/AppX
│       ├── 1.1.2.1 Estructura OPC/ZIP
│       │   ├── 1.1.2.1.1 Desempaquetar un .msix con 7z/unzip
│       │   ├── 1.1.2.1.2 Mapear AppxManifest.xml (Identity, Dependencies)
│       │   └── 1.1.2.1.3 Localizar <Application Executable=...>          [V]
│       └── 1.1.2.2 Clasificación de apps por dependencia de UI
│           ├── 1.1.2.2.1 Detectar apps Win32-puras vs WinUI3
│           ├── 1.1.2.2.2 Detectar Framework packages requeridos
│           └── 1.1.2.2.3 Construir corpus de prueba (5+ MSIX)           [V]
│
├── 1.2 Iteración 1 — MSIX unpack + launch (Nivel 0 mínimo)          [FASE →]
│   ├── 1.2.1 Desempaquetador
│   │   ├── 1.2.1.1 CLI de extracción
│   │   │   ├── 1.2.1.1.1 wl-msix extract <pkg> -> carpeta destino
│   │   │   ├── 1.2.1.1.2 Validar firma/AppxBlockMap (solo aviso, no bloquea)
│   │   │   └── 1.2.1.1.3 Test: extrae sin pérdida de archivos           [V]
│   │   └── 1.2.1.2 Parser de manifiesto
│   │       ├── 1.2.1.2.1 Leer Executable/EntryPoint del manifest
│   │       ├── 1.2.1.2.2 Resolver rutas relativas dentro del paquete
│   │       └── 1.2.1.2.3 Test: entrypoint correcto en 3 paquetes        [V]
│   └── 1.2.2 Lanzador
│       ├── 1.2.2.1 Ejecución en Wine
│       │   ├── 1.2.2.1.1 Copiar a C:\msix\<app> y lanzar el .exe
│       │   ├── 1.2.2.1.2 Inyectar variables de paquete mínimas
│       │   └── 1.2.2.1.3 [V] Una app MSIX Win32-pura ABRE en windows-like [V]
│       └── 1.2.2.2 Diagnóstico de fallo
│           ├── 1.2.2.2.1 Capturar DLL ausente / WinRT no resuelto
│           ├── 1.2.2.2.2 Clasificar causa (Win32 ok / WinUI3 / AppContainer)
│           └── 1.2.2.2.3 Reporte legible al usuario                     [V]
│
├── 1.3 Iteración 2 — MSIX robusto + integración (Nivel 0 robusto)   [FASE →]
│   ├── 1.3.1 Dependencias y framework packages              [‖B]
│   │   ├── 1.3.1.1 Resolución de dependencias
│   │   │   ├── 1.3.1.1.1 Parsear <Dependencies><PackageDependency>
│   │   │   ├── 1.3.1.1.2 Mapear VCLibs/WinAppSDK a runtimes del prefix
│   │   │   └── 1.3.1.1.3 Test: app con VCLibs resuelve                  [V]
│   │   └── 1.3.1.2 Almacén local de framework packages
│   │       ├── 1.3.1.2.1 Carpeta C:\msix\_frameworks compartida
│   │       ├── 1.3.1.2.2 Deduplicar versiones
│   │       └── 1.3.1.2.3 Test: dos apps comparten un framework          [V]
│   └── 1.3.2 Integración de escritorio                       [‖C]
│       ├── 1.3.2.1 Accesos del menú Inicio
│       │   ├── 1.3.2.1.1 Leer VisualElements (DisplayName, icono)
│       │   ├── 1.3.2.1.2 Crear .lnk con CreateLnk.exe (reusar script 08)
│       │   └── 1.3.2.1.3 [V] 3 apps MSIX distintas en el menú Inicio    [V]
│       └── 1.3.2.2 Desinstalación
│           ├── 1.3.2.2.1 Registrar apps instaladas en un índice
│           ├── 1.3.2.2.2 wl-msix remove <app> limpia archivos+accesos
│           └── 1.3.2.2.3 Test: instalar/desinstalar sin residuos       [V]
│
├── 1.4 Iteración 3 — WinRT regfree no-UI (Nivel 1 exploratorio)     [FASE →]
│   ├── 1.4.1 Activación por manifest                          [‖B]
│   │   ├── 1.4.1.1 Undocked RegFree WinRT
│   │   │   ├── 1.4.1.1.1 Preparar <exe>.manifest con activatableClass
│   │   │   ├── 1.4.1.1.2 Desplegar winrtact.dll junto al exe
│   │   │   └── 1.4.1.1.3 Test: activar tipo WinRT propio                [V]
│   │   └── 1.4.1.2 Componentes WinRT del sistema acotados
│   │       ├── 1.4.1.2.1 Probar Windows.Storage / Windows.Networking
│   │       ├── 1.4.1.2.2 Documentar cuáles responden en Wine
│   │       └── 1.4.1.2.3 [V] Una llamada WinRT no-UI responde           [V]
│   └── 1.4.2 Contribución upstream (opcional)                 [‖C]
│       ├── 1.4.2.1 Reporte de stubs faltantes
│       │   ├── 1.4.2.1.1 Aislar la API faltante con caso mínimo
│       │   ├── 1.4.2.1.2 Abrir bug en WineHQ Bugzilla
│       │   └── 1.4.2.1.3 Enlazar evidencia reproducible                 [V]
│       └── 1.4.2.2 Parche candidato
│           ├── 1.4.2.2.1 Implementar stub mínimo
│           ├── 1.4.2.2.2 Probar contra el caso mínimo
│           └── 1.4.2.2.3 Enviar a wine-devel (si aplica)               [V]
│
└── 1.5 Iteración 4 — Límites, matriz y cierre                       [FASE →]
    ├── 1.5.1 Matriz de compatibilidad                         [‖A]
    │   ├── 1.5.1.1 Banco de pruebas
    │   │   ├── 1.5.1.1.1 Ejecutar el corpus completo
    │   │   ├── 1.5.1.1.2 Registrar resultado (abre/parcial/falla+causa)
    │   │   └── 1.5.1.1.3 Publicar matriz en docs/                       [V]
    │   └── 1.5.1.2 Casos WinUI3/AppContainer
    │       ├── 1.5.1.2.1 Confirmar fallo del Bloc de notas Win11
    │       ├── 1.5.1.2.2 Documentar equivalente Win32 recomendado
    │       └── 1.5.1.2.3 Cerrar alcance con justificación              [V]
    └── 1.5.2 Empaquetado como fase del repo                   [‖A]
        ├── 1.5.2.1 Script reproducible
        │   ├── 1.5.2.1.1 Integrar wl-msix como scripts/14-msix.sh
        │   ├── 1.5.2.1.2 Actualizar CHANGELOG (SemVer) y README
        │   └── 1.5.2.1.3 [V] Instalación end-to-end desde cero          [V]
        └── 1.5.2.2 Regenerar backup dorado
            ├── 1.5.2.2.1 Ejecutar 99-backup.sh
            ├── 1.5.2.2.2 Verificar restauración
            └── 1.5.2.2.3 Commit final del incremento                   [V]
```

## Carriles de paralelismo (resumen)

- **‖A** (investigación / matriz / empaquetado): 1.1.1, 1.1.2, 1.5.1, 1.5.2 son
  independientes entre sí dentro de su fase.
- **‖B** (lógica de paquete): 1.3.1 y 1.4.1 son el núcleo técnico secuencial por
  iteración pero paralelos a la integración de escritorio.
- **‖C** (integración/upstream): 1.3.2 y 1.4.2 corren en paralelo a ‖B.

## Criterios de validación por iteración (Definition of Done)

| Iteración | Criterio de salida `[V]` |
|-----------|--------------------------|
| It-1 | Una app MSIX Win32-pura se desempaqueta y **abre** en el windows-like. |
| It-2 | 3 apps MSIX instalan, resuelven dependencias y aparecen en el menú Inicio; desinstalan sin residuos. |
| It-3 | Un componente WinRT no-UI se activa vía manifest y responde. |
| It-4 | Matriz de compatibilidad publicada; alcance cerrado; fase 14 reproducible end-to-end con backup regenerado. |
