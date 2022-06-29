//
//  TableViewController.swift
//  mementoBook
//
//  Created by Turgay Ceylan on 29.06.2022.
//

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var placesTable: UITableView!
    var placeNames : [String] = []
    var placeIDs : [UUID] = []
    var chosedPlaceID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton))
        placesTable.delegate = self
        placesTable.dataSource = self
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        refresh()
    }
    
    func refresh(){
        placeNames.removeAll(keepingCapacity: true)
        placeIDs.removeAll(keepingCapacity: true)
        loadData()
        placesTable.reloadData()
    }
    
    func loadData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject]  {
                placeNames.append(result.value(forKey: "title") as! String)
                placeIDs.append(result.value(forKey: "id") as! UUID)
            }
        }catch{
            print("error, selecting rows")
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = placeNames[indexPath.row]
        return cell
    }
    
    @objc func addButton(){
        performSegue(withIdentifier: "addSegueVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailsVC" {
            let destVC = segue.destination as! DetailsViewController
            destVC.chosenPlaceID = chosedPlaceID
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosedPlaceID = placeIDs[indexPath.row]
        performSegue(withIdentifier: "detailsVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let pred = NSPredicate(format: "id = %@", placeIDs[indexPath.row].uuidString)
            let delete = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            delete.predicate = pred
            
            do{
                let results = try context.fetch(delete)
                
                for result in results {
                    context.delete(result as! NSManagedObject)
                    
                }
                
                do{
                    try context.save()
                    print("deleted")
                    placeNames.remove(at: indexPath.row)
                    placeIDs.remove(at: indexPath.row)
                    tableView.reloadData()
                }catch{
                    print("deleting an item error")
                }
               
            }
            catch{
                print("deleting error")
            }
            
        }
    }
}
