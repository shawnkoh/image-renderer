//
//  ContentView.swift
//  ImagePreview
//
//  Created by Shawn Koh on 3/8/21.
//

import SwiftUI
import Resolver

final class ContentViewModel: ObservableObject {
    enum Mode {
        case underlay
        case preview
        case underlayPicker
    }

    @Published var mode: Mode = .underlay

    // MARK: - Underlay

    @Published var underlay: UIImage?

    @Published var angle: Angle = .zero
    @Published var currentAngle: Angle = .zero

    @Published var scale: Double = 1
    private var lastScale: Double = 1

    @Published var offset: CGSize = .zero
    @Published var currentOffset: CGSize = .zero

    // MARK: - Actual Preview

    @Published var preview: UIImage?

    func magnifyOnChanged(scaleDelta: MagnificationGesture.Value) {
        let delta = scaleDelta / CGFloat(self.lastScale)
        self.lastScale = Double(scaleDelta)
        let newScale = CGFloat(self.scale) * delta
        self.scale = Double(newScale)
    }

    func magnifyOnEnded(scaleDelta: MagnificationGesture.Value) {
        self.lastScale = 1
    }

    func rotateOnChanged(angle: RotationGesture.Value) {
        self.angle = angle
    }

    func rotateOnEnded(angle: RotationGesture.Value) {
        self.currentAngle += self.angle
        self.angle = .degrees(0)
    }

    func dragOnChanged(delta: DragGesture.Value) {
        currentOffset = delta.translation
    }

    func dragOnEnded(delta: DragGesture.Value) {
        offset += currentOffset
        currentOffset = .zero
    }

    func makePreview(length: Double) {
        self.preview = makeImage(length: length)
    }

    func export(length: Double) {
        guard let image = makeImage(length: length) else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }

    func makeImage(length: Double) -> UIImage? {
        guard let underlay = underlay else {
            return nil
        }
        return autoreleasepool {
            UIGraphicsImageRenderer(size: .init(width: length, height: length))
                .image { context in
                    let angle = self.angle + self.currentAngle
                    let offset = self.offset + self.currentOffset
                    // scale the image relative to the UI (because SwiftUI does this) while maintaining the aspect ratio
                    // to do so, we need to find which side is bigger and scale it by that.
                    let uiScale: CGFloat
                    if underlay.size.width > underlay.size.height {
                        uiScale = UIScreen.canvasLength / underlay.size.width
                    } else {
                        uiScale = UIScreen.canvasLength / underlay.size.height
                    }
                    let outputScale = CGFloat(length) / UIScreen.canvasLength
                    let width = underlay.size.width * uiScale * CGFloat(scale) * outputScale
                    let height = underlay.size.height * uiScale * CGFloat(scale) * outputScale

                    // TODO: Using context and context.cgContext, apply the appropriate transformations before calling underlay.draw(in:)
                }
        }
    }
}

public enum ExportResolution: Double, CustomStringConvertible, Codable {
    case low = 1
    case medium = 2
    case high = 3

    public var description: String {
        switch self {
        case .low:
            return "LOW"
        case .medium:
            return "MED"
        case .high:
            return "HIGH"
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel = Resolver.resolve()
    @State var resolution: ExportResolution = .medium

    @ViewBuilder
    private var underlayPicker: some View {
        if viewModel.mode == .underlayPicker {
            UnderlayPicker()
        }
    }

    var body: some View {
        Color.gray
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .overlay(WorldView())
            .overlay(
                VStack {
                    Button {
                        viewModel.mode = .underlayPicker
                    } label: {
                        Text("Select Image")
                    }

                    Button {
                        switch viewModel.mode {
                        case .underlay:
                            viewModel.mode = .preview
                        default:
                            viewModel.mode = .underlay
                        }
                    } label: {
                        Text("Show \(viewModel.mode == .preview ? "Underlay" : "Preview")")
                    }

                    Button {
                        viewModel.makePreview(length: Double(UIScreen.screenHeight))
                    } label: {
                        Text("Make Preview")
                    }

                    Button {
                        switch resolution {
                        case .low:
                            resolution = .medium
                        case .medium:
                            resolution = .high
                        case .high:
                            resolution = .low
                        }
                    } label: {
                        Text(resolution.description)
                    }

                    Button {
                        viewModel.export(length: resolution.rawValue)
                    } label: {
                        Text("Export")
                    }
                }
                .background(
                    Color.black
                )
                ,
                alignment: .trailing
            )
            .overlay(underlayPicker)
            .ignoresSafeArea()
            .statusBar(hidden: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - Relevant code found on stackoverflow

extension UIImage {
    func rotate(degrees: Double) -> UIImage? {
        let radians = degrees * .pi / 180
        return rotate(radians: radians)
    }

    // Adapted from rotate(radians:)
    func rotate2(radians: Double) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        return UIGraphicsImageRenderer(size: .init(width: newSize.width, height: newSize.height))
            .image { context in
                context.cgContext.translateBy(x: newSize.width / 2, y: newSize.height / 2)
                context.cgContext.rotate(by: CGFloat(radians))
                self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
            }
    }

    // Credit: https://stackoverflow.com/a/47402811/8639572
    func rotate(radians: Double) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

