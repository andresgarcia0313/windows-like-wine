# Soberanía del código fuente (vendoring)

> Objetivo: que si mañana **cierran o borran Wine** (o cualquier componente
> opensource que usamos), podamos reconstruir el windows-like **sin depender de
> internet ni de los servidores de terceros**. Tenemos el código fuente, no solo
> los binarios.

## Por qué NO metemos el source dentro del repo git

- GitHub **rechaza archivos >100 MB** y recomienda repos **<1 GB** (fuertemente
  <5 GB). Git LFS gratis solo da **1 GB de almacenamiento + 1 GB/mes** de ancho
  de banda. Fuentes:
  [límites de repo](https://docs.github.com/en/repositories/creating-and-managing-repositories/repository-limits),
  [LFS](https://docs.github.com/en/repositories/working-with-files/managing-large-files/about-large-files-on-github).
- El source de Wine Mono solo pesa **~306 MB**; Wine, DXVK y vkd3d suman cientos
  de MB más. Vendorizarlo con `git subtree`/LFS **rompería** el repo (clones
  lentos, cuota agotada).

## Estrategia ganadora: triple respaldo, repo delgado

El repo git queda **delgado** (solo scripts + manifiesto + checksums). El código
fuente vive **congelado y verificado** en tres lugares redundantes bajo control
del usuario:

1. **Manifiesto versionado** (`vendor/sources.lock`) — en el repo git: por cada
   componente, su **versión exacta, URL oficial, SHA256, licencia y si es
   redistribuible**. Es la "lista de materiales" reproducible (cabe en KB).
2. **Tarballs de source congelados** (`vendor/cache/`, *ignorado por git*) —
   `vendor/fetch-sources.sh` los descarga y **verifica el SHA256** contra el
   manifiesto. Reproducible bit a bit. Estos tarballs se copian a:
   - **Canvio 4TB** (`/mnt/canvio4tb/`, ya montado): copia fría offline.
   - **Release assets de ESTE repo en GitHub** (hasta 2 GB/archivo, **no cuentan**
     contra el tamaño del repo) como mirror público adicional.
3. **Mirror de los repos upstream en el Gitea propio** (cluster k3s del usuario):
   Gitea soporta *pull mirror* automático. Clonar Wine/DXVK/vkd3d/wine-mono/
   winetricks como mirrors da el **historial git completo** bajo control propio.
   Si GitHub o WineHQ desaparecen, el Gitea del usuario sigue teniendo todo.

> Resultado: aunque el repo git permanezca pequeño y portable, la **cadena de
> suministro completa** (source + historial + checksums) está respaldada tres
> veces en infraestructura propia.

## Licencias: ¿podemos redistribuir el source?

Sí, todos son redistribuibles conservando sus avisos de licencia:

| Componente | Licencia | ¿Redistribuible? |
|------------|----------|------------------|
| Wine | LGPL-2.1-or-later | Sí (conservar COPYING.LIB) |
| Wine Mono | MIT + LGPL/GPL (componentes Mono) | Sí (conservar LICENSE) |
| DXVK | zlib/libpng | Sí |
| vkd3d / vkd3d-proton | LGPL-2.1 / Apache-2.0 | Sí |
| winetricks | LGPL-3.0 | Sí |
| corefonts | EULA Microsoft (redist permitida sin modificar) | Sí, sin modificar |

`vendor/fetch-sources.sh` guarda también el archivo de licencia de cada source.

## Cómo usarlo

```bash
# 1. Descargar y verificar todo el source (idempotente):
vendor/fetch-sources.sh

# 2. Primera vez (registrar los SHA256 reales tras descargar):
vendor/fetch-sources.sh --record   # rellena sources.lock con los hashes medidos

# 3. Copia fría a Canvio:
vendor/fetch-sources.sh --mirror /mnt/canvio4tb/windows-like-vendor

# 4. (Opcional) subir como release asset del repo:
gh release create vendor-snapshot vendor/cache/*  -t "Snapshot de fuentes"
```

## Reproducibilidad

- **Versión congelada** por componente en `sources.lock` (no "latest").
- **SHA256 verificado** en cada fetch: si el upstream cambia el tarball, el script
  aborta (no acepta un source distinto al registrado).
- Para reconstruir desde cero sin internet: `fetch-sources.sh --from /mnt/canvio4tb/...`
  toma los tarballs de la copia fría en vez de la red.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
|--------|------------|
| Tamaño del repo | Source NUNCA entra al repo; solo manifiesto + script (KB). |
| Upstream borra el tarball | Triple copia (Canvio + Gitea mirror + release asset). |
| Cuota LFS | No se usa LFS; se usan release assets (no cuentan al repo). |
| Cambio silencioso del source | SHA256 obligatorio; fetch aborta si no coincide. |
| Licencias | Tabla anterior + se conserva el archivo de licencia de cada source. |
