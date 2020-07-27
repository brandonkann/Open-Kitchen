//
//  RecipeViewerViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-10.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class RecipeViewerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var valueToPass : String = ""
    var valueToPass1 : UIImage? = #imageLiteral(resourceName: "Untitled design (4).png")
    var valueToPass2 : String = ""
    var valueToPassToProfile : String = ""
    var likesOld : Int  = 0
    var likesNew : String = "0"
    var userName : String = ""
    var viewers = [String]()
    var likers = [String]()
    var ownersEmail : String = ""
    var bannerView: GADBannerView!
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var methodsTableView: UITableView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var submitPressed: UIButton!
    @IBOutlet weak var recipeOwner: UILabel!
    @IBOutlet weak var descriptionDetails: UILabel!
    
    var ingredients : [Ingredient] = []
    var methods : [Methods] = []
    var recipeMethods : [RecipeMethods] = []
    var comment: [Comment] = []
    
    var numberOfIngredients = 0
    var numberOfMethods = 0
    var numberOfComments = 0
    
    let db = Firestore.firestore()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.rightBarButtonItem?.tintColor = UIColor.red
        


        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        methodsTableView.delegate = self
        methodsTableView.dataSource = self
        commentTableView.dataSource = self
        commentTableView.delegate = self
        commentTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "commentCell")
        recipeTitle.text = valueToPass
        loadExistingImage()
    
      
               
        loadIngredientsData()
        loadMethodsImages()
        loadLikeData()
        loadUserData()
        loadCommentData()
        loadUserName()
        loadRecipeDescription()
        
    // Banner Stuff
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)

           addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-8846014009643246/7111346525"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
         }

         func addBannerViewToView(_ bannerView: GADBannerView) {
           bannerView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(bannerView)
           view.addConstraints(
             [NSLayoutConstraint(item: bannerView,
                                 attribute: .bottom,
                                 relatedBy: .equal,
                                 toItem: view,
                                 attribute: .bottomMargin,
                                 multiplier: 1,
                                 constant: 0),
              NSLayoutConstraint(item: bannerView,
                                 attribute: .centerX,
                                 relatedBy: .equal,
                                 toItem: view,
                                 attribute: .centerX,
                                 multiplier: 1,
                                 constant: 0)
             ])
          }
    
    @IBAction func sendToProfile(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "recipeToProfile", sender: self)
        valueToPassToProfile = ownersEmail
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                    if segue.identifier == "recipeToProfile" {
                        let destinationVC = segue.destination as! ProfileViewController
                        destinationVC.recievedValue = ownersEmail
                    }
             }
    
    func loadUserName() {
        let currentUser = Auth.auth().currentUser?.email
        db.collection("newUsers").whereField("email", isEqualTo: currentUser!)
         .getDocuments() { (querySnapshot, err) in
                 if let err = err {
                     print("Error getting documents: \(err)")
                 } else {
                     for document in querySnapshot!.documents {
                        let data = document.data()
                        if let displayName = data["username"] as? String {
                            self.userName = displayName
                            print(self.userName)
                        }
                     }
                 }
         }
    }
    
    func loadRecipeDescription() {
        db.collection("recipeDescription").whereField("recipeName", isEqualTo: recipeTitle.text!)
         .getDocuments() { (querySnapshot, err) in
                 if let err = err {
                     print("Error getting documents: \(err)")
                 } else {
                     for document in querySnapshot!.documents {
                        let data = document.data()
                        if let description = data["recipeDescription"] as? String {
                            self.descriptionDetails.text = description
                        }
                     }
                 }
         }
    }
    
    func loadExistingImage() {
        db.collection("RecipeImage").whereField("recipeName", isEqualTo: recipeTitle.text!)
            .addSnapshotListener() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let recipeImage = data["imageUrl"] as? String, let chef = data["sender"] as? String, let ownerEmail = data["senderEmail"] as? String {
                             DispatchQueue.global().async {
                            let url = URL(string: recipeImage)
                            if let data = try? Data(contentsOf: url!)
                            {
                                DispatchQueue.main.async {
                                let image: UIImage = UIImage(data: data)!
                                    self.recipeImage.image = image
                                    self.recipeOwner.text = chef
                                    self.ownersEmail = ownerEmail
                                }
                            }
                        }
                    }
                }
            }
        }
    
    }
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 100, y: self.view.frame.size.height-200, width: 200, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 5.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }

    
    @IBAction func likeButtonPressed(_ sender: UIBarButtonItem) {
        let currentUser = Auth.auth().currentUser?.email
        if viewers.contains(currentUser!) {
                  self.navigationItem.rightBarButtonItem?.isEnabled = false
                  self.showToast(message: "You have already like this post!", font: .systemFont(ofSize: 12.0))
               }
        else {
            likesOld = Int(likesNew)! + 1
            viewers.append(currentUser!)
            likers.append(recipeTitle.text!)
            self.showToast(message: "You have liked the post!", font: .systemFont(ofSize: 12.0))
            addLikeData()
            addUserLikeCollection()
        }
    }
    
    func loadLikeData() {
        db.collection("Likes").whereField("recipeName", isEqualTo: recipeTitle.text!).getDocuments()
       { (querySnapshot, error) in
          if let e = error {
              print("There was an issue retrieving data from Firestore \(e)")
          }
          else {
            for document in querySnapshot!.documents {
                      let data = document.data()
                if let newLikes = data["numberOfLikes"] as? String, let newViewers = data["viewers"] as? [String] {
                        self.likesNew = newLikes
                        self.likesLabel.text = self.likesNew
                        self.viewers = newViewers
        
                    }
                }
            }
        }
    }
    
    func loadUserData() {
        let userLiker = Auth.auth().currentUser?.email
        db.collection("Users").whereField("user", isEqualTo: userLiker!).getDocuments()
        { (querySnapshot, error) in
           if let e = error {
               print("There was an issue retrieving data from Firestore \(e)")
           }
           else {
             for document in querySnapshot!.documents {
                       let data = document.data()
                if let userLiked = data["recipeName"] as? [String]{
                         self.likers = userLiked
                     }
                 }
             }
         }
        
    }
    
    func addUserLikeCollection() {
        let userLiker = Auth.auth().currentUser?.email
        db.collection("Users").document(userLiker!).setData([
            "user" : userLiker!,
            "recipeName" : likers
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    func addLikeData() {
        db.collection("Likes").document(recipeTitle.text!).setData([
            "numberOfLikes": "\(likesOld)",
            "recipeName" : "\(recipeTitle.text!)",
            "viewers" : viewers,
            "sender" : "\(recipeOwner.text!)"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    
    
    func loadIngredientsData() {
        db.collection("Ingredients").whereField("recipeName", isEqualTo: recipeTitle.text!)
      .addSnapshotListener { (queryShapshot, error) in
      self.ingredients = []
      if let e = error {
          print("There was an issue retrieving data from Firestore \(e)")
      }
      else {
          if let snapshotDocuments = queryShapshot?.documents {
              for doc in snapshotDocuments {
                  let data = doc.data()
                if let messageSender = data["Ingredients"] as? String {
                      let newMessage = Ingredient(ingredient: messageSender)
                      self.ingredients.append(newMessage)
                    DispatchQueue.main.async {
                    self.ingredientsTableView.reloadData()
    }
            }
        }
        }
        }
    }
    }
    
//    func loadMethodsData() {
//        db.collection("recipeMethods").whereField("recipeName", isEqualTo: recipeTitle.text!)
//      .addSnapshotListener { (queryShapshot, error) in
//      self.recipeMethods = []
//      if let e = error {
//          print("There was an issue retrieving data from Firestore \(e)")
//      }
//      else {
//          if let snapshotDocuments = queryShapshot?.documents {
//              for doc in snapshotDocuments {
//                  let data = doc.data()
//                if let messageSender = data["Methods"] as? String {
//                      let newMessage = RecipeMethods(description: messageSender)
//                      self.recipeMethods.append(newMessage)
//                    DispatchQueue.main.async {
//                    self.methodsTableView.reloadData()
//    }
//            }
//        }
//        }
//        }
//    }
//    }
    
    func loadMethodsImages() {
        db.collection("Method Images").whereField("imageToMethod", isEqualTo: recipeTitle.text!)
               .getDocuments() { (querySnapshot, err) in
                   if let err = err {
                       print("Error getting documents: \(err)")
                   } else {
                       for document in querySnapshot!.documents {
                           let data = document.data()
                           if let methodImage = data["imageUrl"] as? String, let recipeMethod = data["Method Description"] as? String, let date = data["date"] as? String  {
                            DispatchQueue.global().async {
                               let url = URL(string: methodImage)
                               if let data = try? Data(contentsOf: url!)
                               {
                                   let image: UIImage = UIImage(data: data)!
                                self.recipeMethods.append(RecipeMethods(image: image, description: recipeMethod, date: date))
                                 self.recipeMethods = self.recipeMethods.sorted(by: { $0.date < $1.date})
                                   DispatchQueue.main.async {
                                   self.methodsTableView.reloadData()
                                       }
                               }
                           }
                       }
                   }
                }
            }
        }

    
    func loadCommentData() {
        db.collection("comments").whereField("recipeName", isEqualTo: recipeTitle.text!)
          .addSnapshotListener { (querySnapshot, error) in
            self.comment = []
          if let e = error {
              print("There was an issue retrieving data from Firestore \(e)")
          }
          else {
             for document in querySnapshot!.documents {
              let data = document.data()
                    if let messageSender = data["sender"] as? String, let messageBody = data["comment"] as? String {
                          let newMessage = Comment(sender: messageSender, body: messageBody)
                          self.comment.append(newMessage)
                        DispatchQueue.main.async {
                        self.commentTableView.reloadData()
                            let indexPath = IndexPath(row: self.comment.count - 1, section: 0)
                            self.commentTableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = commentTextField.text
        {
            db.collection("comments").addDocument(data: ["sender" :userName, "comment" : messageBody, "recipeName" : recipeTitle.text!, "date": Date().timeIntervalSince1970])
            { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                }
                else {
                    print("Successfully Saved data")
                    
                    DispatchQueue.main.async {
                     self.commentTextField.text = ""
                    }
                }
            }
            
        }
        
        
    }

    


    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 1) {
            numberOfIngredients = ingredients.count
            return numberOfIngredients
        }
        else if (tableView.tag == 2) {
            numberOfMethods = recipeMethods.count
            return numberOfMethods
        }
        else if (tableView.tag == 3) {
            numberOfComments = comment.count
            return numberOfComments
        }
            return 0
    }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView.tag == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "celli", for: indexPath) as
            UITableViewCell
            let ingredient = ingredients[indexPath.row]
            cell.textLabel?.text = "\(ingredient.ingredient)"
            cell.textLabel?.textColor = UIColor.black
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        return cell
          }
          
        else if (tableView.tag == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellm", for: indexPath) as? RecipeCell
            let methodn = recipeMethods[indexPath.row]
            cell?.setRecipeMethods(method: methodn)
            cell?.methodText?.font = UIFont.boldSystemFont(ofSize: 16.0)
        return cell!
        }
        else if (tableView.tag == 3) {
            let newComment = comment[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentCell
            cell.user.text = newComment.body
            cell.comments.text = newComment.sender
            cell.user?.textColor = UIColor.black
            cell.user?.font = UIFont.boldSystemFont(ofSize: 16.0)
        return cell
            
            
        }
    return UITableViewCell()
    }
      }

