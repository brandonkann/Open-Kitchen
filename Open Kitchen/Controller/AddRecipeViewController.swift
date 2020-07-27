//
//  AddRecipeViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-02.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase
import StoreKit
import GoogleMobileAds
class AddRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    let db = Firestore.firestore()
    
    var userName : String = ""

    @IBOutlet weak var recipeTimeTextField: UITextField!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var methodsTableView: UITableView!
    @IBOutlet weak var ingredientTextField: UITextField!
    @IBOutlet weak var ingredientAmountTextField: UITextField!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var methodImageView: UIImageView!
    @IBOutlet weak var methodTextView: UITextView!
    @IBOutlet weak var metricLabel: UISegmentedControl!
    @IBOutlet weak var add1Button: UIButton!
    @IBOutlet weak var add2Button: UIButton!
    var ingredients : [Ingredient] = []
    var method : [Methods] = []
    var nameToPass : String = ""
    var recipeMethod : [RecipeMethods] = []
    var interstitial: GADInterstitial!
    var numberOfIngredients : Int = 0
    var numberOfMethods : Int = 0
    
    var currentImageView: UIImageView? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       navigationController?.navigationBar.topItem?.title = "Add Your Recipe"
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
   
    
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8846014009643246/9007830246")
                let request = GADRequest()
                  interstitial.load(request)
    
        recipeName.text = nameToPass
        ingredientsTableView.delegate = self
        methodsTableView.delegate = self
        ingredientsTableView.dataSource = self
        methodsTableView.dataSource = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))

        recipeImageView.isUserInteractionEnabled = true
        recipeImageView.addGestureRecognizer(tapGestureRecognizer)

        let tapGestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(tap))
        methodImageView.isUserInteractionEnabled = true
        methodImageView.addGestureRecognizer(tapGestureRecognizer1)
        
        loadPersonalRecipe()
        loadUserName()
    
    }
    
    enum AppStoreReviewManager {
      static func requestReviewIfAppropriate() {
        SKStoreReviewController.requestReview()
      }
    }
    
    var chef = [String]()
    
    
    @IBAction func deleteRecipeButton(_ sender: UIButton) {
        // create the alert
    let alert = UIAlertController(title: "Delete this Recipe", message: "Are you sure you want to delete this recipe? All your progress will be deleted!", preferredStyle: UIAlertController.Style.alert)
                // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            self.performSegue(withIdentifier: "delete", sender: self)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    self.present(alert, animated: true, completion: nil)
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
    func loadPersonalRecipe() {
           let userLiker = Auth.auth().currentUser?.email
           db.collection("Chef").whereField("chef", isEqualTo: userLiker!).getDocuments()
           { (querySnapshot, error) in
              if let e = error {
                  print("There was an issue retrieving data from Firestore \(e)")
              }
              else {
                for document in querySnapshot!.documents {
                          let data = document.data()
                   if let userLiked = data["recipe"] as? [String]{
                            self.chef = userLiked
                        }
                    }
                }
            }
           
       }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        currentImageView = (sender.view as! UIImageView)
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
        currentImageView?.image = (image as! UIImage)
    self.dismiss(animated: true, completion: nil)
    }
      
    

    
    @IBAction func ingredientButtonPressed(_ sender: UIButton) {
        insertNewIngredient()
        print(ingredients)

    }
    
    func insertNewIngredient() {
        let metricTitle = metricLabel.titleForSegment(at: metricLabel.selectedSegmentIndex)!
        let newIngredients = ingredientTextField.text! + " " + ingredientAmountTextField.text! + "" + metricTitle
        let ingredients_append = (Ingredient(ingredient:newIngredients))
        ingredients.append(ingredients_append)
        let indexPath = IndexPath(row: ingredients.count - 1, section: 0)
        ingredientsTableView.beginUpdates()
        ingredientsTableView.insertRows(at: [indexPath], with: .automatic)
        ingredientsTableView.endUpdates()
        
        ingredientTextField.text = ""
        view.endEditing(true)
        let messageBody = newIngredients
        let recipe = recipeName.text
        db.collection("Ingredients").addDocument(data: ["Ingredients" : messageBody, "recipeName" : recipe!])
            { (error) in
                if let e = error {
                    print("There was an issue saving data to firestore, \(e)")
                }
                else {
                    print("Successfully Saved data")
                    
                }
            }
            
        }
    
    
    @IBAction func insertNewMethod(_ sender: UIButton) {
        insertNewMethod()
        self.showToast(message: "Step Added! Scroll down, wait for text to clear", font: .systemFont(ofSize: 12.0))
        
    }
    
    
    func insertNewMethod() {
        // Savings the Photo into Firebase
              guard let image = methodImageView.image, let data = image.jpegData(compressionQuality: 1.0)
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
                      
                      //let methodToImage = String(self.method.count)
                    let dataReference = Firestore.firestore().collection("Method Images").document()
                      let documentUid = dataReference.documentID
                      let urlString = url.absoluteString
                      let method = self.methodTextView.text!
                      let data = ["name" : documentUid,
                                  "imageUrl" : urlString,
                                  "imageToMethod" : self.recipeName.text!,
                                  "date" : String(Date().timeIntervalSince1970),
                                  "Method Description" : method] as [String : Any]
                      dataReference.setData(data) { (err) in
                          if err != nil {
                              print("Error")
                              return
                          }
                          print("Success!")
                        DispatchQueue.main.async {
                            self.methodTextView.text = ""
                            self.methodImageView.image = #imageLiteral(resourceName: "Image-2")
                                }
                      }
              })
        }
        // Saving the recipeMethod into Firebase
//             let recipe = recipeName.text
//              let methodIndex = recipeMethod.count
//              db.collection("recipeMethods").addDocument(data: ["Methods" : methodTextField.text!, "recipeName" : recipe!,"methodToImage" : methodIndex])
//                         { (error) in
//                             if let e = error {
//                                 print("There was an issue saving data to firestore, \(e)")
//                          }
//                             else {
//                                 print("Successfully Saved data")
//
//                             }
//                         }
        let method_append = (Methods(step: String("\(method.count + 1)"), description: methodTextView.text! , stepImage: methodImageView.image!)) //this just displays for the user
        //let methodRecipe_append = (RecipeMethods(description: methodTextField.text!)) // Need to send this to firestore
        //recipeMethod.append(methodRecipe_append)
        method.append(method_append)
        let indexPath = IndexPath(row: method.count - 1, section: 0)
        methodsTableView.beginUpdates()
        methodsTableView.insertRows(at: [indexPath], with: .automatic)

        methodsTableView.endUpdates()
        methodsTableView.reloadData()
        methodsTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
       

        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView.tag == 1) {
            numberOfIngredients = ingredients.count
            return numberOfIngredients
        }
        else if (tableView.tag == 2) {
            numberOfMethods = method.count
            return numberOfMethods
        }
        return 0
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if (tableView.tag == 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as
                  UITableViewCell
            let ingredient = ingredients[indexPath.row]
            cell.textLabel?.text = "\(ingredient.ingredient)"
            return cell
        }
        
        else if (tableView.tag == 2) {
            let cell =  tableView.dequeueReusableCell(withIdentifier: "cellx", for: indexPath) as? MethodCell
            let methods = method[indexPath.row]
            cell?.setMethod(method: methods)
            return cell!
            }
        return UITableViewCell()
        }
     
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tableView.tag == 1 {
            if editingStyle == .delete {
                let name = ingredients[indexPath.row].ingredient
                db.collection("Ingredients").whereField("Ingredients", isEqualTo: name).getDocuments(completion: { (snapshot, error) in
                               if let error = error {
                                   print(error.localizedDescription)
                               } else {
                                   for document in snapshot!.documents {
                                    let id = document.documentID
                                    self.db.collection("Ingredients").document(id).delete()
                               }
                           }
                    
                })
                ingredients.remove(at: indexPath.row)
                ingredientsTableView.beginUpdates()
                ingredientsTableView.deleteRows(at: [indexPath], with: .automatic)
                ingredientsTableView.endUpdates()
            }
        }
        if tableView.tag == 2 {
            if editingStyle == .delete {
                //lets first delete the photo from the gallery
               //TODO need to delete images in the storage
                let methodName = method[indexPath.row].description
                print(methodName)
                db.collection("Method Images").whereField("Method Description", isEqualTo: methodName).getDocuments(completion: { (snapshot, error) in
                                              if let error = error {
                                                  print(error.localizedDescription)
                                              } else {
                                                  for document in snapshot!.documents {
                                                   let id = document.documentID
                                                   self.db.collection("Method Images").document(id).delete()
                                                print("Document has been successfully deleted")
                                              }
                                          }
                                   
                        })
                
                method.remove(at: indexPath.row)
                methodsTableView.beginUpdates()
                methodsTableView.deleteRows(at: [indexPath], with: .automatic)
                methodsTableView.endUpdates()
            }
        }
    }

    
    
    @IBAction func submit(_ sender: Any) {
        if interstitial.isReady {
          interstitial.present(fromRootViewController: self)
        } else {
          print("Ad wasn't ready")
        }
        
        chef.append(recipeName.text!)
        let currentDateTime = Date()
        let formater = DateFormatter()
        formater.timeStyle = .short
        formater.dateStyle = .long
        let dateTimeString = formater.string(from: currentDateTime)
        
        
        var dictionary1:[String:Any] {
                     return [
                         "words1" : method.map({$0.mdictionary})
                     ]
               }
        
        AddPersonalRecipe()
        

//        db.collection("Ingredients").document(recipeName.text!).setData(dictionary)
//            { (error) in
//                if let e = error {
//                    print("There was an issue saving data to firestore, \(e)")
//                }
//                else {
//                    print("Successfully Saved data")
//                }
//
//        }
        db.collection("methods").document(dateTimeString).setData(dictionary1)
                 { (error) in
                     if let e = error {
                         print("There was an issue saving data to firestore, \(e)")
                     }
                     else {
                         print("Successfully Saved data")
                     }
        }
        
        
        
        guard let image = recipeImageView.image, let data = image.jpegData(compressionQuality: 1.0)
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
                    let dataReference = Firestore.firestore().collection("RecipeImage").document(dateTimeString)
                    let documentUid = dataReference.documentID
                    let urlString = url.absoluteString
                    let currentUserEmail = Auth.auth().currentUser?.email
                    let data = ["name" : documentUid,
                                "sender" : self.userName,
                                "imageUrl" : urlString,
                                "senderEmail" : currentUserEmail!,
                                "recipeTime" : self.recipeTimeTextField.text ?? "",
                                "recipeName" : self.recipeName.text!] as [String : Any];
                    dataReference.setData(data) { (err) in
                        if err != nil {
                            print("Error")
                            return
                        }
                        print("Success!")
                    }
            })
        }
        AppStoreReviewManager.requestReviewIfAppropriate()
    }
    
    func AddPersonalRecipe() {

            let userLiker = Auth.auth().currentUser?.email
            db.collection("Chef").document(userLiker!).setData([
                "recipe" : chef ,
                "chef" : userLiker!
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
}


