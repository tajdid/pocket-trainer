import SwiftUI

@main struct PocketApp: App {
    var body: some Scene { WindowGroup { CollectionView() } }
}

struct CollectionView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var phase
    @State private var inspecting = false
    @State private var rotation: Float = 0
    @State private var selection = 0
    @GestureState private var drag = CGSize.zero
    @State private var showingCredits = false
    @State private var status = "Original 3D studies"
    private var theme: Cartridge { Cartridge(rawValue: selection)! }
    private let ink = Color(white: 0.15)
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    if inspecting {
                        Button(action: closeDetails) {
                            Image(systemName: "arrow.left").frame(width: 44, height: 44)
                        }.accessibilityLabel("Back to collection").accessibilityIdentifier("details.close")
                        Spacer()
                        Text(String(format: "CARTRIDGE NO. %03d", selection + 1))
                            .font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button { showingCredits = true } label: {
                        Image(systemName: "info.circle").font(.system(size: 18, weight: .light)).frame(width: 44, height: 44)
                    }.accessibilityLabel("Trainer’s guide and model credits")
                }.padding(.horizontal, 24).padding(.top, 12)
                if !inspecting { Spacer(minLength: 12) }
                VStack(spacing: 10) {
                    if inspecting {
                        Text(theme.release).font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(themeColor).tracking(1)
                        Text("Pokémon \(theme.name)").font(.system(size: 32, weight: .bold)).tracking(-1)
                            .accessibilityIdentifier("details.title")
                        Text(theme.journey).font(.system(size: 13)).foregroundStyle(.secondary)
                    } else {
                        Text("Pocket Trainer")
                            .font(.system(size: 40, weight: .bold)).tracking(-1.5)
                            .lineLimit(1).minimumScaleFactor(0.75)
                            .padding(.horizontal, 24)
                        Text("Your adventure starts here.").font(.system(size: 13)).foregroundStyle(.secondary)
                    }
                }
                .padding(.top, inspecting ? 10 : 0)
                .contentShape(Rectangle())
                .gesture(DragGesture().onEnded { value in
                    if inspecting && value.translation.height > 65 && abs(value.translation.width) < value.translation.height { closeDetails() }
                })
                // This ARView remains at the same structural position in both layouts.
                // RealityKit keeps the selected entity alive as its focus and frame change.
                ZStack(alignment: .bottom) {
                    CartridgeScene(selection: selection, drag: drag, reduceMotion: reduceMotion,
                                   active: phase == .active && !showingCredits,
                                   focused: inspecting, inspectionRotation: rotation, status: $status)
                        .allowsHitTesting(false)
                    Ellipse().fill(themeColor.opacity(0.16)).frame(width: 160, height: 12).blur(radius: 13).padding(.bottom, 20)
                }
                .frame(height: inspecting ? min(300, geometry.size.height * 0.33) : min(400, geometry.size.height * 0.43))
                .contentShape(Rectangle())
                .gesture(DragGesture(minimumDistance: 4)
                    .updating($drag) { value, state, _ in state = value.translation }
                    .onEnded { value in
                        if inspecting {
                            rotation += Float(value.translation.width) * 0.012
                            return
                        }
                        let x = value.translation.width
                        guard abs(x) > abs(value.translation.height) * 1.3 else { return }
                        if abs(x) > 65 || (abs(x) > 24 && abs(value.predictedEndTranslation.width) > 140) {
                            select(selection + (x < 0 ? 1 : -1))
                        }
                    }.exclusively(before: SpatialTapGesture().onEnded { value in
                        // Only the central cartridge opens; empty space and neighbors do not.
                        let width = min(geometry.size.width, 600)
                        let height = min(400, geometry.size.height * 0.43)
                        if !inspecting && CGRect(x: width * 0.22, y: height * 0.15,
                                                 width: width * 0.56, height: height * 0.7).contains(value.location) { openDetails() }
                    }))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Pokémon \(theme.name) cartridge")
                .accessibilityValue(inspecting ? "Inspection" : "\(selection + 1) of 3")
                .accessibilityIdentifier("cartridge")
                .accessibilityHint(inspecting ? "Double tap to flip the cartridge" : "Double tap to explore. Swipe up or down to choose a version")
                .accessibilityAction { if inspecting { rotation += .pi } else { openDetails() } }
                .accessibilityAdjustableAction { direction in
                    if inspecting { rotation += direction == .increment ? .pi / 4 : -.pi / 4 }
                    else { select(selection + (direction == .increment ? 1 : -1)) }
                }
                if inspecting {
                    HStack(spacing: 14) {
                        Text("DRAG TO ROTATE").font(.system(size: 8, design: .monospaced)).tracking(1)
                            .foregroundStyle(.secondary)
                        Button { rotation += .pi; UISelectionFeedbackGenerator().selectionChanged() } label: {
                            Label("FLIP", systemImage: "arrow.triangle.2.circlepath")
                                .font(.system(size: 10, weight: .medium, design: .monospaced)).frame(minHeight: 44)
                        }.accessibilityIdentifier("details.flip")
                    }
                    ScrollView {
                        VStack(alignment: .leading, spacing: 18) {
                            detailLabel("THE ADVENTURE")
                            Text(theme.adventure).font(.system(size: 15)).lineSpacing(4)
                            Divider()
                            LazyVGrid(columns: [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)], alignment: .leading, spacing: 18) {
                                fact("REGION", "Kanto"); fact("GENERATION", "I")
                                fact("POKÉDEX", "151"); fact("PLATFORM", "Game Boy")
                            }
                            Divider()
                            detailLabel("VERSION MASCOT")
                            Text(theme.mascot).font(.system(size: 22, weight: .semibold))
                            detailLabel("DID YOU KNOW?")
                            Text(theme.trivia).font(.system(size: 14)).lineSpacing(4)
                            Button(action: closeDetails) {
                                Text("BACK TO COLLECTION").font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .foregroundStyle(.white).background(ink, in: RoundedRectangle(cornerRadius: 8))
                            }.accessibilityIdentifier("details.back")
                        }.padding(.horizontal, 28).padding(.top, 10).padding(.bottom, 24)
                    }.accessibilityIdentifier("details.content")
                } else {
                    VStack(spacing: 10) {
                        Text(String(format: "%02d / 03", selection + 1) + " · CHOOSE YOUR VERSION").font(.system(size: 9, design: .monospaced)).tracking(1).foregroundStyle(.secondary)
                        Text("Pokémon \(theme.name)").font(.system(size: 27, weight: .semibold)).contentTransition(.opacity)
                        Text(theme.subtitle).font(.system(size: 12)).foregroundStyle(.secondary).contentTransition(.opacity)
                        Capsule().fill(themeColor).frame(width: 24, height: 3).padding(.top, 8)
                    }.animation(.easeInOut(duration: 0.2), value: selection)
                    Spacer(minLength: 18)
                    HStack(spacing: 16) {
                        ForEach(Cartridge.allCases) { item in
                            Button { select(item.rawValue) } label: {
                                VStack(spacing: 9) {
                                    Capsule().fill(selection == item.rawValue ? Color(item.color) : ink.opacity(0.13))
                                        .frame(width: selection == item.rawValue ? 25 : 6, height: 6)
                                    Text(item.name.uppercased()).font(.system(size: 10, weight: .medium, design: .monospaced)).tracking(1).opacity(selection == item.rawValue ? 1 : 0.45)
                                }.frame(maxWidth: .infinity, minHeight: 50)
                            }.accessibilityIdentifier("theme.\(item.rawValue)")
                            .accessibilityAddTraits(selection == item.rawValue ? .isSelected : [])
                        }
                    }.padding(.horizontal, 52)
                    Text("SWIPE TO CHOOSE · TAP TO EXPLORE").font(.system(size: 8, design: .monospaced)).tracking(1.5).foregroundStyle(.secondary).padding(.top, 18).padding(.bottom, 24)
                }
            }.frame(maxWidth: 600).frame(maxWidth: .infinity)
        }
        .foregroundStyle(ink).background(Color(red: 0.953, green: 0.941, blue: 0.914).ignoresSafeArea())
        .preferredColorScheme(.light)
        .sheet(isPresented: $showingCredits) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Trainer’s guide").font(.system(.largeTitle, design: .default, weight: .bold))
                        Text("Welcome to the world of Pokémon! Swipe to choose your version, then tap the cartridge to explore its story. In the detail view, drag to rotate or use FLIP to see its back. Return with the back arrow, swipe down on the heading, or use BACK TO COLLECTION.")
                        Text("Pocket Trainer — a Wee Interactions experiment by Tajdid Rahman.").font(.footnote).foregroundStyle(.secondary)
                        Text(status).font(.headline)
                        Text("The included cartridges are original procedural placeholders with typographic labels. No Sketchfab models or Pokémon character artwork are bundled.")
                        Text("Sketchfab’s public metadata lists all three models as Editorial and not downloadable. Obtain permission and suitable files from the creator before importing them.")
                        Link("View the Sketchfab collection", destination: URL(string: "https://sketchfab.com/Karenawilliams/collections/pokemon-game-boy-cartridges-1a1f1a1bef6241a19137f2097abb9395")!)
                        Text("Pokémon and Game Boy names belong to their respective owners. This is an unofficial interaction study.").font(.footnote).foregroundStyle(.secondary)
                    }.padding(28)
                }.toolbar { Button("Done") { showingCredits = false } }
            }.presentationDetents([.medium, .large])
        }
    }
    private func detailLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 10, weight: .medium, design: .monospaced)).tracking(1).foregroundStyle(themeColor)
    }
    private func fact(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary)
            Text(value).font(.system(size: 18, weight: .medium))
        }.accessibilityElement(children: .combine)
    }
    private func openDetails() {
        guard !inspecting else { return }
        rotation = 0
        UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.5)
        withAnimation(reduceMotion ? .easeInOut(duration: 0.15) : .spring(duration: 0.55, bounce: 0.08)) { inspecting = true }
    }
    private func closeDetails() {
        rotation = 0
        withAnimation(reduceMotion ? .easeInOut(duration: 0.15) : .spring(duration: 0.55, bounce: 0.08)) { inspecting = false }
    }
    private var themeColor: Color { Color(theme.color) }
    private func select(_ next: Int) {
        let next = min(2, max(0, next))
        guard next != selection else { return }
        withAnimation(reduceMotion ? .linear(duration: 0.1) : .spring(duration: 0.45, bounce: 0.12)) { selection = next }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
