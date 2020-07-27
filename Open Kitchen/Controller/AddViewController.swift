//
//  RecipeAdd0.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-08.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var recipeNameTextField: UITextField!

    @IBOutlet weak var recipeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView))

              recipeImageView.isUserInteractionEnabled = true
              recipeImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        picker.allowsEditing = true
    }
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        var selectedImageFromPicker :  UIImage?
        
        if let editedImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage").rawValue] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let orignalImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage").rawValue] as? UIImage {
            selectedImageFromPicker = orignalImage
        }
        if let selectedImage = selectedImageFromPicker {
            recipeImageView.image = selectedImage }
       picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           print("Canceled Image Picker")
           picker.dismiss(animated: true, completion: nil)
       }
       
    

    @IBAction func confirmed(_ sender: UIButton) {
    }
    
    
    

}
