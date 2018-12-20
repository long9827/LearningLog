//
//  EntryViewController.swift
//  LearningLog
//
//  Created by nonamer on 2018/12/14.
//  Copyright © 2018年 龙洪杰. All rights reserved.
//

import UIKit
import os.log

class EntryViewController: UIViewController, UITextViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var entryTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var topicLabel: UILabel!
    
    var entry: EntryDetail?
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        
        let isPresentingInAddEntryMode = presentingViewController is UINavigationController
        
        if isPresentingInAddEntryMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The EntryViewController is not inside a navigation controler.")
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        entryTextView.delegate = self
        
        if let entry = entry {
            navigationItem.title = "Edit Entry"
            entryTextView.text = entry.text
            topicLabel.text = entry.topic
        } else {
            os_log("add", log: OSLog.default, type: .debug)
            topicLabel.text = navigationController?.title
        }
        
        
//        updateSaveButtonState()
        saveButton.isEnabled = false
    }
    
    //MARK: UITextViewDelegate
    func textViewDidBeginEditing(_ entryTextView: UITextView) {
        saveButton.isEnabled = false
    }
    func textViewDidChange(_ entryTextView: UITextView) {
        updateSaveButtonState()
    }
    func textViewShouldReturn(_ entryTextView: UITextView) -> Bool {
        // Hide the keyboard
        entryTextView.resignFirstResponder()
        return true
    }
    

    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        let text = entryTextView.text ?? ""
        let topic = topicLabel.text ?? ""
        let creationDate = entry?.creationDate ?? Date()
        
        entry = EntryDetail(creationDate: creationDate, text: text, topic: topic)
    }
    
    private func updateSaveButtonState() {
        let text = entryTextView.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }

}

