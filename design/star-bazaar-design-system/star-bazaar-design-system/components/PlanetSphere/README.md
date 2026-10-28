# PlanetSphere

A CSS-only planet render: one `.ds-planet` element plus a world-type class, lit from the upper left like the sun on the map.

- Types: `terran`, `arid`, `frozen`, `molten`, `gas`. Add `atmo` to terran worlds for the `glow-atmo` rim.
- Hollin Reach uses Voltara = `molten`, Tillam = `terran atmo`, Ashgate = `arid`.
- Set the size with `width`/`height` and keep `font-size` at roughly half of it: the terminator shading is measured in `em`.
- These stand in for the planned per-type planet textures. When the textures land, keep the same type names and sizes.
- Sizes: 26–34px on the map, 76px in the panel hero.
