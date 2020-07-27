//
//  CollectionViewController.swift
//  Open Kitchen
//
//  Created by Brandon Kan  on 2020-06-17.
//  Copyright © 2020 Brandon Kan . All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "newcell"
var valueToPass : String  = ""


class CollectionViewController: UICollectionViewController {
    
    
    
    var likedRecipes: [LikedRecipes] = []
    let db = Firestore.firestore()
    
    var array : Array<String> = []
    
    
    override func viewWillAppear(_ animated: Bool) {
               super.viewWillAppear(animated)
              navigationController?.navigationBar.topItem?.title = "Liked Recipes"
           }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        let width = (view.frame.size.width - 20) / 3
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        loadLikeRecipe()
    }
    
    
    func loadLikeRecipe() {
        let currentUser = Auth.auth().currentUser?.email
        db.collection("Users").whereField("user", isEqualTo: currentUser!)
          .addSnapshotListener { (queryShapshot, error) in
          if let e = error {
              print("There was an issue retrieving data from Firestore \(e)")
          }
          else {
              if let snapshotDocuments = queryShapshot?.documents {
                  for doc in snapshotDocuments {
                      let data = doc.data()
                    if let messageSender = data["recipeName"] as? [String]  {
                        self.array = messageSender
                        DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}
    }

 

    // MARK: UICollectionViewDataSource



    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return array.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell

        cell.likeRecipeName.text = array[indexPath.row]
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1.0;

        
        
        return cell
        }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let myCell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell {
            valueToPass = (myCell.likeRecipeName.text)! as String
       self.performSegue(withIdentifier: "favoriteToRecipe", sender: self)
    }
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "favoriteToRecipe" {
        let destinationVC = segue.destination as! RecipeViewerViewController
        destinationVC.valueToPass = valueToPass
                }
    }
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
