//
//  ViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-01.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class ViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var registerButton: UIButton!
    var interstitial: GADInterstitial!
    

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8846014009643246/9007830246")
                              let request = GADRequest()
                                interstitial.load(request)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: "LoginToTransfer", sender: self)
            
        } else {
            print("User needs to sign in")
        }
    }

    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = loginTextField.text, let password = passwordTextField.text {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let e = error {
                print(e)
            }
            else {
                if self.interstitial.isReady {
                    self.interstitial.present(fromRootViewController: self)
                                 } else {
                                   print("Ad wasn't ready")
                                 }
                self.performSegue(withIdentifier: "LoginToTransfer", sender: self)
            }
            }
        }
    }
}


