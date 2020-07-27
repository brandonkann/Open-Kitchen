//
//  RecipeViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-01.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
// model ID: ca-app-pub-8846014009643246/9007830246

class RecipeViewController: UIViewController, UISearchBarDelegate {
    
    var recipeTitle = ""
    var imageURL = ""
    var valueToPass = "0"
    var valueToPass1 = #imageLiteral(resourceName: "Untitled design (4).png")
    var valueToPass2 = ""
    var interstitial: GADInterstitial!

    
    @IBOutlet weak var recipeSearchBar: UISearchBar!
    @IBOutlet weak var recipeTableView: UITableView!
    let db = Firestore.firestore()
    
    var recipes: [Recipes] = []
    var searchMaterial = [Recipes]()
    var likeRecipes : [RecipesLikes] = []
    var array = [RecipesLikes]()
    var imageList = [UIImage]()
    var searching = false
    

    override func viewDidLoad() {
          super.viewDidLoad()
         self.tabBarController!.navigationItem.setHidesBackButton(true, animated: false)

        
        recipeSearchBar.delegate = self
        recipeTableView.delegate = self
        recipeTableView.dataSource = self
        
        loadLikes()
        
        

        loadRecipeImages()
        searchMaterial = recipes



        
      }
    // New
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            let vc = storyboard?.instantiateViewController(identifier: "welcome") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    

   override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         navigationController?.navigationBar.topItem?.title = "Open Kitchen"
    }

 
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // ONBOARDING LOGIC BEGINGS HERE
    

    


    
    func loadRecipeImages() {
        db.collection("RecipeImage").order(by: "name")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let recipeImage = data["imageUrl"] as? String, let recipeName = data["recipeName"] as? String, let recipeOwner = data["sender"] as? String, let recipeTime = data["recipeTime"] as? String {
                             DispatchQueue.global().async {
                            let url = URL(string: recipeImage)
                            if let data = try? Data(contentsOf: url!)
                            {
                                DispatchQueue.main.async {
                                let image: UIImage = UIImage(data: data)!
                                    self.recipes.append(Recipes(image: image, title: recipeName, rating: recipeOwner, time: recipeTime))
                                self.recipeTableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadLikes() {
        db.collection("Likes").getDocuments() { (querySnapshot, err) in
            if let err = err {
            print("Error getting documents: \(err)")
                } else {
            for document in querySnapshot!.documents {
            let data = document.data()
                if let newData = data["numberOfLikes"] as? String, let newRecipeName = data["recipeName"] as? String {
                    self.likeRecipes.append(RecipesLikes(Recipes: newData, Likes: newRecipeName))
                    // NEED TO WORK ON THIS
                }
            }
    }
}
    }
        


    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            searchMaterial = recipes
            recipeTableView.reloadData()
            return
            
        }
        searchMaterial = recipes.filter({ (Recipes) -> Bool in
            Recipes.title.lowercased().contains(searchText.lowercased())
        
//        recipeSearchBar.delegate = self
//        searchMaterial = recipes.filter({ (Recipes) -> Bool in
//            guard let text = searchBar.text else {return false}
//            return Recipes.title.contains(text)
        })
        searchBar.setShowsCancelButton(true, animated: true)
        searching = true
        recipeTableView.reloadData()

    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
          searchBar.setShowsCancelButton(false, animated: true)
          searching = false
          searchBar.text = ""
          recipeTableView.reloadData()

      }
    
   
}



extension RecipeViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchMaterial.count
        }
        else {
        return recipes.count
    }
}
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeCells", for: indexPath) as? ImageCell
        if searching {
            let searchRecipe = searchMaterial[indexPath.row]
            cell?.recipeTitleLabel.text = searchRecipe.title
            cell?.recipeImageView.image = searchRecipe.image
            cell?.recipeOwner.text = searchRecipe.rating
            cell?.recipeTime.text = "\(searchRecipe.time) mins"
        }
        
        else {
                let recipe = self.recipes[indexPath.row]
        cell?.recipeTitleLabel.text = recipe.title
        cell?.recipeImageView.image = recipe.image
            cell?.recipeOwner.text = recipe.rating
            cell?.recipeTime.text = "\(recipe.time) mins"
            }
        return cell!
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as? ImageCell
        
        valueToPass = (currentCell?.recipeTitleLabel.text!)! as String
        valueToPass1 = (currentCell?.recipeImageView.image!)! as UIImage
        valueToPass2 = (currentCell?.recipeOwner.text!)! as String
        print("value: \(valueToPass)")
        print("Image: \(valueToPass1)")
        print("rating: \(valueToPass2)")
        
        
        self.performSegue(withIdentifier: "segue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             if segue.identifier == "segue" {
                 let destinationVC = segue.destination as! RecipeViewerViewController
                 destinationVC.valueToPass = valueToPass
                destinationVC.valueToPass1 = valueToPass1
                destinationVC.valueToPass2 = valueToPass2
             }
      }
}

