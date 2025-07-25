import SwiftUI
import RealityKit
import ARKit

struct ARMenuView: View {
    @State private var selectedDish: ARDish?
    @State private var showingDishDetail = false
    @State private var arSession: ARSession?
    @State private var isARReady = false
    @State private var showingInstructions = true
    
    private let dishes = ARDish.sampleDishes
    
    var body: some View {
        ZStack {
            // AR View
            ARViewContainer(
                selectedDish: $selectedDish,
                dishes: dishes,
                isARReady: $isARReady
            )
            .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top controls
                HStack {
                    Button(action: {
                        showingInstructions.toggle()
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    if isARReady {
                        Text("AR готов")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    } else {
                        Text("Настройка AR...")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                }
                .padding()
                
                Spacer()
                
                // Bottom dish selector
                DishSelectorView(
                    dishes: dishes,
                    selectedDish: $selectedDish
                )
            }
            
            // Instructions overlay
            if showingInstructions {
                InstructionsOverlay {
                    showingInstructions = false
                }
            }
            
            // Dish detail sheet
            if let selectedDish = selectedDish {
                ARDishDetailSheet(
                    dish: selectedDish,
                    isPresented: $showingDishDetail
                )
            }
        }
        .onChange(of: selectedDish) { dish in
            if dish != nil {
                showingDishDetail = true
            }
        }
    }
}

// MARK: - AR View Container
struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedDish: ARDish?
    let dishes: [ARDish]
    @Binding var isARReady: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: false)
        
        // Configure AR session
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.environmentTexturing = .automatic
        
        arView.session.delegate = context.coordinator
        arView.session.run(configuration)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGesture)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update AR content when dishes change
        context.coordinator.updateARDishes(dishes, in: uiView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        var parent: ARViewContainer
        var arDishEntities: [UUID: Entity] = [:]
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            DispatchQueue.main.async {
                self.parent.isARReady = true
            }
        }
        
        func session(_ session: ARSession, didFailWithError error: Error) {
            print("AR Session failed: \(error)")
        }
        
        func updateARDishes(_ dishes: [ARDish], in arView: ARView) {
            // Clear existing entities
            arDishEntities.values.forEach { entity in
                entity.removeFromParent()
            }
            arDishEntities.removeAll()
            
            // Add new dish entities
            for (index, dish) in dishes.enumerated() {
                let entity = createDishEntity(for: dish)
                
                // Position dishes in a circle
                let angle = Float(index) * (2 * Float.pi) / Float(dishes.count)
                let radius: Float = 0.5
                let x = radius * cos(angle)
                let z = radius * sin(angle)
                
                entity.position = SIMD3<Float>(x, 0, z)
                entity.scale = SIMD3<Float>(dish.scale, dish.scale, dish.scale)
                
                let anchor = AnchorEntity(world: entity.position)
                anchor.addChild(entity)
                arView.scene.addAnchor(anchor)
                
                arDishEntities[dish.id] = entity
            }
        }
        
        private func createDishEntity(for dish: ARDish) -> Entity {
            let entity = Entity()
            
            // Create a simple 3D representation (placeholder)
            let mesh = MeshResource.generateBox(size: 0.1)
            let material = SimpleMaterial(color: .blue, isMetallic: false)
            let modelEntity = ModelEntity(mesh: mesh, materials: [material])
            
            // Add dish info as text
            let textMesh = MeshResource.generateText(
                dish.name,
                extrusionDepth: 0.01,
                font: .systemFont(ofSize: 0.05),
                containerFrame: .zero,
                alignment: .center,
                lineBreakMode: .byTruncatingTail
            )
            let textMaterial = SimpleMaterial(color: .white, isMetallic: false)
            let textEntity = ModelEntity(mesh: textMesh, materials: [textMaterial])
            textEntity.position = SIMD3<Float>(0, 0.08, 0)
            
            entity.addChild(modelEntity)
            entity.addChild(textEntity)
            
            // Add tap interaction
            entity.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(size: SIMD3<Float>(0.15, 0.15, 0.15))])
            entity.components[InputTargetComponent.self] = InputTargetComponent()
            
            return entity
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            
            guard let arView = gesture.view as? ARView else { return }
            
            let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any)
            
            if let result = results.first {
                // Handle tap on AR content
                print("Tapped at: \(result.worldTransform)")
            }
        }
    }
}

// MARK: - Dish Selector View
struct DishSelectorView: View {
    let dishes: [ARDish]
    @Binding var selectedDish: ARDish?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(dishes) { dish in
                    ARDishCard(dish: dish) {
                        selectedDish = dish
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.8), Color.clear],
                startPoint: .bottom,
                endPoint: .top
            )
        )
    }
}

// MARK: - AR Dish Card
struct ARDishCard: View {
    let dish: ARDish
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Dish image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                Text(dish.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(dish.formattedPrice)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(width: 100)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Instructions Overlay
struct InstructionsOverlay: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                VStack(spacing: 16) {
                    Text("AR Меню")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Наведите камеру на поверхность и выберите блюдо для просмотра в 3D")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                Button("Начать") {
                    onDismiss()
                }
                .font(.headline)
                .foregroundColor(.black)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.white)
                .clipShape(Capsule())
            }
        }
    }
}

// MARK: - AR Dish Detail Sheet
struct ARDishDetailSheet: View {
    let dish: ARDish
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Закрыть") {
                    isPresented = false
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Text("3D Просмотр")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("Заказать") {
                    // Add to cart logic
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color.black.opacity(0.9))
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    // 3D View placeholder
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "cube.transparent")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                Text("3D Модель блюда")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                    
                    // Dish info
                    VStack(alignment: .leading, spacing: 16) {
                        Text(dish.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(dish.description)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                        
                        // Stats
                        HStack(spacing: 20) {
                            ARStatItem(icon: "ruble", value: dish.formattedPrice)
                            ARStatItem(icon: "flame", value: dish.formattedCalories)
                            ARStatItem(icon: "clock", value: dish.formattedTime)
                        }
                        
                        // Ingredients
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ингредиенты:")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 8) {
                                ForEach(dish.ingredients, id: \.self) { ingredient in
                                    Text("• \(ingredient)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

// MARK: - AR Stat Item
struct ARStatItem: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    ARMenuView()
} 