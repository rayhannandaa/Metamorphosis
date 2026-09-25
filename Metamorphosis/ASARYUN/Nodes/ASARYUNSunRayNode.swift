//
//  ASARYUNSunRayNode.swift
//  ASARYUN
//
//  A single persistent trapezoid of light anchored below the window.
//  Its horizontal top edge stays fixed while its wider horizontal bottom
//  edge sweeps from side to side.
//

import CoreImage
import SpriteKit

final class ASARYUNSunRayNode: SKShapeNode {
    private let topWidth: CGFloat
    private let bottomWidth: CGFloat
    private let rayHeight: CGFloat
    private let bottomCurveDepth: CGFloat
    private let visualShape = SKShapeNode()
    private let blurEffect = SKEffectNode()
    private var bottomOffset: CGFloat = 0
    private var isLightActive = false

    init(topWidth: CGFloat, bottomWidth: CGFloat, height: CGFloat) {
        self.topWidth = topWidth
        self.bottomWidth = bottomWidth
        rayHeight = height
        bottomCurveDepth = ASARYUNGameConfig.sunRayBottomCurveDepth
        super.init()

        name = "ASARYUN_SunRay"
        alpha = 0
        zPosition = 4

        // The parent path owns the matching physics geometry but remains
        // invisible. Its child is blurred normally, avoiding a bright glow
        // around the beam boundary.
        fillColor = .clear
        strokeColor = .clear
        lineWidth = 0

        let lightColor = SKColor(
            red: 1,
            green: 0.95,
            blue: 0.68,
            alpha: 1
        )
        visualShape.fillColor = lightColor
        visualShape.strokeColor = lightColor
        visualShape.lineWidth = 0

        blurEffect.filter = CIFilter(
            name: "CIGaussianBlur",
            parameters: [kCIInputRadiusKey: ASARYUNGameConfig.sunRayEdgeBlurRadius]
        )
        blurEffect.shouldEnableEffects = true
        blurEffect.shouldRasterize = true
        blurEffect.addChild(visualShape)
        addChild(blurEffect)

        updateGeometry(bottomOffset: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Moves only the bottom edge. Both the top and bottom remain horizontal.
    func setBottomOffset(_ offset: CGFloat, animated: Bool = true) {
        removeAction(forKey: "ASARYUNSunRaySweep")

        if animated {
            let startingOffset = bottomOffset
            let distance = offset - startingOffset
            let action = SKAction.customAction(
                withDuration: ASARYUNGameConfig.sunRayTransitionDuration
            ) { [weak self] _, elapsedTime in
                let duration = CGFloat(ASARYUNGameConfig.sunRayTransitionDuration)
                let progress = duration > 0 ? elapsedTime / duration : 1
                self?.updateGeometry(bottomOffset: startingOffset + distance * progress)
            }
            action.timingMode = .easeInEaseOut
            run(action, withKey: "ASARYUNSunRaySweep")
        } else {
            updateGeometry(bottomOffset: offset)
        }
    }

    func show() {
        isLightActive = true
        guard alpha < ASARYUNGameConfig.sunRayAlpha else { return }
        run(
            .fadeAlpha(
                to: ASARYUNGameConfig.sunRayAlpha,
                duration: ASARYUNGameConfig.sunRayTransitionDuration
            ),
            withKey: "ASARYUNSunRayFade"
        )
    }

    func hide() {
        isLightActive = false
        removeAction(forKey: "ASARYUNSunRayFade")
        run(.fadeOut(withDuration: 0.5), withKey: "ASARYUNSunRayFade")
    }

    /// Uses the ray's current visual path rather than physics contacts. The
    /// path changes during every sweep frame, so this always matches what the
    /// player can actually see on screen.
    func containsScenePoint(_ scenePoint: CGPoint) -> Bool {
        guard isLightActive, let parent, let path else { return false }
        let localPoint = convert(scenePoint, from: parent)
        return path.contains(localPoint)
    }

    private func updateGeometry(bottomOffset: CGFloat) {
        self.bottomOffset = bottomOffset

        let topLeft = CGPoint(x: -topWidth / 2, y: 0)
        let topRight = CGPoint(x: topWidth / 2, y: 0)
        let bottomRight = CGPoint(x: bottomOffset + bottomWidth / 2, y: -rayHeight)
        let bottomLeft = CGPoint(x: bottomOffset - bottomWidth / 2, y: -rayHeight)

        // A half-ellipse needs control points 4/3 of the curve depth below
        // its endpoints. This keeps the cap smooth and horizontally tangent
        // where it meets each side of the beam.
        let visualPath = CGMutablePath()
        visualPath.move(to: topLeft)
        visualPath.addLine(to: topRight)
        visualPath.addLine(to: bottomRight)
        visualPath.addCurve(
            to: bottomLeft,
            control1: CGPoint(
                x: bottomRight.x,
                y: bottomRight.y - (4 * bottomCurveDepth / 3)
            ),
            control2: CGPoint(
                x: bottomLeft.x,
                y: bottomLeft.y - (4 * bottomCurveDepth / 3)
            )
        )
        visualPath.closeSubpath()
        path = visualPath
        visualShape.path = visualPath

    }
}
