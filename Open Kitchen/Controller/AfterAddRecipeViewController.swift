//
//  AfterAddRecipeViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-07-03.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//
import GoogleMobileAds
import UIKit


class AfterAddRecipeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addReview(_ sender: UIButton) {
        // Write a review Here
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/1524104312?action=write-review")
                else { fatalError("Expected a valid URL") }
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func sendBack(_ sender: Any) {
        performSegue(withIdentifier: "sendBack", sender: self)
    }
    
}
