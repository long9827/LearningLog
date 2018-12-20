//
//  EntryTableViewController.swift
//  LearningLog
//
//  Created by nonamer on 2018/12/14.
//  Copyright © 2018年 龙洪杰. All rights reserved.
//

import UIKit
import CoreData
import os.log

class EntryTableViewController: UITableViewController {
    
    //MARK: Properties
    var entries = [NSManagedObject]()
    
    var topicText: String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entry")
        let topictext = navigationItem.title ?? ""
//        print(topictext)
//
//        fetchRequest.predicate = NSPredicate(format: "topic=fdsfsd", "topic")
//        fetchRequest.predicate = predicate
        
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                entries = []
                for result in results {
                    if result.value(forKey: "topic") as? String == topictext {
                        entries += [result]
                    }
                }
                if entries.count == 0 {
                    let msgAlertCtr = UIAlertController.init(title: "提示", message: "此主题为空", preferredStyle: .alert)
                    
                    let ok = UIAlertAction.init(title: "确定", style: .cancel) {
                        (action: UIAlertAction) -> () in
                    }
                    
                    msgAlertCtr.addAction(ok)
                    self.present(msgAlertCtr, animated: true, completion: nil)
                    
                }
                tableView.reloadData()
            }
        } catch {
            print("获取失败")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = topicText
        
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return entries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "EntryTableViewCell"
        

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EntryTableViewCell else {
            fatalError("The dequeued cell is not an instance of EntryTableViewCell.")
        }
        
        let entry = entries[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        
        let creationDate = entry.value(forKey: "creationDate")
        let text = entry.value(forKey: "text")
        
        cell.creationTimeLabel.text = dateFormatter.string(from: creationDate as! Date)
        cell.entryTextLable.text = text as! String
        
        tableView.estimatedRowHeight = 300

        return cell
        
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let id = entries[indexPath.row].objectID
            
            deleteEntry(id: id)
            entries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        case "AddEntryItem":
            guard let navigation = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            navigation.title = navigationItem.title
            os_log("Adding a New Entry", log: OSLog.default, type: .debug)
        case "ShowEntryDetail":
            guard let entryDetailViewController = segue.destination as? EntryViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedEntryCell = sender as? EntryTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedEntryCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedEntry = entries[indexPath.row]
            let creationDate = selectedEntry.value(forKey: "creationDate")
            let text = selectedEntry.value(forKey: "text")
            let topic = selectedEntry.value(forKey: "topic")
            
            
            let selectedEntryDetail = EntryDetail(creationDate: creationDate as! Date, text: text as! String, topic: topic as! String)
            
            entryDetailViewController.entry = selectedEntryDetail
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    //MARK: Actions
    @IBAction func unwindToEntryList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? EntryViewController, let entry = sourceViewController.entry {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //update
                print("update")
//                entries[selectedIndexPath.row].value(forKey: "") = entry
                updateEntry(row: selectedIndexPath.row, text: entry.text)
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                //add
                print("add")
                let newIndexPath = IndexPath(row: entries.count, section: 0)
                addEntry(topic: entry.topic, text: entry.text)
            }
            
        }
    }
    
    //MARK: Private Methods
    private func updateEntry(row: Int , text: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        entries[row].setValue(text, forKey: "text")
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("无法保存")
        }
    }
    private func addEntry(topic: String, text: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Entry", in: managedObjectContext)
        
        let entry = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        
        entry.setValue(topic, forKey: "topic")
        entry.setValue(text, forKey: "text")
        entry.setValue(Date(), forKey: "creationDate")
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("无法保存")
        }
        entries.append(entry)
    }
    private func deleteEntry(id: NSManagedObjectID) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let deleteTopic = managedObjectContext.object(with: id)
        
        managedObjectContext.delete(deleteTopic)
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("无法保存")
        }
    }
}
