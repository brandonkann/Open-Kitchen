//
//  RegisterViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-01.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class RegisterViewController: UIViewController {
     var interstitial: GADInterstitial!
    let db = Firestore.firestore()


    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

         interstitial = GADInterstitial(adUnitID: "ca-app-pub-8846014009643246/9007830246")
                                     let request = GADRequest()
                                       interstitial.load(request)
    }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width - 385, y: self.view.frame.size.height-450, width: 350, height: 35))
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
    

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password  = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let e = error {
                self.showToast(message: "\(e.localizedDescription)", font: .systemFont(ofSize: 12.0))
                }
            else {
                if self.userName.text != ""{
                let uid = (Auth.auth().currentUser?.uid)!
                self.db.collection("newUsers").document(email).setData([
                    "email" : email,
                    "userID": uid,
                    "username": self.userName.text ?? "Guest",
                    "creationDate": String(describing: Date())
                ]) { err in
                    if let err = err {
                        print("\(err)")
                    } else {
                         if self.interstitial.isReady {
                                           self.interstitial.present(fromRootViewController: self)
                                                        } else {
                                                          print("Ad wasn't ready")
                                                        }
                        self.performSegue(withIdentifier: "RegisterToRecipe", sender: self)
                    }
                }
            }
                else {
                    self.showToast(message: "Add a Username", font: .systemFont(ofSize: 12.0))
                }
            }
    }
}
}

}
