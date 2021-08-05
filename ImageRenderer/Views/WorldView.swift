//
//  WorldView.swift
//  WorldView
//
//  Created by Shawn Koh on 3/8/21.
//

import SwiftUI
import Resolver

struct WorldView: View {
    @StateObject private var viewModel: ContentViewModel = Resolver.resolve()

    @ViewBuilder
    var imageView: some View {
        if viewModel.mode == .underlay, let underlay = viewModel.underlay {
            Image(uiImage: underlay)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
                .rotationEffect(viewModel.angle + viewModel.currentAngle)
                .scaleEffect(CGFloat(viewModel.scale))
                .offset(viewModel.offset + viewModel.currentOffset)
        } else if viewModel.mode == .preview, let preview = viewModel.preview {
            Image(uiImage: preview)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .ignoresSafeArea()
        }
    }

    var body: some View {
        let rotationGesture = RotationGesture()
            .onChanged(viewModel.rotateOnChanged(angle:))
            .onEnded(viewModel.rotateOnEnded(angle:))

        let magnificationGesture = MagnificationGesture()
            .onChanged(viewModel.magnifyOnChanged(scaleDelta:))
            .onEnded(viewModel.magnifyOnEnded(scaleDelta:))

        let dragGesture = DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged(viewModel.dragOnChanged(delta:))
            .onEnded(viewModel.dragOnEnded(delta:))

        let gesture = magnificationGesture.simultaneously(with: rotationGesture).simultaneously(with: dragGesture)

        Color.white
            .frame(width: UIScreen.screenHeight, height: UIScreen.screenHeight)
            .overlay(imageView)
            .gesture(gesture)
    }
}

struct WorldView_Previews: PreviewProvider {
    static var previews: some View {
        WorldView()
    }
}
