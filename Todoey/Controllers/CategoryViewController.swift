//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hjaseyyh Grursht on 06.05.2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: UITableViewController {
    
    let realm = try! Realm()
    
    
    var categoryArr: Results<Category>?


    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        tableView.separatorStyle = .none
    }
    
    //MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return categoryArr?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArr?[indexPath.row].name ?? "No categories added yet"
        cell.backgroundColor = UIColor.init(hexString: categoryArr?[indexPath.row].colour ?? "007AFF")
        return cell
    }


        
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArr? [indexPath.row]
        }
    }
    
    //MARK: Add New Categories

    @IBAction func addButtonPressed(_ sender:UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addTextField { field in
            field.placeholder = "Create New Item"
            textField = field
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    

    
//MARK: - Data Manupulation Methods
    func save(category: Category) {
        do {
            try realm.write({
                realm.add(category)
            })
        }   catch {
            print("Error saving context\(error)")
        }
        tableView.reloadData()
    }
    func loadCategories() {
        
        categoryArr = realm.objects(Category.self)
        
       tableView.reloadData()
    }

}


//MARK: - Deleting rows

extension CategoryViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            if let item = categoryArr?[indexPath.row] {
                try! realm.write{
                    realm.delete(item)
                }
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }
    }
}
