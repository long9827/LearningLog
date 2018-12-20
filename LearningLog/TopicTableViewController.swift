//
//  TopicTableViewController.swift
//  LearningLog
//
//  Created by nonamer on 2018/12/16.
//  Copyright © 2018年 龙洪杰. All rights reserved.
//

import UIKit
import CoreData

class TopicTableViewController: UITableViewController {
    
    //MARKS: Properties
//    var topics = [Topic]()
    var topics = [NSManagedObject]()
    
    
    //MARKS: Action
    @IBAction func addNewTopic(_ sender: UIBarButtonItem) {
        print("Add New Topic")
        var inputText: UITextField = UITextField()
        
        let msgAlertCtr = UIAlertController.init(title: "New Topic", message: "", preferredStyle: .alert)
        
        let ok = UIAlertAction.init(title: "confirm", style: .default) {
            (action: UIAlertAction) -> () in
            if ((inputText.text) != "") {
                //add new topic
                let newTopic = inputText.text ?? ""
                
//                let topic = Topic(creationTime: Date(), text: newTopic)!
                
                self.addTopic(text: newTopic)
                
                let newIndexPath = IndexPath(row: self.topics.count-1, section: 0)
//                self.topics.append(topic)
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        
        let cancel = UIAlertAction.init(title: "cancel", style: .cancel) {
            (action: UIAlertAction) -> () in
        }
        
        msgAlertCtr.addAction(ok)
        msgAlertCtr.addAction(cancel)
        msgAlertCtr.addTextField{(textField) in
            inputText = textField
            inputText.placeholder = "pleases input topic"
        }
        self.present(msgAlertCtr, animated: true, completion: nil)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Topic")
        
        do {
            let fetchedResults = try managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                topics = results
                tableView.reloadData()
            }
            
        } catch {
            fatalError("获取失败")
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)

//        loadSampleMeals()
//        tableView.register
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return topics.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TopicTableViewCell"
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TopicTableViewCell else {
            fatalError("The dequeued cell is not an instance of TopicTableViewCell.")
        }
        
        let topic = topics[indexPath.row]
        
        cell.topicTextLabel.text = topic.value(forKey: "text") as? String
    
        tableView.estimatedRowHeight = 300
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let id = topics[indexPath.row].objectID
            deleteTopic(id: id)
            
            topics.remove(at: indexPath.row)
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
        case "ShowEntries":
            guard let entryTableViewController = segue.destination as? EntryTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedTopicCell = sender as? TopicTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedTopicCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedTopic = topics[indexPath.row]
            entryTableViewController.topicText = selectedTopic.value(forKey: "text") as! String
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    //MARK: Private Methods
    
    private func addTopic(text: String) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Topic", in: managedObjectContext)
        
        let topic = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        
        topic.setValue(text, forKey: "text")
        topic.setValue(Date(), forKey: "creationDate")
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("无法保存")
        }
        topics.append(topic)
    }
    private func deleteTopic(id: NSManagedObjectID) {
        
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
