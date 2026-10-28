# Optional cartridge model imports

Pocket Trainer includes original procedural 3D cartridges. No external models are required to run it.

## Prepare models

Use USDZ files with embedded textures and materials. Export with +X pointing right, +Y up and the front label toward +Z. Apply transforms and check the result in a 3D preview before importing.

## Add to the app

1. Name the files `CartridgeRed.usdz`, `CartridgeBlue.usdz` and `CartridgeYellow.usdz`.
2. Add them to the Pocket group in Xcode with **Copy items if needed** enabled and **Pocket** target membership checked.
3. Confirm each file appears under **Build Phases → Copy Bundle Resources**. Copying a file into the folder alone does not add it to the app.
4. Run. The carousel and detail preview center and scale each model automatically. Missing or invalid imports retain the procedural cartridge.
5. Verify all three versions, label orientation, materials, rotation and back views. Imported models have not been validated against source files in this project.

Keep source credits and any required notices for assets you add. Mascot sprite credits are in SPRITE-CREDITS.md.
