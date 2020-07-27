//
//  SettingViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-21.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase

class SettingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var db = Firestore.firestore()

    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var professionTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

       loadPersonalInfo()
       loadCurrentDisplayName()
    }
    
    func loadCurrentDisplayName() {
        let currentUser = Auth.auth().currentUser?.email
        db.collection("newUsers").whereField("email", isEqualTo: currentUser!)
        .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                       let data = document.data()
                       if let loadedEmail = data["username"] as? String {
                        self.displayNameTextField.text = loadedEmail
                       }
                    }
                }
        }
        
    }
    
    func showToast(message : String, font: UIFont) {

          let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width - 385, y: self.view.frame.size.height-100, width: 350, height: 35))
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
    
    func loadPersonalInfo() {
            let currentUser = Auth.auth().currentUser?.email
            db.collection("UserInfo").whereField("userEmail", isEqualTo: currentUser!)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            let data = document.data()
                            if let userImage = data["imageUrl"] as? String, let profession = data["Profession"] as? String, let location = data["Country"] as? String {
                                 DispatchQueue.global().async {
                                let url = URL(string: userImage)
                                if let data = try? Data(contentsOf: url!)
                                {
                                    DispatchQueue.main.async {
                                    let image: UIImage = UIImage(data: data)!
                                        self.profilePicImageView.image = image
                                        self.locationTextField.text = location
                                        self.professionTextField.text = profession
                                        
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
    

    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        picker.allowsEditing = true
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled Image Picker")
        picker.dismiss(animated: true, completion: nil)
       }
       
       
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        let image = info[UIImagePickerController.InfoKey.originalImage]
           profilePicImageView?.image = (image as! UIImage)
       self.dismiss(animated: true, completion: nil)
       }
         
    
    
    
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        changeDisplayName()
        let currentUser = Auth.auth().currentUser?.email
        guard let image = profilePicImageView.image, let data = image.jpegData(compressionQuality: 1.0)
                       else {
                           print("something went wrong")
                           return
                   }
                   let imageName = UUID().uuidString
                   let imageReference = Storage.storage().reference().child(imageName)
                   
                   imageReference.putData(data, metadata: nil) { (metadata, err) in
                       if err != nil {
                           print("Error")
                           return
                       }
                       imageReference.downloadURL(completion: { (url, err) in
                           if err != nil {
                               print("Error")
                               return
                       }
                           guard let url = url else {
                               print("error")
                               return
                           }
                        let dataReference = Firestore.firestore().collection("UserInfo").document(currentUser!)
                           let urlString = url.absoluteString
                           let currentUser = Auth.auth().currentUser?.email
                        let data = [
                                    "Country" : self.locationTextField.text!,
                                    "Profession": self.professionTextField.text!,
                                    "imageUrl" : urlString,
                                    "userEmail" : currentUser]
                        dataReference.setData(data as [String : Any]) { (err) in
                               if err != nil {
                                   print("Error")
                                   return
                               }
                            self.showToast(message: "Profile Updated!", font: .systemFont(ofSize: 12.0) )
                           }
                   })
               }
    }
    
    func changeDisplayName() {
        let currentUser = Auth.auth().currentUser?.email
         db.collection("newUsers").document(currentUser!).setData([
            "email" : currentUser!,
            "username" : displayNameTextField.text!
               ]) { err in
                   if let err = err {
                       print("Error writing document: \(err)")
                   } else {
                       print("Document successfully written!!!")
                   }
               }
           }

    
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        showToast(message: "Logged Out", font: .systemFont(ofSize: 12.0) )
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
            
            } catch let err {
                print(err)
        }
        navigationController?.popToRootViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
