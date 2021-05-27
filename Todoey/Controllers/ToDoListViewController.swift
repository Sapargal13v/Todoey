//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoViewController: UITableViewController {
    // collection type
    var todoItems: Results<Item>?
    let realm = try! Realm()
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    var selectedCategory: Category? {
        didSet {
            loadItem()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
            if let navBarColor = UIColor(hexString: colourHex) {
                navBar.barTintColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
        
        cell.textLabel?.text = item.title
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        
        cell.accessoryType = item.done ? .checkmark : .none
        }   else {
            cell.textLabel?.text = "No items added"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write{
                    item.done = !item.done
                }
            }   catch {
                print("Error saving done status \(error)")
            }
        }
        
       // print(todoItems[indexPath.row])
  
        // if false / true
//        context.delete(todoItems[indexPath.row])
//        todoItems.remove(at: indexPath.row)
//
        
        tableView.reloadData()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Todoey item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //What will happen once the user clicks the add item button on our UIAlert
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                    let newItem = Item()
                    newItem.title = textField.text!
                        newItem.dateCreated = Date()
                    currentCategory.items.append(newItem)
                }
                }   catch {
                    print("Error saving new items \(error)")
                }
            }
            self.tableView.reloadData()
            
        }
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
 
    // MARK - Model Manupulation Methods

    
    func loadItem(){
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
//        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
//
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionalPredicate])
//        }   else {
//            request.predicate = categoryPredicate
//        }
//
//        do {
//       todoItems = try context.fetch(request)
//        } catch {
//            print("Error fetching data from context \(error)")
//        }
        tableView.reloadData()
    }
    
}

//MARK: - Search bar methods
extension ToDoViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
}
    
//MARK: - Deleting rows

extension ToDoViewController {
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            if let item = todoItems?[indexPath.row] {
                try! realm.write{
                    realm.delete(item)
                }
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
        }
    }
    }

