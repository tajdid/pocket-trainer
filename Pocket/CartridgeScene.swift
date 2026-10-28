import SwiftUI
import RealityKit
import Combine

/// Rewind's non-AR scene, entity track and bounded spring integrator, adapted for cartridges.
struct CartridgeScene: UIViewRepresentable {
    var selection: Int
    var drag: CGSize
    var reduceMotion: Bool
    var active: Bool
    var focused: Bool = false
    var inspectionRotation: Float = 0
    @Binding var status: String
    func makeCoordinator() -> Coordinator { Coordinator() }
    func makeUIView(context: Context) -> ARView {
        let view = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        view.environment.background = .color(UIColor(red: 0.953, green: 0.941, blue: 0.914, alpha: 1))
        view.renderOptions = [.disableMotionBlur, .disableDepthOfField, .disableCameraGrain]
        context.coordinator.configure(view) { status = $0 }
        return view
    }
    func updateUIView(_ view: ARView, context: Context) {
        let c = context.coordinator
        c.selection = selection; c.drag = drag; c.reduceMotion = reduceMotion; c.active = active
        c.focused = focused; c.inspectionRotation = inspectionRotation
    }
    static func dismantleUIView(_ view: ARView, coordinator: Coordinator) {
        coordinator.loading?.cancel(); coordinator.subscription?.cancel()
        view.scene.anchors.removeAll()
    }
    @MainActor final class Coordinator {
        var selection = 0
        var drag = CGSize.zero
        var reduceMotion = false
        var active = true
        var focused = false
        var inspectionRotation: Float = 0
        private var focus: Float = 0
        private var yaw: Float = 0
        var loading: Task<Void, Never>?
        var subscription: Cancellable?
        private let track = Entity()
        private var cartridges: [Entity] = []
        private var x: Float = 0
        private var velocity: Float = 0
        private var tilt = SIMD2<Float>.zero
        private var tiltVelocity = SIMD2<Float>.zero
        private var phase: Float = 0
        private let spacing: Float = 3.6
        func configure(_ view: ARView, status: @escaping (String) -> Void) {
            let anchor = AnchorEntity(world: .zero)
            anchor.addChild(track)
            let camera = PerspectiveCamera()
            camera.camera.fieldOfViewInDegrees = 35
            camera.position = [0, 0, 7.8]
            anchor.addChild(camera)
            let key = DirectionalLight()
            key.light.intensity = 2200
            key.look(at: [0, 0, 0], from: [2, 4, 5], relativeTo: nil)
            anchor.addChild(key)
            let fill = PointLight()
            fill.light.intensity = 350; fill.light.attenuationRadius = 15
            fill.position = [-3, 1, 4]; anchor.addChild(fill)
            view.scene.addAnchor(anchor)
            // Procedural assets are immediately usable, including when an import fails.
            for item in Cartridge.allCases {
                let holder = Entity()
                holder.position.x = Float(item.rawValue) * spacing
                holder.addChild(Self.placeholder(item))
                track.addChild(holder); cartridges.append(holder)
            }
            subscription = view.scene.subscribe(to: SceneEvents.Update.self) { [weak self] event in
                MainActor.assumeIsolated { self?.tick(Float(event.deltaTime)) }
            }
            loading = Task { [weak self] in
                guard let self else { return }
                var imported: [String] = []; var failed: [String] = []
                for item in Cartridge.allCases {
                    guard let url = Bundle.main.url(forResource: item.file, withExtension: "usdz") else { continue }
                    do {
                        let model = try await Entity(contentsOf: url)
                        try Task.checkCancellation()
                        let bounds = model.visualBounds(relativeTo: nil)
                        let longest = max(bounds.extents.x, max(bounds.extents.y, bounds.extents.z))
                        guard longest.isFinite, longest > 0.00001 else { throw CocoaError(.coderReadCorrupt) }
                        let scale: Float = 2.7 / longest
                        let center = Entity()
                        model.scale *= SIMD3(repeating: scale)
                        model.position = -bounds.center * scale
                        center.addChild(model)
                        self.cartridges[item.rawValue].children.removeAll()
                        self.cartridges[item.rawValue].addChild(center)
                        imported.append(item.name)
                    } catch is CancellationError { return }
                    catch { failed.append(item.name) }
                }
                guard !Task.isCancelled else { return }
                var message = imported.isEmpty ? "Original 3D studies" : "Imported models: " + imported.joined(separator: ", ")
                if !failed.isEmpty { message += ". Using placeholders for: " + failed.joined(separator: ", ") }
                status(message)
            }
        }
        private func tick(_ delta: Float) {
            guard active else { return }
            let dt = min(max(delta, 0), 1 / 30)
            // Swipe follows the finger; resistance prevents pulling beyond either end.
            var travel = focused ? 0 : Float(drag.width) * 0.007
            if (selection == 0 && travel > 0) || (selection == 2 && travel < 0) { travel *= 0.23 }
            travel = max(-2.8, min(2.8, travel))
            let target = -Float(selection) * spacing + (reduceMotion ? 0 : travel)
            let targetTilt = SIMD2<Float>(Float(max(-50, min(50, drag.height))) * 0.002,
                                          Float(max(-100, min(100, drag.width))) * 0.0025)
            if reduceMotion {
                x = target; velocity = 0; tilt = .zero; tiltVelocity = .zero
            } else {
                phase += dt
                velocity += ((target - x) * 100 - velocity * 19) * dt
                x += velocity * dt
                tiltVelocity += ((targetTilt - tilt) * 100 - tiltVelocity * 20) * dt
                tilt += tiltVelocity * dt
            }
            focus += ((focused ? 1 : 0) - focus) * (reduceMotion ? 1 : 1 - exp(-12 * dt))
            let targetYaw = focused ? inspectionRotation + Float(drag.width) * 0.012 : 0
            yaw += (targetYaw - yaw) * (reduceMotion ? 1 : 1 - exp(-14 * dt))
            track.position.x = x
            for (index, cartridge) in cartridges.enumerated() {
                let distance = min(1, abs(Float(index) + x / spacing))
                cartridge.components.set(OpacityComponent(opacity: index == selection ? 1 : 1 - focus))
                cartridge.scale = SIMD3(repeating: 1 - distance * 0.12 + (index == selection ? focus * 0.08 : 0))
                cartridge.position.z = -distance * 0.5
                cartridge.position.y = reduceMotion ? 0 : sin(phase * 1.3 + Float(index) * 0.6) * 0.025
                cartridge.orientation = simd_quatf(angle: reduceMotion ? 0 : -0.08 + tilt.x, axis: [1, 0, 0])
                    * simd_quatf(angle: reduceMotion ? (focused ? yaw : 0) : -0.16 + (yaw * focus + tilt.y * (1 - focus)) - (Float(index) + x / spacing) * 0.12, axis: [0, 1, 0])
                    * simd_quatf(angle: reduceMotion ? 0 : -0.035, axis: [0, 0, 1])
            }
        }
        private static func placeholder(_ item: Cartridge) -> Entity {
            let root = Entity()
            func box(_ name: String, _ size: SIMD3<Float>, _ position: SIMD3<Float>, _ color: UIColor, radius: Float = 0.025) {
                let material = SimpleMaterial(color: color, roughness: 0.6, isMetallic: false)
                let model = ModelEntity(mesh: .generateBox(size: size, cornerRadius: radius), materials: [material])
                model.name = name; model.position = position; root.addChild(model)
            }
            let shell = item.color
            box("Shell", [2.35, 2.65, 0.30], [0, 0, 0], shell, radius: 0.11)
            box("Top inset", [1.9, 0.32, 0.035], [0, 1.02, 0.151], shell.withAlphaComponent(1).darker)
            for i in 0..<5 {
                let y = Float(i) * 0.075
                box("Left grip", [0.19, 0.025, 0.025], [-1.03, 0.32 + y, 0.159], shell.darker, radius: 0.01)
                box("Right grip", [0.19, 0.025, 0.025], [1.03, 0.32 + y, 0.159], shell.darker, radius: 0.01)
            }
            box("Label recess", [1.86, 1.73, 0.035], [0, -0.12, 0.157], shell.darker, radius: 0.08)
            box("Paper label", [1.74, 1.60, 0.015], [0, -0.12, 0.181], UIColor(red: 0.95, green: 0.91, blue: 0.79, alpha: 1), radius: 0.05)
            func text(_ string: String, size: Float, y: Float, color: UIColor) {
                let mesh = MeshResource.generateText(string, extrusionDepth: 0.001, font: .systemFont(ofSize: CGFloat(size), weight: .bold), containerFrame: .zero, alignment: .center)
                let e = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: color)])
                let b = e.visualBounds(relativeTo: nil)
                e.position = [-b.center.x, y - b.center.y, 0.195]
                root.addChild(e)
            }
            text("GAME BOY", size: 0.16, y: 1.02, color: UIColor.white.withAlphaComponent(0.7))
            text("POKÉMON", size: 0.24, y: 0.39, color: .darkGray)
            text(item.name.uppercased(), size: 0.28, y: -0.10, color: shell)
            text("VERSION", size: 0.10, y: -0.36, color: .darkGray)
            text("POCKET MONSTERS", size: 0.075, y: -0.70, color: .darkGray)
            box("Bottom seam", [2.08, 0.018, 0.016], [0, -1.12, 0.153], shell.darker, radius: 0.005)
            box("Back inset", [1.87, 1.95, 0.018], [0, 0, -0.158], shell.darker, radius: 0.06)
            let screw = ModelEntity(mesh: .generateSphere(radius: 0.07), materials: [SimpleMaterial(color: .darkGray, isMetallic: true)])
            screw.position = [0, -0.67, -0.18]; screw.scale.z = 0.25; root.addChild(screw)
            box("Back seam", [2.08, 0.025, 0.02], [0, -1.1, -0.159], shell.darker, radius: 0.005)
            return root
        }
    }
}
private extension UIColor {
    var darker: UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red: r * 0.72, green: g * 0.72, blue: b * 0.72, alpha: 1)
    }
}
