//
//  ImagePicker.swift
//  ToDos
//
//  Created by Scholar on 6/27/24.
//
import SwiftUI
import UIKit

struct ImagePicker : UIViewControllerRepresentable{
    @Binding var selectedPhoto: UIImage?
    @Binding var isImagePickerShowing: Bool
    var sourceType: UIImagePickerController.SourceType
    func makeUIViewController(context: Context) -> some UIViewController {
            
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
            
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        
            return Coordinator(self)
        }
    
}



class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    DispatchQueue.main.async {
                        self.parent.selectedPhoto = image
                    }
                }
        parent.isImagePickerShowing = false

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent.isImagePickerShowing = false
    }
    
    var parent: ImagePicker
        
        init(_ picker: ImagePicker) {
            self.parent = picker
        }
    
}


