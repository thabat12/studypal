//
//  ImagePicker.swift
//  StudyPal
//
//  Created by Tejas Cheeti on 4/8/25.
//


import SwiftUI

import UIKit

struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode) private var presentationMode

    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {

        let picker = UIImagePickerController()

        picker.delegate = context.coordinator

        picker.allowsEditing = true

        picker.sourceType = .photoLibrary

        return picker

    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {

        Coordinator(self)

    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        let parent: ImagePicker

        init(_ parent: ImagePicker) {

            self.parent = parent

        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

            if let image = info[.editedImage] as? UIImage {

                parent.selectedImage = image

            }

            parent.presentationMode.wrappedValue.dismiss()

        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {

            parent.presentationMode.wrappedValue.dismiss()

        }

    }

}

