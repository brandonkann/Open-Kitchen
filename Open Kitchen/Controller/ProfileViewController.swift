//
//  ProfileViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-01.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // - MARK There was some changes here!
    
    var array1 : Array<String> = []
    var valueToPass : String = ""
    var recievedValue : String = ""
    var email : String = (Auth.auth().currentUser?.email)!
    
      let db = Firestore.firestore()

    
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var profileUserName: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var recipeCollectionView: UICollectionView!
    @IBOutlet weak var recipeBookTitle: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
        navigationController?.navigationBar.topItem?.title = "My Profile"
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Thonburi-Bold", size: 22)!]
        UINavigationBar.appearance().titleTextAttributes = attributes

     }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let width = (view.frame.size.width - 20) / 3
        let layout = recipeCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
    
        
        recipeCollectionView.delegate = self
        recipeCollectionView.dataSource = self
        
        if recievedValue != "" {
        self.settingButton.isHidden = true
        print("1")
            print(recievedValue)
        loadStrangerData()
        loadEmailAddress()
        loadLikeRecipe2()
        recipeBookTitle.text = "CookBook"
        }
        else
        {
        print("2")
        self.tabBarController!.navigationItem.setHidesBackButton(true, animated: false)
        loadEmailAddress()
        loadPersonalData()
        loadLikeRecipe()
    

        }

    
        
    
        // Do any additional setup after loading the view.
    }
    
    func loadStrangerData() {
        db.collection("UserInfo").whereField("userEmail", isEqualTo: recievedValue)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let userImage = data["imageUrl"] as? String, let userDisplayName = data["userEmail"] as? String, let profession = data["Profession"] as? String, let location = data["Country"] as? String {
                             DispatchQueue.global().async {
                            let url = URL(string: userImage)
                            if let data = try? Data(contentsOf: url!)
                            {
                                DispatchQueue.main.async {
                                let image: UIImage = UIImage(data: data)!
                                    self.profileImageView.image = image
                                    self.email = userDisplayName
                                    self.professionLabel.text = profession
                                    self.countryLabel.text = location
                                    self.loadEmailAddress()
                                    self.loadLikeRecipe2()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadPersonalData() {
        let currentUser = Auth.auth().currentUser?.email
        db.collection("UserInfo").whereField("userEmail", isEqualTo: currentUser!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let userImage = data["imageUrl"] as? String, let profession = data["Profession"] as? String, let location = data["Country"] as? String,
                            let userEmail = data["userEmail"] as? String{
                             DispatchQueue.global().async {
                            let url = URL(string: userImage)
                            if let data = try? Data(contentsOf: url!)
                            {
                                DispatchQueue.main.async {
                                let image: UIImage = UIImage(data: data)!
                                    self.profileImageView.image = image
                                    self.countryLabel.text = location
                                    self.professionLabel.text = profession
                                    self.email = userEmail
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadEmailAddress() {
        db.collection("newUsers").whereField("email", isEqualTo: email)
         .getDocuments() { (querySnapshot, err) in
                 if let err = err {
                     print("Error getting documents: \(err)")
                 } else {
                     for document in querySnapshot!.documents {
                        let data = document.data()
                        if let loadedEmail = data["username"] as? String {
                            print(loadedEmail)
                            self.profileUserName.text = loadedEmail
                        }
                     }
                 }
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           array1.count
          }
          
          func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profilecell", for: indexPath) as! RecipeCollectionViewCell
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1.0;
            cell.personalRecipeName.text = array1[indexPath.row]
           return cell
          }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if let myCell = collectionView.cellForItem(at: indexPath) as? RecipeCollectionViewCell {
                valueToPass = (myCell.personalRecipeName.text)! as String

           self.performSegue(withIdentifier: "profileToRecipe", sender: self)
        }
        }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "profileToRecipe" {
        let destinationVC = segue.destination as! RecipeViewerViewController
        destinationVC.valueToPass = valueToPass
                }
    }
    
    func loadLikeRecipe() {
            let currentUser = Auth.auth().currentUser?.email
            db.collection("Chef").whereField("chef", isEqualTo: currentUser!)
              .addSnapshotListener { (queryShapshot, error) in
              if let e = error {
                  print("There was an issue retrieving data from Firestore \(e)")
              }
              else {
                  if let snapshotDocuments = queryShapshot?.documents {
                      for doc in snapshotDocuments {
                          let data = doc.data()
                        if let messageSender = data["recipe"] as? [String]  {
                            self.array1 = messageSender
                            DispatchQueue.main.async {
                            self.recipeCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
}
    
    func loadLikeRecipe2() {   //This whole area was used 
                db.collection("Chef").whereField("chef", isEqualTo: email)
                  .addSnapshotListener { (queryShapshot, error) in
                  if let e = error {
                      print("There was an issue retrieving data from Firestore \(e)")
                  }
                  else {
                      if let snapshotDocuments = queryShapshot?.documents {
                          for doc in snapshotDocuments {
                              let data = doc.data()
                            if let messageSender = data["recipe"] as? [String]  {
                                self.array1 = messageSender
                                print(self.array1)
                                DispatchQueue.main.async {
                                self.recipeCollectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    

    
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
    }
    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//    }
}
