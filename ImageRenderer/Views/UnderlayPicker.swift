//
//  UnderlayPicker.swift
//  HyperSketch
//
//  Created by Shawn Koh on 15/7/21.
//

import SwiftUI
import Resolver
import Combine

final class UnderlayPickerViewModel: ObservableObject {
    @LazyInjected private var contentViewModel: ContentViewModel

    init() {}

    func closeUnderlayPicker() {
        contentViewModel.mode = .underlay
    }

    func selectUnderlay(_ underlay: UIImage) {
        contentViewModel.underlay = underlay
        contentViewModel.mode = .underlay
    }
}

final class UnderlayPickerCoordinator: NSObject {
    var underlayPicker: UnderlayPicker

    init(_ underlayPicker: UnderlayPicker) {
        self.underlayPicker = underlayPicker
    }
}

extension UnderlayPickerCoordinator: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        underlayPicker.viewModel.selectUnderlay(image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        underlayPicker.viewModel.closeUnderlayPicker()
    }
}

extension UnderlayPickerCoordinator: UINavigationControllerDelegate {}

struct UnderlayPicker: UIViewControllerRepresentable {
    typealias Coordinator = UnderlayPickerCoordinator

    @StateObject var viewModel = UnderlayPickerViewModel()

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        context.coordinator.underlayPicker = self
    }
}

struct UnderlayPicker_Previews: PreviewProvider {
    static var previews: some View {
        UnderlayPicker()
    }
}
