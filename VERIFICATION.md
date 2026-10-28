# Verification

28 October 2026 — Xcode 27.1 SDK, iPhone 18 Pro simulator running iOS 27.0.

- Debug simulator build succeeded.
- `PocketUITests.testCarouselSnapsAndClamps` passed. It checks horizontal swipes Red → Blue → Yellow, attempted advancement past Yellow, direct selection of Red and attempted movement before Red. Selection is checked through accessible labels and values.
- Simulator screenshot `Preview.png` inspected: centered red cartridge, visible blue neighbor, readable labels and unclipped controls on iPhone 18 Pro.
- Rewind source and assets were read but never edited or copied over. Pocket uses a separate output folder and bundle identifier.

Not verified: physical-device haptic feel, other screen sizes, real VoiceOver use, thermal/energy behavior over long sessions, and imported model materials/orientation. Reduce Motion and background pausing are implemented but were not exercised through system settings. No physical phone was installed, updated or launched.

Build/test commands (from the repository root):

```
xcodebuild -project Pocket.xcodeproj -scheme Pocket -destination 'platform=iOS Simulator,id=A23E6416-A381-41A5-B3E7-1756C9469B68' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project Pocket.xcodeproj -scheme Pocket -destination 'platform=iOS Simulator,id=A23E6416-A381-41A5-B3E7-1756C9469B68' -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO test
```

The initial restricted compiler invocation could not start SwiftUI macro services; rerunning with compiler-service access succeeded without source changes.

Typography revision: replaced all serif headings with system sans-serif and changed cartridge navigation labels to uppercase monospace. Simulator rebuild passed; refreshed Preview.png inspected.

PocketOS copy revision: simulator build passed. Refreshed main screen inspected for title baseline, version-selection label and instruction fit. Red, Blue and Yellow descriptions updated from the supplied references. No new interaction behavior was introduced.

First-run dialogue revision: final simulator test passed, including the full accessible message, immediately available PRESS START, persisted dismissal after relaunch, replay from Trainer’s guide, and existing swipe/boundary checks. Main header label removed. Welcome.png visually inspected; typewriter uses a stable text area to prevent layout shifts and cancels with view/lifecycle changes. System VoiceOver/Reduce Motion settings were not manually exercised.


## Cartridge details revision

The first-run dialogue, storage dependency and replay option have been removed. Final `PocketUITests.testCarouselAndDetails` passed on iPhone 18 Pro simulator: all three detail titles, opening by tap, FLIP, drag inspection without changing version, close arrow, scroll-to-bottom return, preserved selection, and carousel boundary checks. The original test lookup was updated because adding a default accessible tap action makes the cartridge a button rather than an “Other” element.

Details-Red.png, Details-Blue.png and Details-Yellow.png were exported from the passing run and visually inspected. The shared RealityKit view stays in the same structural location; focus scales the selected entity and fades its neighbors instead of duplicating scenes for a matched-geometry effect. The top heading supports downward-swipe dismissal. The lower detail area scrolls independently. No character artwork is bundled; mascot names appear as text. Source references are in GAME-SOURCES.md.

Still not assessed on a physical device: haptics, sustained performance, and real VoiceOver navigation. The earlier welcome screenshot was removed because it is no longer part of the app.

Pocket Trainer rename: wordmark, information-sheet identity and both app display-name configurations updated. Simulator build passed. Bundle identifier and project paths remain stable so existing installs update in place.

App icon revision: the universal iOS AppIcon asset is an opaque 1024 × 1024 PNG. Asset catalog compilation and simulator build passed. AppIcon is selected in Debug and Release. The specified reference-collection paragraph was removed from README.md. Generation prompt and artwork provenance are recorded in APP-ICON.md.


## Native detail sheet revision

Replaced the inline split detail layout with a rounded native sheet at 88% and large detents, visible drag indicator, fixed close header and a single scrolling page. The preview and grouped information card scroll together, removing the old hard crop between a pinned scene and scrolling facts. The paused collection remains behind the sheet; its selection persists. A separate isolated preview uses the existing scene implementation, with neighbors disabled before first render. Yellow text accents use a darker shade for legibility.

Final simulator test passed for Red, Blue and Yellow opening, preview rotation and flip, close button, bottom return button, native swipe-down dismissal, selection persistence and carousel boundaries. Detail screenshots refreshed from that run and Blue visually reviewed. Physical-device performance and haptic feel remain unverified.


## Sheet preview and mascot sprite fix

Replaced the second RealityKit ARView in the sheet with a dedicated SceneKit preview. The preview object is centered at the origin with an explicit camera; it does not depend on carousel offsets or a RealityKit frame-update subscription to become visible. Main carousel rendering remains RealityKit. USDZ imports are attempted in the sheet, with procedural fallback; unavailable source imports remain unverified.

Bundled original Pokémon Yellow pixel sprites for Charizard, Blastoise and Pikachu from the URLs returned by PokéAPI. Rendered beside mascot names with nearest-neighbor interpolation and no runtime requests. Attribution and upstream notice are in SPRITE-CREDITS.md and ThirdParty/.

Simulator UI tests passed, including the mascot image identifiers/labels for all versions, rotation and flip, repeated detail opening, close/back, swipe-down dismissal and preserved selection. Final preview screenshots were exported and inspected for visible cartridges and the mascot row. Xcode’s post-test diagnostic collector stalled after tests passed; only that collector was terminated, and the report finalized successfully. The user-reported physical-device condition has not been verified on a physical device.
