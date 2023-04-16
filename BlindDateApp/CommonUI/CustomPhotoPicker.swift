//
//  CustomPhotoPicker.swift
//  BlindDateApp
//
//  Created by 盛杰厚 on 2023/3/10.
//

import SwiftUI
import PhotosUI

struct CustomPhotoPicker: UIViewControllerRepresentable {
        var configuration: PHPickerConfiguration
        @Binding var pickerResult: [UIImage]
        @Binding var isPresented: Bool
        func makeUIViewController(context: Context) -> PHPickerViewController {
            let controller = PHPickerViewController(configuration: configuration)
            controller.delegate = context.coordinator
            controller.modalPresentationStyle = .popover
            return controller
        }
        func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        /// PHPickerViewControllerDelegate => Coordinator
        class Coordinator: PHPickerViewControllerDelegate {
            
            private let parent: CustomPhotoPicker
            
            init(_ parent: CustomPhotoPicker) {
                self.parent = parent
            }
           
            func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                let semaphore = DispatchSemaphore(value: 1)
                for image in results {
                    if image.itemProvider.canLoadObject(ofClass: UIImage.self)  {
                        semaphore.wait()
                        image.itemProvider.loadObject(ofClass: UIImage.self) { (newImage, error) in
                            if let error = error {
                                print(error.localizedDescription)
                            } else {
                                self.parent.pickerResult.append(newImage as!UIImage)
                                semaphore.signal()
                            }
                        }
                       
                    } else {
                        print("Loaded Assest is not a Image")
                    }
                }
                // dissmiss the picker
                DispatchQueue.main.async {
                    self.parent.isPresented = false
                }
            }
        }
}

