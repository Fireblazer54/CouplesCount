import SwiftUI
import PhotosUI
import UIKit

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let prov = results.first?.itemProvider, prov.canLoadObject(ofClass: UIImage.self) else { return }
            prov.loadObject(ofClass: UIImage.self) { obj, _ in
                guard let ui = obj as? UIImage,
                      let data = ui.jpegData(compressionQuality: 0.9) else { return }
                DispatchQueue.main.async { self.parent.imageData = data }
            }
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    @Binding var imageData: Data?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = context.coordinator
        return vc
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let img = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            if let img, let data = img.jpegData(compressionQuality: 0.9) {
                parent.imageData = data
            }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { picker.dismiss(animated: true) }
    }
}
