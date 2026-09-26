import SwiftUI

struct GameplayOverlay: View {
    let scene: RoomScene
    let isIntroBlockingHUD: Bool
    let isStoryDialogBlockingControls: Bool

    @ObservedObject private var interactableManager: InteractableManager
    @StateObject private var hudViewModel: HUDViewModel
    @State private var isMonologueDismissing = false

    init(
        scene: RoomScene,
        isIntroBlockingHUD: Bool,
        isStoryDialogBlockingControls: Bool
    ) {
        self.scene = scene
        self.isIntroBlockingHUD = isIntroBlockingHUD
        self.isStoryDialogBlockingControls = isStoryDialogBlockingControls
        _interactableManager = ObservedObject(wrappedValue: scene.interactableManager)
        _hudViewModel = StateObject(
            wrappedValue: HUDViewModel(input: InputBridge(scene: scene))
        )
    }

    private var areControlsVisible: Bool {
        !isIntroBlockingHUD && !isStoryDialogBlockingControls && (
            interactableManager.activeMonologue == nil || isMonologueDismissing
        )
    }

    var body: some View {
        ZStack {
            HUDView(viewModel: hudViewModel)
                .opacity(areControlsVisible ? 1 : 0)
                .allowsHitTesting(areControlsVisible)
                .animation(.easeInOut(duration: 0.2), value: areControlsVisible)

            GameStatusOverlay(session: scene.session)
                .opacity(isIntroBlockingHUD ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: isIntroBlockingHUD)

            MonologueObserver(
                manager: interactableManager,
                onDismissalStateChange: { isDismissing in
                    isMonologueDismissing = isDismissing
                }
            )
        }
        .onAppear {
            hudViewModel.setControlsEnabled(areControlsVisible)
        }
        .onChange(of: areControlsVisible) { _, isVisible in
            hudViewModel.setControlsEnabled(isVisible)
        }
    }
}

struct MonologueObserver: View {
    @ObservedObject var manager: InteractableManager
    let onDismissalStateChange: (Bool) -> Void

    var body: some View {
        if let monologue = manager.activeMonologue {
            MonologueOverlayView(
                objectName: monologue.objectName,
                monologueText: monologue.text,
                onDismissStarted: {
                    onDismissalStateChange(true)
                },
                onDismiss: {
                    manager.dismissMonologue()
                    onDismissalStateChange(false)
                }
            )
        }
    }
}
