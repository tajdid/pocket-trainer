# Cartridge assets and import guide

Reviewed 28 October 2026.

## Collection review

[Pokémon Game Boy Cartridges by Karena Williams](https://sketchfab.com/Karenawilliams/collections/pokemon-game-boy-cartridges-1a1f1a1bef6241a19137f2097abb9395) contains exactly the three requested models. All have 1,140 faces and no animations according to the public metadata, making their geometry modest for a mobile carousel. Texture dimensions, material behavior and orientation have not been inspected because files are unavailable.

| Model | Link | Public metadata license | Downloadable |
| --- | --- | --- | --- |
| Red | [Model](https://sketchfab.com/3d-models/pokemon-red-version-game-boy-color-cartridge-3d6d115ea67d4953a6757ff91f41c9f7) | Editorial | No |
| Blue | [Model](https://sketchfab.com/3d-models/pokemon-blue-version-game-boy-color-cartridge-819aaafc15ca44b48fb0b0fd94dcea5b) | Editorial | No |
| Yellow | [Model](https://sketchfab.com/3d-models/pokemon-yellow-version-game-boy-cartridge-54d32643103147baad31a53272a2755f) | Editorial | No |

Evidence is saved in `AssetReview/*-metadata.json`, fetched from `https://api.sketchfab.com/v3/models/{model-id}`. The normal model pages returned 403 to automated browsing. The metadata describes Editorial usage as “Use only in connection with events that are newsworthy or of public interest.” See [Sketchfab licenses](https://sketchfab.com/licenses). This is not a Creative Commons grant, and this interaction experiment has not been established as permitted editorial use. None of these assets has been downloaded or bundled. Attribution alone does not supply permission.

## Obtain files

1. Open each model page while signed into Sketchfab and review its current availability and license. If downloads remain disabled, contact the creator to request source files and permission for the intended app use. No download button is promised by this guide.
2. Keep written permission and any conditions with the project. Clarify distribution and modification rights before shipping an app containing the models. Relevant Pokémon and Nintendo artwork rights are separate from the mesh creator’s rights.
3. Obtain a supported source format with textures. Convert/export in Blender or another suitable 3D tool to USDZ, embedding materials and textures. Use a front-facing coordinate system: +X right, +Y up, front label toward +Z. Apply transforms before export. Keep artwork readable in the exported preview.

## Add to Pocket

1. Name the exports exactly `CartridgeRed.usdz`, `CartridgeBlue.usdz`, and `CartridgeYellow.usdz` (case matters).
2. In Xcode, add the files to the Pocket group with **Copy items if needed** enabled, and check **Pocket** target membership. Confirm each appears in the Pocket target’s **Build Phases → Copy Bundle Resources**. Merely copying into the folder does not add resources to this project.
3. Run. The loader fits each asset’s longest bound to 2.7 scene units and centers it. It preserves embedded materials. If a cartridge faces the wrong direction, correct its export orientation; do not rotate the full carousel.
4. Open About to check which models imported. A corrupt/missing model keeps its procedural fallback. Verify all three labels, materials, centering, side views, rapid swipes and memory use on simulator and device.
5. Replace the placeholder statement in About with the actual creator, model links, license/permission and modification credits before sharing a build with imported assets. Preserve any required notices alongside the app.

No importer or texture conversion has been validated against these unavailable source files.
