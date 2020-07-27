//
//  recipeNameViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-24.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase

class recipeNameViewController: UIViewController {
    

    
    var nameTaken : Bool = false
    var allowEntry: Bool = true
    var alreadyPressed : Bool = false
    var valueToPass : String = ""
    let db = Firestore.firestore()
    
    @IBOutlet weak var recipeNameTextField: UITextField!

    
    @IBOutlet weak var recipeDescriptionTextView: UITextView!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       navigationController?.navigationBar.topItem?.title = "Open Kitchen"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width - 385, y: self.view.frame.size.height - 200, width: 350, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 7.0, delay: 1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    @IBAction func check(_ sender: UIButton) {
           sideCheck()
    
        alreadyPressed = true
        showToast(message: "Agreed", font: .systemFont(ofSize: 12.0))

       }

    @IBAction func recipeNameTransfer(_ sender: UIButton) {
        print(allowEntry)
        print(nameTaken)
        print(alreadyPressed)
        
        if nameTaken == true {
            showToast(message: "Name Taken", font: .systemFont(ofSize: 12.0))
            allowEntry = true
            nameTaken = false
            alreadyPressed = false
        }
        else if allowEntry == true && nameTaken == false && alreadyPressed == false {
            showToast(message: "Confirm your title and description", font: .systemFont(ofSize: 12.0))
             alreadyPressed = false
        }
        else if allowEntry == true && nameTaken == false && alreadyPressed == true {
        saveRecipeDescriptions()
            valueToPass = recipeNameTextField.text!
        performSegue(withIdentifier: "recipeNameOk", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "recipeNameOk" {
               let destinationVC = segue.destination as! AddRecipeViewController
               destinationVC.nameToPass = valueToPass
           }
    }
    
    func saveRecipeDescriptions() {
        db.collection("recipeDescription").document().setData(
            ["recipeName" : recipeNameTextField.text!,
             "recipeDescription" : recipeDescriptionTextView.text ?? ""])
             { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    

    func sideCheck() {
        db.collection("Ingredients").whereField("recipeName", isEqualTo: recipeNameTextField.text!)
        .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                       let data = document.data()
                       if let recipeTaken = data["recipeName"] as? String {
                        if recipeTaken == self.recipeNameTextField.text {
                            print(recipeTaken)
                            self.nameTaken = true
                            print(self.nameTaken)
                            }
                       }
                    }
                }
            }
    }
    
    
//    func isNameTaken() {
//        db.collection("Ingredients").whereField("recipeName", isEqualTo: recipeNameTextField.text!)
//        .getDocuments() { (querySnapshot, err) in
//            if let err = err {
//        print("Error getting documents: \(err)")
//            } else {
//            for document in querySnapshot!.documents {
//            let data = document.data()
//                if let isRecipeTaken = data["recipeName"] as? String {
//                    print(isRecipeTaken)
//                }
//                else {
//                    print("worked")
//                }
//            }
//        }
//    }
//}
    
}
