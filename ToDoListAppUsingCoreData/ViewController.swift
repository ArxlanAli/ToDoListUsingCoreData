//
//  ViewController.swift
//  ToDoListAppUsingCoreData
//
//  Created by Arslan Ali on 21/7/18.
//  Copyright © 2018 Arslan Ali. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var lisItems = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .white
        self.navigationItem.title = "My List"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addItem))
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "id")
        self.fetchFromCoreData()
    }
    
    
    func fetchFromCoreData(){
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "List")
        request.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(request)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    self.lisItems.append(result)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("Something error in fetching")
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lisItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        cell.textLabel?.text = self.lisItems[indexPath.row].value(forKey: "item") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            let conetxt = appDelegate.persistentContainer.viewContext
            conetxt.delete(self.lisItems[indexPath.row])
            do{
                try conetxt.save()
                self.lisItems.remove(at: indexPath.row)
                print(lisItems.count)
                self.tableView.reloadData()
            }
            catch{
                print("Error in deleting")
            }

        }
    }
    
    func itemToSave(itemToSave:String){
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let item = NSEntityDescription.insertNewObject(forEntityName: "List", into: managedContext)
        item.setValue(itemToSave, forKey: "item")
        
        do{
            try managedContext.save()
            lisItems.append(item)
        }catch{
            print("error in insertion")
        }
    }
    
    @objc func addItem(){
        let alert = UIAlertController(title: "ADD", message: "Give name of item", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "ADD", style: UIAlertActionStyle.default, handler: { (_) in
            guard let text = alert.textFields?.first?.text else { return }
            self.itemToSave(itemToSave: text)
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addTextField { (textField) in
            textField.placeholder = "Add Item"
        }
        self.present(alert, animated: true, completion: nil)
    }
}

